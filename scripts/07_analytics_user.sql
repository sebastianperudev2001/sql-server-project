-- =============================================
-- Flexer DWH
-- 07_analytics_user.sql
-- Queries analiticos para usuarios premium
-- =============================================

USE FlexerDWH;
GO

-- =============================================
-- 1. PROGRESION DE FUERZA POR EJERCICIO
-- Peso maximo por semana con variacion
-- respecto a la semana anterior (LAG)
-- =============================================

SELECT
    du.name                                         AS user_name,
    de.name                                         AS exercise,
    dt.year,
    dt.week_of_year,
    MAX(fs.weight_kg)                               AS max_weight_kg,
    LAG(MAX(fs.weight_kg)) OVER (
        PARTITION BY du.user_key, de.exercise_key
        ORDER BY dt.year, dt.week_of_year
    )                                               AS prev_week_weight,
    MAX(fs.weight_kg) - LAG(MAX(fs.weight_kg)) OVER (
        PARTITION BY du.user_key, de.exercise_key
        ORDER BY dt.year, dt.week_of_year
    )                                               AS weight_delta_kg
FROM dwh.fact_sets fs
JOIN dwh.dim_users du      ON du.user_key = fs.user_key
JOIN dwh.dim_exercises de  ON de.exercise_key = fs.exercise_key
JOIN dwh.dim_time dt       ON dt.date_key = fs.date_key
WHERE fs.weight_kg IS NOT NULL
GROUP BY du.user_key, du.name, de.exercise_key, de.name, dt.year, dt.week_of_year
ORDER BY du.name, de.name, dt.year, dt.week_of_year;

-- =============================================
-- 2. VOLUMEN SEMANAL POR GRUPO MUSCULAR
-- Detecta desbalances push/pull por usuario
-- =============================================

SELECT
    du.name                                         AS user_name,
    dt.year,
    dt.week_of_year,
    de.muscle_group,
    de.movement_type,
    SUM(fs.volume_kg)                               AS total_volume_kg,
    COUNT(fs.set_key)                               AS total_sets
FROM dwh.fact_sets fs
JOIN dwh.dim_users du      ON du.user_key = fs.user_key
JOIN dwh.dim_exercises de  ON de.exercise_key = fs.exercise_key
JOIN dwh.dim_time dt       ON dt.date_key = fs.date_key
WHERE fs.volume_kg IS NOT NULL
GROUP BY du.user_key, du.name, dt.year, dt.week_of_year, de.muscle_group, de.movement_type
ORDER BY du.name, dt.year, dt.week_of_year, total_volume_kg DESC;

-- =============================================
-- 3. PRs AUTOMATICOS POR EJERCICIO
-- Maximo peso historico por usuario y ejercicio
-- =============================================

SELECT
    du.name                                         AS user_name,
    de.name                                         AS exercise,
    de.muscle_group,
    MAX(fs.weight_kg)                               AS pr_weight_kg,
    MAX(dt.date)                                    AS pr_date
FROM dwh.fact_sets fs
JOIN dwh.dim_users du      ON du.user_key = fs.user_key
JOIN dwh.dim_exercises de  ON de.exercise_key = fs.exercise_key
JOIN dwh.dim_time dt       ON dt.date_key = fs.date_key
WHERE fs.weight_kg IS NOT NULL
GROUP BY du.user_key, du.name, de.exercise_key, de.name, de.muscle_group
ORDER BY du.name, pr_weight_kg DESC;

-- =============================================
-- 4. SCORE DE CONSISTENCIA
-- Workouts por semana con promedio movil
-- de las ultimas 4 semanas
-- =============================================

SELECT
    du.name                                         AS user_name,
    dt.year,
    dt.week_of_year,
    COUNT(DISTINCT fw.workout_source_id)            AS workouts_this_week,
    AVG(COUNT(DISTINCT fw.workout_source_id)) OVER (
        PARTITION BY du.user_key
        ORDER BY dt.year, dt.week_of_year
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    )                                               AS avg_workouts_4w
FROM dwh.fact_workouts fw
JOIN dwh.dim_users du  ON du.user_key = fw.user_key
JOIN dwh.dim_time dt   ON dt.date_key = fw.date_key
GROUP BY du.user_key, du.name, dt.year, dt.week_of_year
ORDER BY du.name, dt.year, dt.week_of_year;

-- =============================================
-- 5. ESTIMACION DE 1RM
-- Formula Epley: weight * (1 + reps / 30)
-- Maximo 1RM estimado historico por ejercicio
-- =============================================

SELECT
    du.name                                             AS user_name,
    de.name                                             AS exercise,
    de.muscle_group,
    ROUND(MAX(fs.weight_kg * (1 + fs.reps / 30.0)), 2) AS estimated_1rm_kg,
    MAX(dt.date)                                        AS last_calculated
FROM dwh.fact_sets fs
JOIN dwh.dim_users du      ON du.user_key = fs.user_key
JOIN dwh.dim_exercises de  ON de.exercise_key = fs.exercise_key
JOIN dwh.dim_time dt       ON dt.date_key = fs.date_key
WHERE fs.weight_kg IS NOT NULL
  AND fs.reps IS NOT NULL
GROUP BY du.user_key, du.name, de.exercise_key, de.name, de.muscle_group
ORDER BY du.name, estimated_1rm_kg DESC;
