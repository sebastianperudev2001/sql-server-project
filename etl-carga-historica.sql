USE FlexerDWH;
GO

-- =============================================
-- ETL CARGA HISTÓRICA - DIMENSIONES
-- =============================================

-- dim_users
INSERT INTO dwh.dim_users (
    user_id, name, phone, tier, timezone, registered_at, valid_from, valid_to, is_current
)
SELECT
    u.id,
    u.name,
    u.phone,
    u.tier,
    u.timezone,
    u.created_at,
    u.created_at,   -- valid_from = fecha de registro
    NULL,           -- valid_to = NULL (registro actual)
    1               -- is_current = true
FROM oltp.users u
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.dim_users d
    WHERE d.user_id = u.id AND d.is_current = 1
);

-- dim_exercises
INSERT INTO dwh.dim_exercises (
    exercise_id, name, muscle_group, movement_type, is_compound, valid_from, valid_to, is_current
)
SELECT
    e.id,
    e.name,
    mg.name,        -- desnormalizamos muscle_group
    mt.name,        -- desnormalizamos movement_type
    e.is_compound,
    e.created_at,
    NULL,
    1
FROM oltp.exercises e
JOIN oltp.muscle_groups mg ON mg.id = e.muscle_group_id
JOIN oltp.movement_types mt ON mt.id = e.movement_type_id
WHERE NOT EXISTS (
    SELECT 1 FROM dwh.dim_exercises d
    WHERE d.exercise_id = e.id AND d.is_current = 1
);

-- Verificacion
SELECT 'dim_users'     AS tabla, COUNT(*) AS registros FROM dwh.dim_users
UNION ALL
SELECT 'dim_exercises' AS tabla, COUNT(*) AS registros FROM dwh.dim_exercises
UNION ALL
SELECT 'dim_time'      AS tabla, COUNT(*) AS registros FROM dwh.dim_time;
