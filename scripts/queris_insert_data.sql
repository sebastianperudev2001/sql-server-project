USE FlexerDWH;
GO

-- =============================================
-- LOOKUP TABLES
-- =============================================

INSERT INTO oltp.muscle_groups (name) VALUES
('Chest'),
('Back'),
('Shoulders'),
('Biceps'),
('Triceps'),
('Legs'),
('Core'),
('Glutes');

INSERT INTO oltp.movement_types (name) VALUES
('Push'),
('Pull'),
('Hinge'),
('Squat'),
('Carry'),
('Isolation');

-- =============================================
-- EXERCISES
-- =============================================

INSERT INTO oltp.exercises (name, muscle_group_id, movement_type_id, is_compound) VALUES
('Bench Press',          1, 1, 1),  -- Chest / Push
('Overhead Press',       3, 1, 1),  -- Shoulders / Push
('Tricep Pushdown',      5, 6, 0),  -- Triceps / Isolation
('Pull Up',              2, 2, 1),  -- Back / Pull
('Barbell Row',          2, 2, 1),  -- Back / Pull
('Bicep Curl',           4, 6, 0),  -- Biceps / Isolation
('Squat',                6, 4, 1),  -- Legs / Squat
('Romanian Deadlift',    8, 3, 1),  -- Glutes / Hinge
('Deadlift',             2, 3, 1),  -- Back / Hinge
('Plank',                7, 5, 0);  -- Core / Carry

-- =============================================
-- USERS
-- =============================================

INSERT INTO oltp.users (phone, name, tier, timezone) VALUES
('+51987001001', 'Carlos Mendoza',  'premium', 'America/Lima'),
('+51987001002', 'Ana Torres',      'free',    'America/Lima'),
('+51987001003', 'Diego Quispe',    'free',    'America/Lima');


USE FlexerDWH;
GO

-- =============================================
-- WORKOUTS (8 semanas, 3 usuarios)
-- =============================================

-- Carlos (premium) - entrena 4x semana
INSERT INTO oltp.workouts (user_id, date, duration_min, notes) VALUES
(1, DATEADD(day, -54, CAST(GETDATE() AS DATE)), 65, 'Push day'),
(1, DATEADD(day, -52, CAST(GETDATE() AS DATE)), 70, 'Pull day'),
(1, DATEADD(day, -50, CAST(GETDATE() AS DATE)), 60, 'Leg day'),
(1, DATEADD(day, -47, CAST(GETDATE() AS DATE)), 68, 'Push day'),
(1, DATEADD(day, -45, CAST(GETDATE() AS DATE)), 72, 'Pull day'),
(1, DATEADD(day, -43, CAST(GETDATE() AS DATE)), 58, 'Leg day'),
(1, DATEADD(day, -40, CAST(GETDATE() AS DATE)), 66, 'Push day'),
(1, DATEADD(day, -38, CAST(GETDATE() AS DATE)), 71, 'Pull day'),
(1, DATEADD(day, -36, CAST(GETDATE() AS DATE)), 63, 'Leg day'),
(1, DATEADD(day, -33, CAST(GETDATE() AS DATE)), 69, 'Push day'),
(1, DATEADD(day, -31, CAST(GETDATE() AS DATE)), 74, 'Pull day'),
(1, DATEADD(day, -29, CAST(GETDATE() AS DATE)), 61, 'Leg day'),
(1, DATEADD(day, -26, CAST(GETDATE() AS DATE)), 67, 'Push day'),
(1, DATEADD(day, -24, CAST(GETDATE() AS DATE)), 73, 'Pull day'),
(1, DATEADD(day, -22, CAST(GETDATE() AS DATE)), 64, 'Leg day'),
(1, DATEADD(day, -19, CAST(GETDATE() AS DATE)), 70, 'Push day'),
(1, DATEADD(day, -17, CAST(GETDATE() AS DATE)), 75, 'Pull day'),
(1, DATEADD(day, -15, CAST(GETDATE() AS DATE)), 62, 'Leg day'),
(1, DATEADD(day, -12, CAST(GETDATE() AS DATE)), 68, 'Push day'),
(1, DATEADD(day, -10, CAST(GETDATE() AS DATE)), 72, 'Pull day'),
(1, DATEADD(day, -8,  CAST(GETDATE() AS DATE)), 65, 'Leg day'),
(1, DATEADD(day, -5,  CAST(GETDATE() AS DATE)), 71, 'Push day'),
(1, DATEADD(day, -3,  CAST(GETDATE() AS DATE)), 76, 'Pull day'),
(1, DATEADD(day, -1,  CAST(GETDATE() AS DATE)), 63, 'Leg day'),

