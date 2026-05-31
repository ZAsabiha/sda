-- ============================================================
-- 001_init_schema.sql
-- Creates all core tables for SpellCast DB.
-- Idempotent: uses IF NOT EXISTS on all tables.
-- ============================================================

-- ------------------------------------------------------------
-- 1. house
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS house (
    house_id        INT          AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(50)  NOT NULL UNIQUE,
    founder         VARCHAR(100) NOT NULL,
    head_of_house   VARCHAR(100) NOT NULL
);

-- ------------------------------------------------------------
-- 2. student
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS student (
    student_id      INT          AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    blood_status    ENUM('Pure-blood','Half-blood','Muggle-born') NOT NULL,
    date_of_birth   DATE         NOT NULL,
    house_id        INT          NOT NULL,
    guardian_contact VARCHAR(255) NOT NULL,
    CONSTRAINT fk_student_house FOREIGN KEY (house_id) REFERENCES house(house_id)
);

-- ------------------------------------------------------------
-- 3. course
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS course (
    course_id         INT          AUTO_INCREMENT PRIMARY KEY,
    title             VARCHAR(100) NOT NULL,
    professor         VARCHAR(100) NOT NULL,
    classroom         VARCHAR(50)  NOT NULL,
    max_students      INT          NOT NULL CHECK (max_students > 0),
    difficulty_level  ENUM('Beginner','Intermediate','Advanced','O.W.L.','N.E.W.T.') NOT NULL
);

-- ------------------------------------------------------------
-- 4. exam_sitting
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exam_sitting (
    sitting_id      INT          AUTO_INCREMENT PRIMARY KEY,
    course_id       INT          NOT NULL,
    academic_year   YEAR         NOT NULL,
    exam_date       DATE         NOT NULL,
    status          ENUM('Scheduled','Ongoing','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT fk_sitting_course FOREIGN KEY (course_id) REFERENCES course(course_id)
);

-- ------------------------------------------------------------
-- 5. exam_result
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exam_result (
    result_id       INT          AUTO_INCREMENT PRIMARY KEY,
    sitting_id      INT          NOT NULL,
    student_id      INT          NOT NULL,
    grade           CHAR(1)      NOT NULL CHECK (grade IN ('O','E','A','P','D','T')),
    marks_earned    DECIMAL(5,2) NOT NULL CHECK (marks_earned >= 0),
    is_failed       TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_result_sitting FOREIGN KEY (sitting_id) REFERENCES exam_sitting(sitting_id),
    CONSTRAINT fk_result_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT uq_result_sitting_student UNIQUE (sitting_id, student_id)
);

-- ------------------------------------------------------------
-- 6. potion_attempt
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS potion_attempt (
    attempt_id              INT          AUTO_INCREMENT PRIMARY KEY,
    sitting_id              INT          NOT NULL,
    student_id              INT          NOT NULL,
    attempt_number          INT          NOT NULL CHECK (attempt_number >= 1),
    brew_duration_seconds   DECIMAL(7,3),
    brew_time_recorded      VARCHAR(20),        -- legacy format 'M:SS.mmm'
    cauldron_explosion      TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_potion_sitting FOREIGN KEY (sitting_id) REFERENCES exam_sitting(sitting_id),
    CONSTRAINT fk_potion_student FOREIGN KEY (student_id) REFERENCES student(student_id)
);

-- ------------------------------------------------------------
-- 7. spell_stint
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS spell_stint (
    stint_id        INT          AUTO_INCREMENT PRIMARY KEY,
    sitting_id      INT          NOT NULL,
    student_id      INT          NOT NULL,
    incantation     VARCHAR(100) NOT NULL,
    start_round     INT          NOT NULL CHECK (start_round >= 1),
    end_round       INT          NOT NULL,
    CONSTRAINT fk_stint_sitting FOREIGN KEY (sitting_id) REFERENCES exam_sitting(sitting_id),
    CONSTRAINT fk_stint_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT chk_stint_rounds CHECK (end_round >= start_round)
);

-- ------------------------------------------------------------
-- 8. owl_standing
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS owl_standing (
    standing_id     INT          AUTO_INCREMENT PRIMARY KEY,
    student_id      INT          NOT NULL,
    academic_year   YEAR         NOT NULL,
    total_marks     DECIMAL(7,2) NOT NULL DEFAULT 0,
    owl_grade       CHAR(1)      CHECK (owl_grade IN ('O','E','A','P','D','T')),
    CONSTRAINT fk_standing_student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT uq_standing_student_year UNIQUE (student_id, academic_year)
);

-- ============================================================
INSERT INTO change_log (created_by, script_name, script_details)
VALUES ('admin', '001_init_schema.sql', 'Created all 8 core SpellCast DB tables with FK constraints.');