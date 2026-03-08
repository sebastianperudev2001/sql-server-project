USE FlexerDWH;
GO

-- =============================================
-- ETL CARGA HISTÓRICA - FACT TABLES
-- =============================================

-- fact_workouts
INSERT INTO dwh.fact_workouts (
    user_key, date_key, workout_source_id, duration_min, total_sets, total_volume_kg
)
SELECT
    du.user_key,
    dt.date_key,
    w.id,
    w.duration_min,
    COUNT(ws.id)                        AS total_sets,
    SUM(ws.reps * ws.weight_kg)         AS total_volume_kg
FROM oltp.workouts w
JOIN dwh.dim_users du
    ON du.user_id = w.user_id AND du.is_current = 1
JOIN dwh.dim_time dt
    ON dt.date_key = CAST(FORMAT(w.date, 'yyyyMMdd') AS INT)
LEFT JOIN oltp.workout_sets ws
    ON ws.workout_id = w.id
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.fact_workouts fw
    WHERE fw.workout_source_id = w.id
)
GROUP BY du.user_key, dt.date_key, w.id, w.duration_min;

-- fact_sets
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
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.fact_sets fs
    WHERE fs.set_source_id = ws.id
);

-- fact_llm_requests
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
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.fact_llm_requests flr
    WHERE flr.log_source_id = ll.id
);

-- Verificacion
SELECT 'fact_workouts'     AS tabla, COUNT(*) AS registros FROM dwh.fact_workouts
UNION ALL
SELECT 'fact_sets'         AS tabla, COUNT(*) AS registros FROM dwh.fact_sets
UNION ALL
SELECT 'fact_llm_requests' AS tabla, COUNT(*) AS registros FROM dwh.fact_llm_requests;