-- Ana (free) - entrena 3x semana
(2, DATEADD(day, -54, CAST(GETDATE() AS DATE)), 50, NULL),
(2, DATEADD(day, -51, CAST(GETDATE() AS DATE)), 55, NULL),
(2, DATEADD(day, -48, CAST(GETDATE() AS DATE)), 48, NULL),
(2, DATEADD(day, -45, CAST(GETDATE() AS DATE)), 52, NULL),
(2, DATEADD(day, -42, CAST(GETDATE() AS DATE)), 57, NULL),
(2, DATEADD(day, -39, CAST(GETDATE() AS DATE)), 49, NULL),
(2, DATEADD(day, -36, CAST(GETDATE() AS DATE)), 53, NULL),
(2, DATEADD(day, -33, CAST(GETDATE() AS DATE)), 58, NULL),
(2, DATEADD(day, -30, CAST(GETDATE() AS DATE)), 51, NULL),
(2, DATEADD(day, -27, CAST(GETDATE() AS DATE)), 54, NULL),
(2, DATEADD(day, -24, CAST(GETDATE() AS DATE)), 59, NULL),
(2, DATEADD(day, -21, CAST(GETDATE() AS DATE)), 50, NULL),
(2, DATEADD(day, -18, CAST(GETDATE() AS DATE)), 55, NULL),
(2, DATEADD(day, -15, CAST(GETDATE() AS DATE)), 60, NULL),
(2, DATEADD(day, -12, CAST(GETDATE() AS DATE)), 52, NULL),
(2, DATEADD(day, -9,  CAST(GETDATE() AS DATE)), 56, NULL),
(2, DATEADD(day, -6,  CAST(GETDATE() AS DATE)), 61, NULL),
(2, DATEADD(day, -3,  CAST(GETDATE() AS DATE)), 53, NULL),

-- Diego (free) - entrena irregular, simulamos churn (inactivo últimas 2 semanas)
(3, DATEADD(day, -54, CAST(GETDATE() AS DATE)), 45, NULL),
(3, DATEADD(day, -50, CAST(GETDATE() AS DATE)), 48, NULL),
(3, DATEADD(day, -46, CAST(GETDATE() AS DATE)), 42, NULL),
(3, DATEADD(day, -40, CAST(GETDATE() AS DATE)), 50, NULL),
(3, DATEADD(day, -35, CAST(GETDATE() AS DATE)), 44, NULL),
(3, DATEADD(day, -28, CAST(GETDATE() AS DATE)), 47, NULL),
(3, DATEADD(day, -22, CAST(GETDATE() AS DATE)), 43, NULL),
(3, DATEADD(day, -18, CAST(GETDATE() AS DATE)), 46, NULL);

USE FlexerDWH;
GO

-- =============================================
-- LLM LOGS
-- Carlos (workout_ids 1-24), Ana (25-42), Diego (43-50)
-- =============================================

-- Carlos push days (workouts 1,4,7,10,13,16,19,22) - Bench Press + OHP + Triceps
INSERT INTO oltp.llm_logs (workout_id, raw_input, parsed_ok, error_details) VALUES
(1,  'bench press 4x10 70kg',           1, NULL),
(1,  'overhead press 3x10 40kg',        1, NULL),
(1,  'tricep pushdown 3x12 25kg',       1, NULL),
(4,  'bench press 4x10 72.5kg',         1, NULL),
(4,  'overhead press 3x10 42kg',        1, NULL),
(4,  'tricep pushdown 3x12 27kg',       1, NULL),
(7,  'bench 4x10 75',                   1, NULL),  -- abreviado, parseado ok
(7,  'overhead press 3x10 42kg',        1, NULL),
(7,  'tricep pushdown 3x12 27kg',       1, NULL),
(10, 'bench press 4x10 75kg',           1, NULL),
(10, 'overhead press 3x10 45kg',        1, NULL),
(10, 'tricep pushdown 3x12 30kg',       1, NULL),
(13, 'bench press 410 77.5kg',          0, 'Could not parse sets/reps: "410" ambiguous'),  -- ERROR
(13, 'overhead press 3x10 45kg',        1, NULL),
(13, 'tricep pushdown 3x12 30kg',       1, NULL),
(16, 'bench press 4x10 77.5kg',         1, NULL),
(16, 'overhead press 3x10 47kg',        1, NULL),
(16, 'tricep pushdown 3x12 32kg',       1, NULL),
(19, 'bench press 4x10 80kg',           1, NULL),
(19, 'overhead press 3x10 47kg',        1, NULL),
(19, 'tricep 3x12 32kg',                1, NULL),
(22, 'bench press 4x10 80kg',           1, NULL),
(22, 'overhead press 3x10 50kg',        1, NULL),
(22, 'tricep pushdown 3x12 35kg',       1, NULL),

