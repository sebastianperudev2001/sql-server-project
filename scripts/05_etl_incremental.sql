-- =============================================
-- Flexer DWH
-- 05_etl_incremental.sql
-- Carga incremental diaria
-- Extrae solo registros nuevos desde last_load_date
-- =============================================

USE FlexerDWH;
GO

DECLARE @last_load_date DATETIME2;
DECLARE @rows_users     INT = 0;
DECLARE @rows_exercises INT = 0;
DECLARE @rows_workouts  INT = 0;
DECLARE @rows_sets      INT = 0;
DECLARE @rows_llm       INT = 0;

-- Obtener ultima fecha de carga
SELECT @last_load_date = last_load_date
FROM dwh.etl_control
ORDER BY executed_at DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

-- =============================================
-- 1. NUEVOS USUARIOS
-- =============================================
INSERT INTO dwh.dim_users (
    user_id, name, phone, tier, timezone, registered_at, valid_from, valid_to, is_current
)
SELECT
    u.id, u.name, u.phone, u.tier, u.timezone,
    u.created_at, u.created_at, NULL, 1
FROM oltp.users u
WHERE u.created_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.dim_users d
    WHERE d.user_id = u.id AND d.is_current = 1
);

SET @rows_users = @@ROWCOUNT;

-- =============================================
-- 2. CAMBIOS EN USUARIOS EXISTENTES (SCD Type 2)
-- Detecta usuarios que cambiaron de tier
-- =============================================

-- Cerrar version anterior
UPDATE dwh.dim_users
SET valid_to   = GETDATE(),
    is_current = 0
WHERE is_current = 1
  AND user_id IN (
    SELECT u.id
    FROM oltp.users u
    JOIN dwh.dim_users d ON d.user_id = u.id AND d.is_current = 1
    WHERE u.updated_at > @last_load_date
      AND u.tier != d.tier
);

-- Insertar nueva version
INSERT INTO dwh.dim_users (
    user_id, name, phone, tier, timezone, registered_at, valid_from, valid_to, is_current
)
SELECT
    u.id, u.name, u.phone, u.tier, u.timezone,
    u.created_at, GETDATE(), NULL, 1
FROM oltp.users u
WHERE u.updated_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.dim_users d
    WHERE d.user_id = u.id AND d.is_current = 1
);

-- =============================================
-- 3. NUEVOS EJERCICIOS
-- =============================================
INSERT INTO dwh.dim_exercises (
    exercise_id, name, muscle_group, movement_type, is_compound, valid_from, valid_to, is_current
)
SELECT
    e.id, e.name, mg.name, mt.name, e.is_compound,
    e.created_at, NULL, 1
FROM oltp.exercises e
JOIN oltp.muscle_groups mg  ON mg.id = e.muscle_group_id
JOIN oltp.movement_types mt ON mt.id = e.movement_type_id
WHERE e.created_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.dim_exercises d
    WHERE d.exercise_id = e.id AND d.is_current = 1
);

SET @rows_exercises = @@ROWCOUNT;

-- =============================================
-- 4. NUEVOS WORKOUTS
-- =============================================
INSERT INTO dwh.fact_workouts (
    user_key, date_key, workout_source_id, duration_min, total_sets, total_volume_kg
)
SELECT
    du.user_key,
    dt.date_key,
    w.id,
    w.duration_min,
    COUNT(ws.id),
    SUM(ws.reps * ws.weight_kg)
FROM oltp.workouts w
JOIN dwh.dim_users du
    ON du.user_id = w.user_id AND du.is_current = 1
JOIN dwh.dim_time dt
    ON dt.date_key = CAST(FORMAT(w.date, 'yyyyMMdd') AS INT)
LEFT JOIN oltp.workout_sets ws
    ON ws.workout_id = w.id
WHERE w.created_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.fact_workouts fw
    WHERE fw.workout_source_id = w.id
)
GROUP BY du.user_key, dt.date_key, w.id, w.duration_min;

SET @rows_workouts = @@ROWCOUNT;

-- =============================================
-- 5. NUEVOS SETS
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
WHERE ws.created_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.fact_sets fs
    WHERE fs.set_source_id = ws.id
);

SET @rows_sets = @@ROWCOUNT;

-- =============================================
-- 6. NUEVOS LLM LOGS
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
WHERE ll.parsed_at > @last_load_date
  AND NOT EXISTS (
    SELECT 1 FROM dwh.fact_llm_requests flr
    WHERE flr.log_source_id = ll.id
);

SET @rows_llm = @@ROWCOUNT;

-- =============================================
-- 7. Registrar en etl_control
-- =============================================
INSERT INTO dwh.etl_control (process_name, last_load_date, rows_inserted, status)
VALUES (
    'incremental_load',
    GETDATE(),
    @rows_users + @rows_exercises + @rows_workouts + @rows_sets + @rows_llm,
    'success'
);

-- Resumen
SELECT
    'incremental_load'  AS process,
    @rows_users         AS new_users,
    @rows_exercises     AS new_exercises,
    @rows_workouts      AS new_workouts,
    @rows_sets          AS new_sets,
    @rows_llm           AS new_llm_logs;
