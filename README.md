# Flexer Data Warehouse

**SQL for Analytics · Trabajo Final**

Flexer es un asistente de gym basado en WhatsApp que permite registrar entrenamientos mediante lenguaje natural. Este proyecto implementa una capa analítica separada de la base transaccional, siguiendo el patrón de modelado dimensional de Kimball (Star Schema).

---

## Stack Técnico

| Componente             | Tecnología                                  |
| ---------------------- | ------------------------------------------- |
| Motor de base de datos | SQL Server Express                          |
| Cliente                | SQL Server Management Studio (SSMS)         |
| Patrón dimensional     | Kimball Star Schema                         |
| Estrategia ETL         | Batch (Histórico + Incremental + Reproceso) |

---

## Arquitectura

```
WhatsApp
   │
   ▼
AI Agent (LLM)
   │  Text Interpretation & Extraction
   ▼
PostgreSQL / Supabase (OLTP)          SQL Server (DWH)
──────────────────────────            ──────────────────────────
oltp.muscle_groups                    dwh.dim_users      (SCD Type 2)
oltp.movement_types                   dwh.dim_exercises  (SCD Type 2)
oltp.users                            dwh.dim_time
oltp.exercises                        dwh.fact_sets
oltp.workouts          ── ETL ──►     dwh.fact_workouts
oltp.llm_logs                         dwh.fact_llm_requests
oltp.workout_sets                     dwh.etl_control
```

---

## Modelo Dimensional

### Dimensiones

| Tabla           | Descripción                                                        | SCD      |
| --------------- | ------------------------------------------------------------------ | -------- |
| `dim_users`     | Usuarios con tier free/premium                                     | Type 2   |
| `dim_exercises` | Ejercicios desnormalizados con grupo muscular y tipo de movimiento | Type 2   |
| `dim_time`      | Calendario 2024–2026 con atributos temporales                      | Estática |

### Fact Tables

| Tabla               | Granularidad            | Métricas clave                                   |
| ------------------- | ----------------------- | ------------------------------------------------ |
| `fact_sets`         | 1 row por serie         | `weight_kg`, `reps`, `rpe`, `volume_kg`          |
| `fact_workouts`     | 1 row por entrenamiento | `duration_min`, `total_sets`, `total_volume_kg`  |
| `fact_llm_requests` | 1 row por mensaje LLM   | `parsed_ok`, `raw_input_length`, `error_details` |

---

## Decisiones de Diseño

### OLTP — Normalización (3NF)

**Lookup tables para dominios**
`muscle_groups` y `movement_types` como tablas de catálogo independientes, evitando anomalías de actualización. Cambiar "Pecho" a "Pectorales" impacta un solo registro.

**`llm_logs` separado de `workout_sets`**
El `raw_input` del LLM no depende de la serie individual sino del evento de parseo. Un mensaje "Press banca 4x10 80kg" genera 1 log y 4 sets — relación limpia sin redundancia.

**`log_id NULL` en `workout_sets`**
Permite ingreso manual desde UI sin romper la trazabilidad del LLM. La columna `source` ('llm', 'manual', 'adjustment') registra el origen de cada serie.

**Unicidad compuesta**
`UNIQUE (workout_id, exercise_id, set_number)` garantiza que no existan dos "Set 1" del mismo ejercicio en el mismo entrenamiento. El `set_number` lo asigna la aplicación consultando `MAX(set_number) + 1`.

### DWH — Modelo Dimensional

**Star Schema (no Snowflake)**
`muscle_group` y `movement_type` desnormalizados dentro de `dim_exercises`. Menos JOINs, mejor rendimiento de lectura en BI.

**SCD Type 2**
`valid_from`, `valid_to` e `is_current` en `dim_users` y `dim_exercises` permiten analizar el comportamiento de un usuario antes y después de pasar a tier premium sin perder historia.

**Sin `dim_workouts`**
`workout_source_id` como dimensión degenerada en `fact_sets` para evitar el problema de fan-out. `duration_min` vive en `fact_workouts` con su propio grano.

**Dos fact tables con granos distintos**
Separa métricas de nivel serie (peso, reps) de métricas de nivel entrenamiento (duración), eliminando el riesgo de multiplicación de datos en agregaciones.

**`volume_kg` como columna calculada**
`AS (reps * weight_kg)` — se computa automáticamente, estandariza la métrica central y reduce carga en herramientas de BI.

**`date_key` como INT YYYYMMDD**
Best practice de la industria para optimizar índices particionados.

**`fact_llm_requests`**
Diferenciador único de Flexer vs apps tradicionales. Permite analizar el rendimiento del modelo de parseo: tasa de error por ejercicio, longitud promedio de prompts, patrones de fallo.