-- Carlos pull days (workouts 2,5,8,11,14,17,20,23) - Pull Up + Barbell Row + Bicep Curl
(2,  'pull ups 3x8',                    1, NULL),
(2,  'barbell row 4x8 60kg',            1, NULL),
(2,  'bicep curl 3x12 15kg',            1, NULL),
(5,  'pull ups 3x8',                    1, NULL),
(5,  'barbell row 4x8 62.5kg',          1, NULL),
(5,  'bicep curl 3x12 15kg',            1, NULL),
(8,  'pull ups 3x9',                    1, NULL),
(8,  'barbell row 4x8 62.5kg',          1, NULL),
(8,  'bicep curl 3x12 17kg',            1, NULL),
(11, 'pull ups 3x9',                    1, NULL),
(11, 'barbell row 48 65kg',             0, 'Could not parse sets/reps: "48" ambiguous'),  -- ERROR
(11, 'bicep curl 3x12 17kg',            1, NULL),
(14, 'pull ups 3x10',                   1, NULL),
(14, 'barbell row 4x8 65kg',            1, NULL),
(14, 'bicep curl 3x12 20kg',            1, NULL),
(17, 'pull ups 3x10',                   1, NULL),
(17, 'barbell row 4x8 67.5kg',          1, NULL),
(17, 'bicep curl 3x12 20kg',            1, NULL),
(20, 'pull ups 4x10',                   1, NULL),
(20, 'barbell row 4x8 67.5kg',          1, NULL),
(20, 'bicep curl 3x12 22kg',            1, NULL),
(23, 'pull ups 4x10',                   1, NULL),
(23, 'barbell row 4x8 70kg',            1, NULL),
(23, 'bicep curl 3x12 22kg',            1, NULL),

-- Carlos leg days (workouts 3,6,9,12,15,18,21,24) - Squat + RDL
(3,  'squat 4x8 80kg',                  1, NULL),
(3,  'romanian deadlift 3x10 60kg',     1, NULL),
(6,  'squat 4x8 82.5kg',               1, NULL),
(6,  'romanian deadlift 3x10 62.5kg',  1, NULL),
(9,  'squat 4x8 85kg',                  1, NULL),
(9,  'romanian deadlift 3x10 65kg',     1, NULL),
(12, 'squat 4x8 87.5kg',               1, NULL),
(12, 'romanian deadlift 3x10 65kg',    1, NULL),
(15, 'squat 4x8 90kg',                  1, NULL),
(15, 'rdl 3x10 67.5kg',                1, NULL),
(18, 'squat 4x8 90kg',                  1, NULL),
(18, 'romanian deadlift 3x10 70kg',    1, NULL),
(21, 'squat 4x8 92.5kg',               1, NULL),
(21, 'romanian deadlift 3x10 70kg',    1, NULL),
(24, 'squat 4x10 92.5kg',              1, NULL),
(24, 'romanian deadlift 3x10 72.5kg',  1, NULL),

-- Ana (workouts 25-42) - full body, ejercicios básicos
(25, 'squat 3x10 40kg',                 1, NULL),
(25, 'bench press 3x10 30kg',           1, NULL),
(28, 'squat 3x10 42kg',                 1, NULL),
(28, 'bench press 3x10 30kg',           1, NULL),
(31, 'squat 3x10 42kg',                 1, NULL),
(31, 'bench press 310 32kg',            0, 'Could not parse sets/reps: "310" ambiguous'),  -- ERROR
(34, 'squat 3x10 45kg',                 1, NULL),
(34, 'bench press 3x10 32kg',           1, NULL),
(37, 'squat 3x10 45kg',                 1, NULL),
(37, 'bench press 3x10 35kg',           1, NULL),
(40, 'squat 3x10 47kg',                 1, NULL),
(40, 'bench press 3x10 35kg',           1, NULL),

-- Diego (workouts 43-50) - inconsistente
(43, 'bench press 3x10 60kg',           1, NULL),
(45, 'squat 3x8 70kg',                  1, NULL),
(47, 'deadlift 3x5 100kg',              1, NULL),
(49, 'bench press 3x10 60kg',           1, NULL);


USE FlexerDWH;
GO

-- =============================================
-- WORKOUT SETS - Carlos Push Days
-- Bench Press (exercise_id=1), OHP (2), Tricep (3)
-- =============================================

