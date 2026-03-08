-- =============================================
-- Flexer DWH
-- 08_analytics_business.sql
-- Queries analiticos para el negocio (founder)
-- =============================================

USE FlexerDWH;
GO

-- =============================================
-- 1. RETENCION POR COHORTE
-- Usuarios activos en semana 1, 2, 4 y 8
-- desde su fecha de registro
-- =============================================

SELECT
    du.user_id,
    du.name,
    du.tier,
    CAST(du.registered_at AS DATE)                          AS registration_date,
    COUNT(DISTINCT fw.workout_source_id)                    AS total_workouts,
    MAX(dt.date)                                            AS last_workout_date,
    DATEDIFF(DAY, MAX(dt.date), CAST(GETDATE() AS DATE))    AS days_since_last_workout,
    MAX(CASE WHEN DATEDIFF(WEEK, du.registered_at, dt.date) = 1 THEN 1 ELSE 0 END) AS active_week1,
    MAX(CASE WHEN DATEDIFF(WEEK, du.registered_at, dt.date) = 2 THEN 1 ELSE 0 END) AS active_week2,
    MAX(CASE WHEN DATEDIFF(WEEK, du.registered_at, dt.date) = 4 THEN 1 ELSE 0 END) AS active_week4,
    MAX(CASE WHEN DATEDIFF(WEEK, du.registered_at, dt.date) = 8 THEN 1 ELSE 0 END) AS active_week8
FROM dwh.fact_workouts fw
JOIN dwh.dim_users du  ON du.user_key = fw.user_key
JOIN dwh.dim_time dt   ON dt.date_key = fw.date_key
GROUP BY du.user_id, du.name, du.tier, du.registered_at
ORDER BY du.registered_at;

-- =============================================
-- 2. TASA DE ERROR DEL LLM POR EJERCICIO
-- Que ejercicios generan mas errores de parseo
-- y cual es la longitud promedio del prompt
-- =============================================

SELECT
    de.name                                                     AS exercise,
    de.muscle_group,
    COUNT(flr.llm_request_key)                                  AS total_requests,
    SUM(CASE WHEN flr.parsed_ok = 0 THEN 1 ELSE 0 END)         AS failed_parses,
    ROUND(
        100.0 * SUM(CASE WHEN flr.parsed_ok = 0 THEN 1 ELSE 0 END)
        / COUNT(flr.llm_request_key), 2
    )                                                           AS error_rate_pct,
    AVG(flr.raw_input_length)                                   AS avg_input_length
FROM dwh.fact_llm_requests flr
JOIN dwh.dim_users du      ON du.user_key = flr.user_key
JOIN dwh.fact_sets fs      ON fs.user_key = flr.user_key
                          AND fs.date_key = flr.date_key
JOIN dwh.dim_exercises de  ON de.exercise_key = fs.exercise_key
GROUP BY de.exercise_key, de.name, de.muscle_group
HAVING COUNT(flr.llm_request_key) > 0
ORDER BY error_rate_pct DESC;

-- =============================================
-- 3. DISTRIBUCION DE USO POR DIA DE LA SEMANA
-- Que dias entrenan mas los usuarios
-- =============================================

SELECT
    dt.day_name,
    dt.day_of_week,
    COUNT(DISTINCT fw.workout_source_id)            AS total_workouts,
    COUNT(DISTINCT fw.user_key)                     AS unique_users,
    ROUND(AVG(CAST(fw.duration_min AS FLOAT)), 1)   AS avg_duration_min
FROM dwh.fact_workouts fw
JOIN dwh.dim_time dt   ON dt.date_key = fw.date_key
GROUP BY dt.day_name, dt.day_of_week
ORDER BY dt.day_of_week;

-- =============================================
-- 4. FUNNEL DE CONVERSION FREE -> PREMIUM
-- Distribucion de usuarios por tier con
-- engagement promedio por grupo
-- =============================================

SELECT
    du.tier,
    COUNT(DISTINCT du.user_key)                         AS total_users,
    AVG(CAST(fw_stats.total_workouts AS FLOAT))         AS avg_workouts_per_user,
    AVG(CAST(fw_stats.total_sets AS FLOAT))             AS avg_sets_per_user,
    ROUND(
        100.0 * COUNT(DISTINCT du.user_key)
        / SUM(COUNT(DISTINCT du.user_key)) OVER (), 2
    )                                                   AS pct_of_total
FROM dwh.dim_users du
JOIN (
    SELECT
        user_key,
        COUNT(DISTINCT workout_source_id)   AS total_workouts,
        SUM(total_sets)                     AS total_sets
    FROM dwh.fact_workouts
    GROUP BY user_key
) fw_stats ON fw_stats.user_key = du.user_key
WHERE du.is_current = 1
GROUP BY du.tier
ORDER BY du.tier;

-- =============================================
-- 5. DETECCION DE CHURN
-- Usuarios inactivos con clasificacion de riesgo
-- At Risk: inactivos > 7 dias
-- High Risk: inactivos > 14 dias
-- =============================================

SELECT
    du.user_id,
    du.name,
    du.tier,
    MAX(dt.date)                                            AS last_workout_date,
    DATEDIFF(DAY, MAX(dt.date), CAST(GETDATE() AS DATE))    AS days_inactive,
    COUNT(DISTINCT fw.workout_source_id)                    AS total_workouts,
    CASE
        WHEN DATEDIFF(DAY, MAX(dt.date), CAST(GETDATE() AS DATE)) > 14 THEN 'High Risk'
        WHEN DATEDIFF(DAY, MAX(dt.date), CAST(GETDATE() AS DATE)) > 7  THEN 'At Risk'
        ELSE 'Active'
    END                                                     AS churn_status
FROM dwh.fact_workouts fw
JOIN dwh.dim_users du  ON du.user_key = fw.user_key AND du.is_current = 1
JOIN dwh.dim_time dt   ON dt.date_key = fw.date_key
GROUP BY du.user_id, du.name, du.tier
ORDER BY days_inactive DESC;
