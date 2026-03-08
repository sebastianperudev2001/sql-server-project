-- =============================================
-- Flexer DWH
-- 03_dim_time_populate.sql
-- Poblar dimension de tiempo 2024-2026
-- =============================================

USE FlexerDWH;
GO

DECLARE @start_date DATE = '2024-01-01';
DECLARE @end_date   DATE = '2026-12-31';
DECLARE @date       DATE = @start_date;

WHILE @date <= @end_date
BEGIN
    INSERT INTO dwh.dim_time (
        date_key,
        date,
        day,
        month,
        year,
        quarter,
        week_of_year,
        day_of_week,
        day_name,
        month_name,
        is_weekend
    )
    VALUES (
        CAST(FORMAT(@date, 'yyyyMMdd') AS INT),
        @date,
        DAY(@date),
        MONTH(@date),
        YEAR(@date),
        DATEPART(QUARTER, @date),
        DATEPART(WEEK, @date),
        DATEPART(WEEKDAY, @date),
        DATENAME(WEEKDAY, @date),
        DATENAME(MONTH, @date),
        CASE WHEN DATEPART(WEEKDAY, @date) IN (1, 7) THEN 1 ELSE 0 END
    );

    SET @date = DATEADD(DAY, 1, @date);
END;

-- Verificacion
SELECT
    COUNT(*)    AS total_days,
    MIN(date)   AS from_date,
    MAX(date)   AS to_date
FROM dwh.dim_time;
-- Esperado: 1096 days | 2024-01-01 | 2026-12-31