-- Workout 1 - Bench Press (log_id=1), OHP (log_id=2), Triceps (log_id=3)
INSERT INTO oltp.workout_sets (log_id, workout_id, exercise_id, set_number, reps, weight_kg, rpe, source) VALUES
(1, 1, 1, 1, 10, 70, 7.0, 'llm'),
(1, 1, 1, 2, 10, 70, 7.5, 'llm'),
(1, 1, 1, 3, 10, 70, 8.0, 'llm'),
(1, 1, 1, 4, 10, 70, 8.5, 'llm'),
(2, 1, 2, 1, 10, 40, 7.0, 'llm'),
(2, 1, 2, 2, 10, 40, 7.5, 'llm'),
(2, 1, 2, 3, 10, 40, 8.0, 'llm'),
(3, 1, 3, 1, 12, 25, 7.0, 'llm'),
(3, 1, 3, 2, 12, 25, 7.5, 'llm'),
(3, 1, 3, 3, 12, 25, 8.0, 'llm'),

-- Workout 4 - Bench Press (log_id=4), OHP (log_id=5), Triceps (log_id=6)
(4, 4, 1, 1, 10, 72.5, 7.0, 'llm'),
(4, 4, 1, 2, 10, 72.5, 7.5, 'llm'),
(4, 4, 1, 3, 10, 72.5, 8.0, 'llm'),
(4, 4, 1, 4, 10, 72.5, 8.5, 'llm'),
(5, 4, 2, 1, 10, 42, 7.0, 'llm'),
(5, 4, 2, 2, 10, 42, 7.5, 'llm'),
(5, 4, 2, 3, 10, 42, 8.0, 'llm'),
(6, 4, 3, 1, 12, 27, 7.0, 'llm'),
(6, 4, 3, 2, 12, 27, 7.5, 'llm'),
(6, 4, 3, 3, 12, 27, 8.0, 'llm'),

-- Workout 7 - Bench Press (log_id=7), OHP (log_id=8), Triceps (log_id=9)
(7, 7, 1, 1, 10, 75, 7.0, 'llm'),
(7, 7, 1, 2, 10, 75, 7.5, 'llm'),
(7, 7, 1, 3, 10, 75, 8.0, 'llm'),
(7, 7, 1, 4, 10, 75, 8.5, 'llm'),
(8, 7, 2, 1, 10, 42, 7.0, 'llm'),
(8, 7, 2, 2, 10, 42, 7.5, 'llm'),
(8, 7, 2, 3, 10, 42, 8.0, 'llm'),
(9, 7, 3, 1, 12, 27, 7.0, 'llm'),
(9, 7, 3, 2, 12, 27, 7.5, 'llm'),
(9, 7, 3, 3, 12, 27, 8.0, 'llm'),

-- Workout 10 - Bench Press (log_id=10), OHP (log_id=11), Triceps (log_id=12)
(10, 10, 1, 1, 10, 75, 7.5, 'llm'),
(10, 10, 1, 2, 10, 75, 8.0, 'llm'),
(10, 10, 1, 3, 10, 75, 8.0, 'llm'),
(10, 10, 1, 4, 10, 75, 8.5, 'llm'),
(11, 10, 2, 1, 10, 45, 7.0, 'llm'),
(11, 10, 2, 2, 10, 45, 7.5, 'llm'),
(11, 10, 2, 3, 10, 45, 8.0, 'llm'),
(12, 10, 3, 1, 12, 30, 7.0, 'llm'),
(12, 10, 3, 2, 12, 30, 7.5, 'llm'),
(12, 10, 3, 3, 12, 30, 8.0, 'llm'),

-- Workout 13 - OHP (log_id=14), Triceps (log_id=15)
-- log_id=13 parsed_ok=0, insertamos bench manualmente como adjustment
(NULL, 13, 1, 1, 10, 77.5, 7.5, 'adjustment'),
(NULL, 13, 1, 2, 10, 77.5, 8.0, 'adjustment'),
(NULL, 13, 1, 3, 10, 77.5, 8.0, 'adjustment'),
(NULL, 13, 1, 4, 10, 77.5, 8.5, 'adjustment'),
(14, 13, 2, 1, 10, 45, 7.0, 'llm'),
(14, 13, 2, 2, 10, 45, 7.5, 'llm'),
(14, 13, 2, 3, 10, 45, 8.0, 'llm'),
(15, 13, 3, 1, 12, 30, 7.0, 'llm'),
(15, 13, 3, 2, 12, 30, 7.5, 'llm'),
(15, 13, 3, 3, 12, 30, 8.0, 'llm'),

-- Workout 16 - Bench Press (log_id=16), OHP (log_id=17), Triceps (log_id=18)
(16, 16, 1, 1, 10, 77.5, 7.5, 'llm'),
(16, 16, 1, 2, 10, 77.5, 8.0, 'llm'),
(16, 16, 1, 3, 10, 77.5, 8.0, 'llm'),
(16, 16, 1, 4, 10, 77.5, 8.5, 'llm'),
(17, 16, 2, 1, 10, 47, 7.0, 'llm'),
(17, 16, 2, 2, 10, 47, 7.5, 'llm'),
(17, 16, 2, 3, 10, 47, 8.0, 'llm'),
(18, 16, 3, 1, 12, 32, 7.0, 'llm'),
(18, 16, 3, 2, 12, 32, 7.5, 'llm'),
(18, 16, 3, 3, 12, 32, 8.0, 'llm'),