---

## ETL

### Tres modos de carga

**Carga Histórica** (`04_etl_historical.sql`)
Migración completa única al inicializar el DWH. Sin condición de fecha, extrae toda la data existente del OLTP.

**Carga Incremental** (`05_etl_incremental.sql`)
Batch diario. Usa `etl_control` como marca de agua (`last_load_date`). Filtra por `created_at > last_load_date` y valida `NOT EXISTS` para garantizar idempotencia.

**Reproceso** (`06_etl_reprocess.sql`)
Cuando el LLM corrige un parseo erróneo, detecta registros con `updated_at > last_load_date`, los elimina del DWH y los reinserta con la data corregida.

### Garantías del pipeline

| Garantía         | Mecanismo                                                             |
| ---------------- | --------------------------------------------------------------------- |
| Idempotencia     | `NOT EXISTS` en todas las inserciones                                 |
| Trazabilidad     | `set_source_id` y `log_source_id` como natural keys                   |
| Auditoría        | `etl_control` registra cada ejecución con timestamp y conteo de filas |
| Correcciones LLM | `updated_at` en OLTP detecta cambios post-carga                       |

---

## Queries Analíticos

### Para el usuario (feature premium)

| #   | Query                              | Técnica SQL                              |
| --- | ---------------------------------- | ---------------------------------------- |
| 1   | Progresión de fuerza por ejercicio | `LAG()` sobre peso semanal               |
| 2   | Volumen semanal por grupo muscular | Detección desbalance push/pull           |
| 3   | PRs automáticos                    | `MAX()` agrupado por usuario / ejercicio |
| 4   | Score de consistencia              | Moving average 4 semanas                 |
| 5   | Estimación de 1RM                  | Fórmula Epley: `weight * (1 + reps/30)`  |

### Para el negocio (founder)

| #   | Query                    | Descripción                                |
| --- | ------------------------ | ------------------------------------------ |
| 1   | Engagement post-registro | Actividad individual en semanas 1, 2, 4, 8 |
| 2   | Tasa de error del LLM    | Error rate por ejercicio                   |
| 3   | Distribución por día     | Heatmap de uso semanal                     |
| 4   | Funnel free → premium    | Conversión y engagement por tier           |
| 5   | Detección de churn       | Inactivos > 7 días con risk score          |

---

## Estructura de Scripts

```
scripts/
├── queris_insert_data.sql     # Data simulada
│                              # 3 usuarios · 50 workouts
│                              # 333 sets · 80 LLM logs
├── 01_oltp_schema.sql         # Schema transaccional + lookup tables
├── 02_dwh_schema.sql          # Modelo estrella (dims + facts)
├── 03_dim_time_populate.sql   # Calendario 2024–2026 (1096 días)
├── 04_etl_historical.sql      # Carga completa inicial
├── 05_etl_incremental.sql     # Batch diario con marca de agua
├── 06_etl_reprocess.sql       # Reproceso de correcciones LLM
├── 07_analytics_user.sql      # 5 queries para usuarios premium
└── 08_analytics_business.sql  # 5 queries para el founder
```

---

## Métricas Alcanzadas

- ✅ `0` queries analíticos ejecutados sobre la base transaccional
- ✅ `0` registros duplicados — idempotencia garantizada por `NOT EXISTS`
- ✅ `3` modos de carga implementados y validados
- ✅ `5` reportes para usuarios premium
- ✅ `5` métricas de producto para el founder
- ✅ Correcciones del LLM reflejadas en el DWH en < 24h
- ✅ SCD Type 2 para histórico de cambios de tier
- ✅ Trazabilidad completa: mensaje LLM → log → set → DWH

---

## Data de Prueba

| Usuario        | Tier    | Workouts | Patrón                                          |
| -------------- | ------- | -------- | ----------------------------------------------- |
| Carlos Mendoza | Premium | 24       | 4x semana, push/pull/legs, progresión constante |
| Ana Torres     | Free    | 18       | 3x semana, full body, progresión moderada       |
| Diego Quispe   | Free    | 8        | Irregular, inactivo últimas 2 semanas (churn)   |

Casos especiales incluidos en el script de inserción (`queris_insert_data.sql`):

- `3` errores de parseo LLM simulados (`parsed_ok = 0`)
- Sets con `source = 'adjustment'` corregidos a `source = 'llm'` via reproceso
- Sets con `source = 'manual'` y `log_id = NULL` para ingreso desde UI

---

_Flexer DWH · SQL for Analytics · 2026_
