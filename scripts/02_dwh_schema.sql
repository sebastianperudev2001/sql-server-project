-- =============================================
-- Flexer DWH
-- 02_dwh_schema.sql
-- Modelo estrella (Star Schema - Kimball)
-- =============================================

USE FlexerDWH;
GO

-- Limpieza en orden (respetar FKs)
DROP TABLE IF EXISTS dwh.fact_sets;
DROP TABLE IF EXISTS dwh.fact_workouts;
DROP TABLE IF EXISTS dwh.fact_llm_requests;
DROP TABLE IF EXISTS dwh.dim_users;
DROP TABLE IF EXISTS dwh.dim_exercises;
DROP TABLE IF EXISTS dwh.dim_time;
DROP TABLE IF EXISTS dwh.etl_control;
GO

-- =============================================
-- DIMENSIONES
-- =============================================

-- SCD Type 2: valid_from, valid_to, is_current
-- permiten trackear cambios historicos
-- (ej: usuario pasa de free a premium)
CREATE TABLE dwh.dim_users (
    user_key        INT IDENTITY(1,1) PRIMARY KEY,  -- surrogate key
    user_id         INT NOT NULL,                    -- natural key del OLTP
    name            VARCHAR(100),
    phone           VARCHAR(20),
    tier            VARCHAR(10),
    timezone        VARCHAR(50),
    registered_at   DATETIME2,
    valid_from      DATETIME2 NOT NULL DEFAULT GETDATE(),
    valid_to        DATETIME2 NULL,
    is_current      BIT NOT NULL DEFAULT 1
);

-- SCD Type 2: permite trackear cambios en
-- grupo muscular o tipo de movimiento
CREATE TABLE dwh.dim_exercises (
    exercise_key    INT IDENTITY(1,1) PRIMARY KEY,
    exercise_id     INT NOT NULL,
    name            VARCHAR(100),
    muscle_group    VARCHAR(50),    -- desnormalizado desde oltp.muscle_groups
    movement_type   VARCHAR(50),    -- desnormalizado desde oltp.movement_types
    is_compound     BIT,
    valid_from      DATETIME2 NOT NULL DEFAULT GETDATE(),
    valid_to        DATETIME2 NULL,
    is_current      BIT NOT NULL DEFAULT 1
);

-- Calendario estatico 2024-2026
-- date_key como INT YYYYMMDD: best practice para indices particionados
CREATE TABLE dwh.dim_time (
    date_key        INT PRIMARY KEY,
    date            DATE NOT NULL,
    day             INT,
    month           INT,
    year            INT,
    quarter         INT,
    week_of_year    INT,
    day_of_week     INT,            -- 1=Sunday, 7=Saturday
    day_name        VARCHAR(10),
    month_name      VARCHAR(10),
    is_weekend      BIT
);

-- =============================================
-- FACT TABLES
-- =============================================

-- Grain: 1 row por entrenamiento
-- duration_min vive aqui (no en dim ni en fact_sets)
-- para evitar el problema de fan-out
CREATE TABLE dwh.fact_workouts (
    workout_key         INT IDENTITY(1,1) PRIMARY KEY,
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    workout_source_id   INT NOT NULL,               -- natural key para ETL
    duration_min        INT,
    total_sets          INT,
    total_volume_kg     DECIMAL(10,2),
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_workouts_source UNIQUE (workout_source_id)
);

-- Grain: 1 row por serie
-- workout_source_id como dimension degenerada
-- (no tiene tabla propia para evitar fan-out)
-- set_number es dimension degenerada: no sumable,
-- usar como atributo de agrupacion/filtro en BI
CREATE TABLE dwh.fact_sets (
    set_key             INT IDENTITY(1,1) PRIMARY KEY,
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    exercise_key        INT NOT NULL REFERENCES dwh.dim_exercises(exercise_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    workout_source_id   INT NOT NULL,               -- dimension degenerada
    set_source_id       INT NOT NULL,               -- natural key para ETL
    set_number          INT,                        -- dimension degenerada (no sumar)
    source              VARCHAR(20),                -- llm / manual / adjustment
    reps                INT,
    weight_kg           DECIMAL(6,2),
    rpe                 DECIMAL(3,1),
    duration_sec        INT,
    volume_kg           AS (reps * weight_kg),      -- columna calculada
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_sets_source UNIQUE (set_source_id)
);

-- Grain: 1 row por mensaje LLM
-- Diferenciador unico de Flexer: permite analizar
-- rendimiento del modelo de parseo de IA
CREATE TABLE dwh.fact_llm_requests (
    llm_request_key     INT IDENTITY(1,1) PRIMARY KEY,
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    log_source_id       INT NOT NULL,               -- natural key para ETL
    parsed_ok           BIT,
    raw_input_length    INT,
    error_details       VARCHAR(500),
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_llm_source UNIQUE (log_source_id)
);

-- =============================================
-- ETL CONTROL
-- Marca de agua para carga incremental
-- =============================================

CREATE TABLE dwh.etl_control (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    process_name    VARCHAR(100) NOT NULL,
    last_load_date  DATETIME2 NOT NULL,
    rows_inserted   INT DEFAULT 0,
    status          VARCHAR(20) DEFAULT 'success' CHECK (status IN ('success', 'failed')),
    executed_at     DATETIME2 DEFAULT GETDATE()
);