-- Workout 19 - Bench Press (log_id=19), OHP (log_id=20), Triceps (log_id=21)
(19, 19, 1, 1, 10, 80, 8.0, 'llm'),
(19, 19, 1, 2, 10, 80, 8.0, 'llm'),
(19, 19, 1, 3, 10, 80, 8.5, 'llm'),
(19, 19, 1, 4, 10, 80, 9.0, 'llm'),
(20, 19, 2, 1, 10, 47, 7.5, 'llm'),
(20, 19, 2, 2, 10, 47, 8.0, 'llm'),
(20, 19, 2, 3, 10, 47, 8.0, 'llm'),
(21, 19, 3, 1, 12, 32, 7.5, 'llm'),
(21, 19, 3, 2, 12, 32, 8.0, 'llm'),
(21, 19, 3, 3, 12, 32, 8.0, 'llm'),

-- Workout 22 - Bench Press (log_id=22), OHP (log_id=23), Triceps (log_id=24)
(22, 22, 1, 1, 10, 80, 8.0, 'llm'),
(22, 22, 1, 2, 10, 80, 8.0, 'llm'),
(22, 22, 1, 3, 10, 80, 8.5, 'llm'),
(22, 22, 1, 4, 10, 80, 9.0, 'llm'),
(23, 22, 2, 1, 10, 50, 7.5, 'llm'),
(23, 22, 2, 2, 10, 50, 8.0, 'llm'),
(23, 22, 2, 3, 10, 50, 8.5, 'llm'),
(24, 22, 3, 1, 12, 35, 7.5, 'llm'),
(24, 22, 3, 2, 12, 35, 8.0, 'llm'),
(24, 22, 3, 3, 12, 35, 8.0, 'llm');


USE FlexerDWH;
GO

-- =============================================
-- WORKOUT SETS - Carlos Pull Days
-- Pull Up (4), Barbell Row (5), Bicep Curl (6)
-- =============================================

INSERT INTO oltp.workout_sets (log_id, workout_id, exercise_id, set_number, reps, weight_kg, rpe, source) VALUES
-- Workout 2 (log_ids 25,26,27)
(25, 2, 4, 1, 8, NULL, 7.0, 'llm'),
(25, 2, 4, 2, 8, NULL, 7.5, 'llm'),
(25, 2, 4, 3, 8, NULL, 8.0, 'llm'),
(26, 2, 5, 1, 8, 60, 7.0, 'llm'),
(26, 2, 5, 2, 8, 60, 7.5, 'llm'),
(26, 2, 5, 3, 8, 60, 8.0, 'llm'),
(26, 2, 5, 4, 8, 60, 8.5, 'llm'),
(27, 2, 6, 1, 12, 15, 7.0, 'llm'),
(27, 2, 6, 2, 12, 15, 7.5, 'llm'),
(27, 2, 6, 3, 12, 15, 8.0, 'llm'),

-- Workout 5 (log_ids 28,29,30)
(28, 5, 4, 1, 8, NULL, 7.5, 'llm'),
(28, 5, 4, 2, 8, NULL, 8.0, 'llm'),
(28, 5, 4, 3, 8, NULL, 8.0, 'llm'),
(29, 5, 5, 1, 8, 62.5, 7.0, 'llm'),
(29, 5, 5, 2, 8, 62.5, 7.5, 'llm'),
(29, 5, 5, 3, 8, 62.5, 8.0, 'llm'),
(29, 5, 5, 4, 8, 62.5, 8.5, 'llm'),
(30, 5, 6, 1, 12, 15, 7.0, 'llm'),
(30, 5, 6, 2, 12, 15, 7.5, 'llm'),
(30, 5, 6, 3, 12, 15, 8.0, 'llm'),

-- Workout 8 (log_ids 31,32,33)
(31, 8, 4, 1, 9, NULL, 7.5, 'llm'),
(31, 8, 4, 2, 9, NULL, 8.0, 'llm'),
(31, 8, 4, 3, 9, NULL, 8.5, 'llm'),
(32, 8, 5, 1, 8, 62.5, 7.5, 'llm'),
(32, 8, 5, 2, 8, 62.5, 8.0, 'llm'),
(32, 8, 5, 3, 8, 62.5, 8.0, 'llm'),
(32, 8, 5, 4, 8, 62.5, 8.5, 'llm'),
(33, 8, 6, 1, 12, 17, 7.0, 'llm'),
(33, 8, 6, 2, 12, 17, 7.5, 'llm'),
(33, 8, 6, 3, 12, 17, 8.0, 'llm'),

