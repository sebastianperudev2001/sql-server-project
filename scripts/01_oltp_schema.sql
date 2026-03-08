-- =============================================
-- Flexer DWH
-- 01_oltp_schema.sql
-- Schema transaccional (OLTP) - 3NF estricta
-- =============================================

USE FlexerDWH;
GO

-- Limpieza en orden (respetar FKs)
DROP TABLE IF EXISTS oltp.workout_sets;
DROP TABLE IF EXISTS oltp.llm_logs;
DROP TABLE IF EXISTS oltp.workouts;
DROP TABLE IF EXISTS oltp.exercises;
DROP TABLE IF EXISTS oltp.users;
DROP TABLE IF EXISTS oltp.muscle_groups;
DROP TABLE IF EXISTS oltp.movement_types;
GO

-- =============================================
-- LOOKUP TABLES (catalogos de dominio)
-- =============================================

CREATE TABLE oltp.muscle_groups (
    id      INT IDENTITY(1,1) PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE oltp.movement_types (
    id      INT IDENTITY(1,1) PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE
);

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

CREATE TABLE oltp.users (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    phone       VARCHAR(20) NOT NULL UNIQUE,
    name        VARCHAR(100),
    tier        VARCHAR(10) DEFAULT 'free' CHECK (tier IN ('free', 'premium')),
    timezone    VARCHAR(50) DEFAULT 'America/Lima',
    created_at  DATETIME2 DEFAULT GETDATE(),
    updated_at  DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE oltp.exercises (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    muscle_group_id     INT NOT NULL REFERENCES oltp.muscle_groups(id),
    movement_type_id    INT NOT NULL REFERENCES oltp.movement_types(id),
    is_compound         BIT DEFAULT 1,
    created_at          DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE oltp.workouts (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES oltp.users(id),
    date            DATE NOT NULL,
    duration_min    INT,
    notes           VARCHAR(500),
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2 DEFAULT GETDATE()
);

-- Separado de workout_sets: el raw_input depende del
-- evento de parseo, no de la serie individual (3NF)
CREATE TABLE oltp.llm_logs (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    workout_id      INT NOT NULL REFERENCES oltp.workouts(id),
    raw_input       VARCHAR(500) NOT NULL,
    parsed_ok       BIT DEFAULT 1,
    error_details   VARCHAR(500),
    parsed_at       DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE oltp.workout_sets (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    log_id          INT NULL REFERENCES oltp.llm_logs(id),   -- NULL si ingreso manual
    workout_id      INT NOT NULL REFERENCES oltp.workouts(id),
    exercise_id     INT NOT NULL REFERENCES oltp.exercises(id),
    set_number      INT NOT NULL,
    reps            INT,
    weight_kg       DECIMAL(6,2),
    rpe             DECIMAL(3,1),
    duration_sec    INT,
    source          VARCHAR(20) DEFAULT 'llm' CHECK (source IN ('llm', 'manual', 'adjustment')),
    created_at      DATETIME2 DEFAULT GETDATE(),
    updated_at      DATETIME2 DEFAULT GETDATE(),

    -- Garantiza que no existan dos Set 1 del mismo ejercicio
    -- en el mismo entrenamiento. El set_number lo asigna la app
    -- consultando MAX(set_number) + 1
    CONSTRAINT UQ_Workout_Exercise_Set UNIQUE (workout_id, exercise_id, set_number)
);
