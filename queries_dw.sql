USE FlexerDWH;
GO

-- Limpieza DWH en orden
DROP TABLE IF EXISTS dwh.fact_sets;
DROP TABLE IF EXISTS dwh.fact_workouts;
DROP TABLE IF EXISTS dwh.fact_llm_requests;
DROP TABLE IF EXISTS dwh.dim_users;
DROP TABLE IF EXISTS dwh.dim_exercises;
DROP TABLE IF EXISTS dwh.dim_time;
GO

-- =============================================
-- DIMENSIONES
-- =============================================

CREATE TABLE dwh.dim_users (
    user_key        INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL,
    name            VARCHAR(100),
    phone           VARCHAR(20),
    tier            VARCHAR(10),
    timezone        VARCHAR(50),
    registered_at   DATETIME2,
    valid_from      DATETIME2 NOT NULL DEFAULT GETDATE(),
    valid_to        DATETIME2 NULL,
    is_current      BIT NOT NULL DEFAULT 1
);

CREATE TABLE dwh.dim_exercises (
    exercise_key    INT IDENTITY(1,1) PRIMARY KEY,
    exercise_id     INT NOT NULL,
    name            VARCHAR(100),
    muscle_group    VARCHAR(50),
    movement_type   VARCHAR(50),
    is_compound     BIT,
    valid_from      DATETIME2 NOT NULL DEFAULT GETDATE(),
    valid_to        DATETIME2 NULL,
    is_current      BIT NOT NULL DEFAULT 1
);

CREATE TABLE dwh.dim_time (
    date_key        INT PRIMARY KEY,
    date            DATE NOT NULL,
    day             INT,
    month           INT,
    year            INT,
    quarter         INT,
    week_of_year    INT,
    day_of_week     INT,
    day_name        VARCHAR(10),
    month_name      VARCHAR(10),
    is_weekend      BIT
);

-- =============================================
-- FACT TABLES
-- =============================================

CREATE TABLE dwh.fact_workouts (
    workout_key         INT IDENTITY(1,1) PRIMARY KEY,
    -- Foreign keys
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    -- Natural key para ETL
    workout_source_id   INT NOT NULL,
    -- Métricas
    duration_min        INT,
    total_sets          INT,
    total_volume_kg     DECIMAL(10,2),
    -- Auditoría
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_workouts_source UNIQUE (workout_source_id)
);

CREATE TABLE dwh.fact_sets (
    set_key             INT IDENTITY(1,1) PRIMARY KEY,
    -- Foreign keys
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    exercise_key        INT NOT NULL REFERENCES dwh.dim_exercises(exercise_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    -- Dimensión degenerada (sin tabla propia)
    workout_source_id   INT NOT NULL,
    -- Natural key para ETL
    set_source_id       INT NOT NULL,
    -- Atributo de agrupación (no sumable)
    set_number          INT,
    source              VARCHAR(20),
    -- Métricas
    reps                INT,
    weight_kg           DECIMAL(6,2),
    rpe                 DECIMAL(3,1),
    duration_sec        INT,
    volume_kg           AS (reps * weight_kg),
    -- Auditoría
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_sets_source UNIQUE (set_source_id)
);

CREATE TABLE dwh.fact_llm_requests (
    llm_request_key     INT IDENTITY(1,1) PRIMARY KEY,
    -- Foreign keys
    user_key            INT NOT NULL REFERENCES dwh.dim_users(user_key),
    date_key            INT NOT NULL REFERENCES dwh.dim_time(date_key),
    -- Natural key para ETL
    log_source_id       INT NOT NULL,
    -- Métricas
    parsed_ok           BIT,
    raw_input_length    INT,
    error_details       VARCHAR(500),
    -- Auditoría
    loaded_at           DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT UQ_fact_llm_source UNIQUE (log_source_id)
);