-- Workout 11 (log_ids 34,35,36) - barbell row log_id=35 parsed_ok=0, adjustment
(34, 11, 4, 1, 9, NULL, 7.5, 'llm'),
(34, 11, 4, 2, 9, NULL, 8.0, 'llm'),
(34, 11, 4, 3, 9, NULL, 8.5, 'llm'),
(NULL, 11, 5, 1, 8, 65, 7.5, 'adjustment'),
(NULL, 11, 5, 2, 8, 65, 8.0, 'adjustment'),
(NULL, 11, 5, 3, 8, 65, 8.0, 'adjustment'),
(NULL, 11, 5, 4, 8, 65, 8.5, 'adjustment'),
(36, 11, 6, 1, 12, 17, 7.0, 'llm'),
(36, 11, 6, 2, 12, 17, 7.5, 'llm'),
(36, 11, 6, 3, 12, 17, 8.0, 'llm'),

-- Workout 14 (log_ids 37,38,39)
(37, 14, 4, 1, 10, NULL, 7.5, 'llm'),
(37, 14, 4, 2, 10, NULL, 8.0, 'llm'),
(37, 14, 4, 3, 10, NULL, 8.0, 'llm'),
(38, 14, 5, 1, 8, 65, 7.5, 'llm'),
(38, 14, 5, 2, 8, 65, 8.0, 'llm'),
(38, 14, 5, 3, 8, 65, 8.0, 'llm'),
(38, 14, 5, 4, 8, 65, 8.5, 'llm'),
(39, 14, 6, 1, 12, 20, 7.0, 'llm'),
(39, 14, 6, 2, 12, 20, 7.5, 'llm'),
(39, 14, 6, 3, 12, 20, 8.0, 'llm'),

-- Workout 17 (log_ids 40,41,42)
(40, 17, 4, 1, 10, NULL, 8.0, 'llm'),
(40, 17, 4, 2, 10, NULL, 8.0, 'llm'),
(40, 17, 4, 3, 10, NULL, 8.5, 'llm'),
(41, 17, 5, 1, 8, 67.5, 7.5, 'llm'),
(41, 17, 5, 2, 8, 67.5, 8.0, 'llm'),
(41, 17, 5, 3, 8, 67.5, 8.0, 'llm'),
(41, 17, 5, 4, 8, 67.5, 8.5, 'llm'),
(42, 17, 6, 1, 12, 20, 7.5, 'llm'),
(42, 17, 6, 2, 12, 20, 8.0, 'llm'),
(42, 17, 6, 3, 12, 20, 8.0, 'llm'),

-- Workout 20 (log_ids 43,44,45)
(43, 20, 4, 1, 10, NULL, 8.0, 'llm'),
(43, 20, 4, 2, 10, NULL, 8.0, 'llm'),
(43, 20, 4, 3, 10, NULL, 8.5, 'llm'),
(43, 20, 4, 4, 10, NULL, 9.0, 'llm'),
(44, 20, 5, 1, 8, 67.5, 8.0, 'llm'),
(44, 20, 5, 2, 8, 67.5, 8.0, 'llm'),
(44, 20, 5, 3, 8, 67.5, 8.5, 'llm'),
(44, 20, 5, 4, 8, 67.5, 8.5, 'llm'),
(45, 20, 6, 1, 12, 22, 7.5, 'llm'),
(45, 20, 6, 2, 12, 22, 8.0, 'llm'),
(45, 20, 6, 3, 12, 22, 8.0, 'llm'),

-- Workout 23 (log_ids 46,47,48)
(46, 23, 4, 1, 10, NULL, 8.0, 'llm'),
(46, 23, 4, 2, 10, NULL, 8.5, 'llm'),
(46, 23, 4, 3, 10, NULL, 8.5, 'llm'),
(46, 23, 4, 4, 10, NULL, 9.0, 'llm'),
(47, 23, 5, 1, 8, 70, 8.0, 'llm'),
(47, 23, 5, 2, 8, 70, 8.0, 'llm'),
(47, 23, 5, 3, 8, 70, 8.5, 'llm'),
(47, 23, 5, 4, 8, 70, 8.5, 'llm'),
(48, 23, 6, 1, 12, 22, 8.0, 'llm'),
(48, 23, 6, 2, 12, 22, 8.0, 'llm'),
(48, 23, 6, 3, 12, 22, 8.5, 'llm');

USE FlexerDWH;
GO

