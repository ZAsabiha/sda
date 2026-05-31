-- ============================================================
-- 002_seed_data.sql
-- Populates sample data for SpellCast DB.
-- NOT idempotent — re-running will insert duplicate rows.
-- Wrap in a transaction so a partial failure rolls back cleanly.
-- ============================================================

START TRANSACTION;

-- ------------------------------------------------------------
-- Houses  (2)
-- ------------------------------------------------------------
INSERT INTO house (name, founder, head_of_house) VALUES
    ('Gryffindor', 'Godric Gryffindor',   'Minerva McGonagall'),
    ('Slytherin',  'Salazar Slytherin',   'Severus Snape'),
    ('Ravenclaw',  'Rowena Ravenclaw',    'Filius Flitwick'),
    ('Hufflepuff', 'Helga Hufflepuff',    'Pomona Sprout');

-- ------------------------------------------------------------
-- Students  (5, spread across houses)
-- ------------------------------------------------------------
INSERT INTO student (name, blood_status, date_of_birth, house_id, guardian_contact) VALUES
    ('Harry Potter',    'Half-blood',   '1980-07-31', 1, 'Uncle: Vernon Dursley +441234567890'),
    ('Hermione Granger','Muggle-born',  '1979-09-19', 1, 'Father - Richard Granger - +441908765432'),
    ('Ron Weasley',     'Pure-blood',   '1980-03-01', 1, 'Mother - Molly Weasley - The Burrow, Ottery St Catchpole'),
    ('Draco Malfoy',    'Pure-blood',   '1980-06-05', 2, 'Father - Lucius Malfoy - Malfoy Manor, Wiltshire'),
    ('Luna Lovegood',   'Pure-blood',   '1981-02-13', 3, 'Father: Xenophilius Lovegood +440123456789');

-- ------------------------------------------------------------
-- Courses  (4)
-- ------------------------------------------------------------
INSERT INTO course (title, professor, classroom, max_students, difficulty_level) VALUES
    ('Defence Against the Dark Arts', 'Alastor Moody',    'Third Floor, Room 3C', 30, 'O.W.L.'),
    ('Potions',                        'Severus Snape',    'Dungeons, Lab 1',      25, 'O.W.L.'),
    ('Transfiguration',                'Minerva McGonagall','Second Floor, Room 2A',28, 'N.E.W.T.'),
    ('Charms',                         'Filius Flitwick',  'First Floor, Room 1B', 32, 'Intermediate');

-- ------------------------------------------------------------
-- Exam Sitting  (1 full sitting — Potions O.W.L., year 1995)
-- ------------------------------------------------------------
INSERT INTO exam_sitting (course_id, academic_year, exam_date, status) VALUES
    (2, 1995, '1995-06-12', 'Completed');   -- sitting_id = 1  (Potions)

-- ------------------------------------------------------------
-- Exam Results  (all 5 students for sitting 1)
-- Grades: O(utstanding) E(xceeds Expectations) A(cceptable)
--         P(oor) D(readful) T(roll)
-- ------------------------------------------------------------
INSERT INTO exam_result (sitting_id, student_id, grade, marks_earned, is_failed) VALUES
    (1, 1, 'A',  64.50, 0),   -- Harry   — Acceptable
    (1, 2, 'O',  98.00, 0),   -- Hermione — Outstanding
    (1, 3, 'A',  61.00, 0),   -- Ron      — Acceptable
    (1, 4, 'E',  85.50, 0),   -- Draco    — Exceeds Expectations
    (1, 5, 'E',  79.00, 0);   -- Luna     — Exceeds Expectations

-- ------------------------------------------------------------
-- Potion Attempts  (each student had 1 attempt in sitting 1)
-- brew_time_recorded uses legacy 'M:SS.mmm' format
-- ------------------------------------------------------------
INSERT INTO potion_attempt (sitting_id, student_id, attempt_number, brew_duration_seconds, brew_time_recorded, cauldron_explosion) VALUES
    (1, 1, 1, 292.300, '4:52.300', 0),   -- Harry
    (1, 2, 1, 241.750, '4:01.750', 0),   -- Hermione
    (1, 3, 1, 310.500, '5:10.500', 1),   -- Ron — cauldron exploded
    (1, 4, 1, 255.100, '4:15.100', 0),   -- Draco
    (1, 5, 1, 268.900, '4:28.900', 0);   -- Luna

-- ------------------------------------------------------------
-- Spell Stints  (duel warm-up exercise, same sitting)
-- ------------------------------------------------------------
INSERT INTO spell_stint (sitting_id, student_id, incantation, start_round, end_round) VALUES
    (1, 1, 'Expelliarmus',   1, 3),
    (1, 1, 'Stupefy',        4, 6),
    (1, 2, 'Wingardium Leviosa', 1, 4),
    (1, 2, 'Alohomora',      5, 6),
    (1, 3, 'Expelliarmus',   1, 2),
    (1, 4, 'Avada Kedavra',  1, 1),   -- flagged incident
    (1, 5, 'Riddikulus',     1, 5);

-- ------------------------------------------------------------
-- O.W.L. Standings  (snapshot after the Potions sitting)
-- ------------------------------------------------------------
INSERT INTO owl_standing (student_id, academic_year, total_marks, owl_grade) VALUES
    (1, 1995,  64.50, 'A'),
    (2, 1995,  98.00, 'O'),
    (3, 1995,  61.00, 'A'),
    (4, 1995,  85.50, 'E'),
    (5, 1995,  79.00, 'E');

-- ------------------------------------------------------------
-- Verification queries (expected outputs as comments)
-- ------------------------------------------------------------

-- SELECT COUNT(*) FROM house;          -- Expected: 4
-- SELECT COUNT(*) FROM student;        -- Expected: 5
-- SELECT COUNT(*) FROM course;         -- Expected: 4
-- SELECT COUNT(*) FROM exam_sitting;   -- Expected: 1
-- SELECT COUNT(*) FROM exam_result;    -- Expected: 5
-- SELECT COUNT(*) FROM potion_attempt; -- Expected: 5
-- SELECT COUNT(*) FROM spell_stint;    -- Expected: 7
-- SELECT COUNT(*) FROM owl_standing;   -- Expected: 5

COMMIT;

-- ============================================================
INSERT INTO change_log (created_by, script_name, script_details)
VALUES ('admin', '002_seed_data.sql',
        'Seeded 4 houses, 5 students, 4 courses, 1 exam sitting with results, potion attempts, spell stints, and OWL standings.');