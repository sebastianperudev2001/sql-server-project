-- =============================================
-- Flexer DWH
-- 06_etl_reprocess.sql
-- Reproceso de correcciones del LLM
-- Detecta registros con updated_at > last_load_date
-- los elimina del DWH y los reinserta corregidos
-- =============================================

USE FlexerDWH;
GO

DECLARE @last_load_date DATETIME2;
DECLARE @rows_deleted   INT = 0;
DECLARE @rows_inserted  INT = 0;

-- Obtener ultima fecha de carga
SELECT @last_load_date = last_load_date
FROM dwh.etl_control
ORDER BY executed_at DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- =============================================
-- PASO 1: Eliminar sets modificados del DWH
-- Detecta workout_sets con updated_at > last_load_date
-- =============================================
DELETE FROM dwh.fact_sets
WHERE set_source_id IN (
    SELECT ws.id
    FROM oltp.workout_sets ws
    WHERE ws.updated_at > @last_load_date
);

SET @rows_deleted = @@ROWCOUNT;

-- =============================================
-- PASO 2: Eliminar llm_logs modificados del DWH
-- =============================================
DELETE FROM dwh.fact_llm_requests
WHERE log_source_id IN (
    SELECT ll.id
    FROM oltp.llm_logs ll
    WHERE ll.updated_at > @last_load_date
);

-- =============================================
-- PASO 3: Reinsertar sets con data corregida
-- =============================================
INSERT INTO dwh.fact_sets (
    user_key, exercise_key, date_key, workout_source_id,
    set_source_id, set_number, source, reps, weight_kg, rpe, duration_sec
)
SELECT
    du.user_key,
    de.exercise_key,
    dt.date_key,
    w.id,
    ws.id,
    ws.set_number,
    ws.source,
    ws.reps,
    ws.weight_kg,
    ws.rpe,
    ws.duration_sec
FROM oltp.workout_sets ws
JOIN oltp.workouts w
    ON w.id = ws.workout_id
JOIN dwh.dim_users du
    ON du.user_id = w.user_id AND du.is_current = 1
JOIN dwh.dim_exercises de
    ON de.exercise_id = ws.exercise_id AND de.is_current = 1
JOIN dwh.dim_time dt
    ON dt.date_key = CAST(FORMAT(w.date, 'yyyyMMdd') AS INT)
WHERE ws.updated_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.fact_sets fs
    WHERE fs.set_source_id = ws.id
);

SET @rows_inserted = @@ROWCOUNT;

-- =============================================
-- PASO 4: Reinsertar llm_logs corregidos
-- =============================================
INSERT INTO dwh.fact_llm_requests (
    user_key, date_key, log_source_id,
    parsed_ok, raw_input_length, error_details
)
SELECT
    du.user_key,
    dt.date_key,
    ll.id,
    ll.parsed_ok,
    LEN(ll.raw_input),
    ll.error_details
FROM oltp.llm_logs ll
JOIN oltp.workouts w
    ON w.id = ll.workout_id
JOIN dwh.dim_users du
    ON du.user_id = w.user_id AND du.is_current = 1
JOIN dwh.dim_time dt
    ON dt.date_key = CAST(FORMAT(w.date, 'yyyyMMdd') AS INT)
WHERE ll.updated_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.fact_llm_requests flr
    WHERE flr.log_source_id = ll.id
);

-- =============================================
-- PASO 5: Registrar en etl_control
-- =============================================
INSERT INTO dwh.etl_control (process_name, last_load_date, rows_inserted, status)
VALUES ('reprocess_load', GETDATE(), @rows_inserted, 'success');

-- Resumen
SELECT
    'reprocess_load'    AS process,
    @rows_deleted       AS rows_deleted,
    @rows_inserted      AS rows_reinserted;