-- =============================================
-- WORKOUT SETS - Carlos Leg Days
-- Squat (7), Romanian Deadlift (8)
-- =============================================

INSERT INTO oltp.workout_sets (log_id, workout_id, exercise_id, set_number, reps, weight_kg, rpe, source) VALUES
-- Workout 3 (log_ids 49,50)
(49, 3, 7, 1, 8, 80, 7.0, 'llm'),
(49, 3, 7, 2, 8, 80, 7.5, 'llm'),
(49, 3, 7, 3, 8, 80, 8.0, 'llm'),
(49, 3, 7, 4, 8, 80, 8.5, 'llm'),
(50, 3, 8, 1, 10, 60, 7.0, 'llm'),
(50, 3, 8, 2, 10, 60, 7.5, 'llm'),
(50, 3, 8, 3, 10, 60, 8.0, 'llm'),

-- Workout 6 (log_ids 51,52)
(51, 6, 7, 1, 8, 82.5, 7.0, 'llm'),
(51, 6, 7, 2, 8, 82.5, 7.5, 'llm'),
(51, 6, 7, 3, 8, 82.5, 8.0, 'llm'),
(51, 6, 7, 4, 8, 82.5, 8.5, 'llm'),
(52, 6, 8, 1, 10, 62.5, 7.0, 'llm'),
(52, 6, 8, 2, 10, 62.5, 7.5, 'llm'),
(52, 6, 8, 3, 10, 62.5, 8.0, 'llm'),

-- Workout 9 (log_ids 53,54)
(53, 9, 7, 1, 8, 85, 7.5, 'llm'),
(53, 9, 7, 2, 8, 85, 8.0, 'llm'),
(53, 9, 7, 3, 8, 85, 8.0, 'llm'),
(53, 9, 7, 4, 8, 85, 8.5, 'llm'),
(54, 9, 8, 1, 10, 65, 7.0, 'llm'),
(54, 9, 8, 2, 10, 65, 7.5, 'llm'),
(54, 9, 8, 3, 10, 65, 8.0, 'llm'),

-- Workout 12 (log_ids 55,56)
(55, 12, 7, 1, 8, 87.5, 7.5, 'llm'),
(55, 12, 7, 2, 8, 87.5, 8.0, 'llm'),
(55, 12, 7, 3, 8, 87.5, 8.0, 'llm'),
(55, 12, 7, 4, 8, 87.5, 8.5, 'llm'),
(56, 12, 8, 1, 10, 65, 7.5, 'llm'),
(56, 12, 8, 2, 10, 65, 8.0, 'llm'),
(56, 12, 8, 3, 10, 65, 8.0, 'llm'),

-- Workout 15 (log_ids 57,58)
(57, 15, 7, 1, 8, 90, 8.0, 'llm'),
(57, 15, 7, 2, 8, 90, 8.0, 'llm'),
(57, 15, 7, 3, 8, 90, 8.5, 'llm'),
(57, 15, 7, 4, 8, 90, 9.0, 'llm'),
(58, 15, 8, 1, 10, 67.5, 7.5, 'llm'),
(58, 15, 8, 2, 10, 67.5, 8.0, 'llm'),
(58, 15, 8, 3, 10, 67.5, 8.0, 'llm'),

-- Workout 18 (log_ids 59,60)
(59, 18, 7, 1, 8, 90, 8.0, 'llm'),
(59, 18, 7, 2, 8, 90, 8.0, 'llm'),
(59, 18, 7, 3, 8, 90, 8.5, 'llm'),
(59, 18, 7, 4, 8, 90, 9.0, 'llm'),
(60, 18, 8, 1, 10, 70, 7.5, 'llm'),
(60, 18, 8, 2, 10, 70, 8.0, 'llm'),
(60, 18, 8, 3, 10, 70, 8.0, 'llm'),

-- Workout 21 (log_ids 61,62)
(61, 21, 7, 1, 8, 92.5, 8.0, 'llm'),
(61, 21, 7, 2, 8, 92.5, 8.5, 'llm'),
(61, 21, 7, 3, 8, 92.5, 8.5, 'llm'),
(61, 21, 7, 4, 8, 92.5, 9.0, 'llm'),
(62, 21, 8, 1, 10, 70, 8.0, 'llm'),
(62, 21, 8, 2, 10, 70, 8.0, 'llm'),
(62, 21, 8, 3, 10, 70, 8.5, 'llm'),

-- Workout 24 (log_ids 63,64)
(63, 24, 7, 1, 10, 92.5, 8.0, 'llm'),
(63, 24, 7, 2, 10, 92.5, 8.5, 'llm'),
(63, 24, 7, 3, 10, 92.5, 8.5, 'llm'),
(63, 24, 7, 4, 10, 92.5, 9.0, 'llm'),
(64, 24, 8, 1, 10, 72.5, 8.0, 'llm'),
(64, 24, 8, 2, 10, 72.5, 8.0, 'llm'),
(64, 24, 8, 3, 10, 72.5, 8.5, 'llm'),

-- =============================================
-- WORKOUT SETS - Ana
-- Squat (7), Bench Press (1)
-- =============================================

-- Workout 25 (log_ids 65,66)
(65, 25, 7, 1, 10, 40, 7.0, 'llm'),
(65, 25, 7, 2, 10, 40, 7.5, 'llm'),
(65, 25, 7, 3, 10, 40, 8.0, 'llm'),
(66, 25, 1, 1, 10, 30, 7.0, 'llm'),
(66, 25, 1, 2, 10, 30, 7.5, 'llm'),
(66, 25, 1, 3, 10, 30, 8.0, 'llm'),

-- Workout 28 (log_ids 67,68)
(67, 28, 7, 1, 10, 42, 7.0, 'llm'),
(67, 28, 7, 2, 10, 42, 7.5, 'llm'),
(67, 28, 7, 3, 10, 42, 8.0, 'llm'),
(68, 28, 1, 1, 10, 30, 7.0, 'llm'),
(68, 28, 1, 2, 10, 30, 7.5, 'llm'),
(68, 28, 1, 3, 10, 30, 8.0, 'llm'),

-- Workout 31 (log_ids 69,70) - bench log_id=70 parsed_ok=0, adjustment
(69, 31, 7, 1, 10, 42, 7.5, 'llm'),
(69, 31, 7, 2, 10, 42, 8.0, 'llm'),
(69, 31, 7, 3, 10, 42, 8.0, 'llm'),
(NULL, 31, 1, 1, 10, 32, 7.0, 'adjustment'),
(NULL, 31, 1, 2, 10, 32, 7.5, 'adjustment'),
(NULL, 31, 1, 3, 10, 32, 8.0, 'adjustment'),

-- Workout 34 (log_ids 71,72)
(71, 34, 7, 1, 10, 45, 7.5, 'llm'),
(71, 34, 7, 2, 10, 45, 8.0, 'llm'),
(71, 34, 7, 3, 10, 45, 8.0, 'llm'),
(72, 34, 1, 1, 10, 32, 7.0, 'llm'),
(72, 34, 1, 2, 10, 32, 7.5, 'llm'),
(72, 34, 1, 3, 10, 32, 8.0, 'llm'),

-- Workout 37 (log_ids 73,74)
(73, 37, 7, 1, 10, 45, 8.0, 'llm'),
(73, 37, 7, 2, 10, 45, 8.0, 'llm'),
(73, 37, 7, 3, 10, 45, 8.5, 'llm'),
(74, 37, 1, 1, 10, 35, 7.5, 'llm'),
(74, 37, 1, 2, 10, 35, 8.0, 'llm'),
(74, 37, 1, 3, 10, 35, 8.0, 'llm'),

-- Workout 40 (log_ids 75,76)
(75, 40, 7, 1, 10, 47, 8.0, 'llm'),
(75, 40, 7, 2, 10, 47, 8.0, 'llm'),
(75, 40, 7, 3, 10, 47, 8.5, 'llm'),
(76, 40, 1, 1, 10, 35, 8.0, 'llm'),
(76, 40, 1, 2, 10, 35, 8.0, 'llm'),
(76, 40, 1, 3, 10, 35, 8.5, 'llm'),

-- =============================================
-- WORKOUT SETS - Diego
-- Bench Press (1), Squat (7), Deadlift (9)
-- =============================================

-- Workout 43 (log_id 77)
(77, 43, 1, 1, 10, 60, 7.0, 'llm'),
(77, 43, 1, 2, 10, 60, 7.5, 'llm'),
(77, 43, 1, 3, 10, 60, 8.0, 'llm'),

-- Workout 45 (log_id 78)
(78, 45, 7, 1, 8, 70, 7.5, 'llm'),
(78, 45, 7, 2, 8, 70, 8.0, 'llm'),
(78, 45, 7, 3, 8, 70, 8.0, 'llm'),

-- Workout 47 (log_id 79)
(79, 47, 9, 1, 5, 100, 8.0, 'llm'),
(79, 47, 9, 2, 5, 100, 8.5, 'llm'),
(79, 47, 9, 3, 5, 100, 9.0, 'llm'),

-- Workout 49 (log_id 80) - ingreso manual sin LLM
(NULL, 49, 1, 1, 10, 60, 7.0, 'manual'),
(NULL, 49, 1, 2, 10, 60, 7.5, 'manual'),
(NULL, 49, 1, 3, 10, 60, 8.0, 'manual');