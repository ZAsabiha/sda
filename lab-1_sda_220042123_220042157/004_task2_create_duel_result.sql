
CREATE TABLE IF NOT EXISTS duel_result (
    duel_result_id INT AUTO_INCREMENT PRIMARY KEY,
    sitting_id INT NOT NULL,
    student_id INT NOT NULL,
    duel_rank INT NOT NULL,
    duel_marks_earned INT,
    is_disqualified BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_duel_result_sitting
        FOREIGN KEY (sitting_id)
        REFERENCES exam_sitting(sitting_id),

    CONSTRAINT fk_duel_result_student
        FOREIGN KEY (student_id)
        REFERENCES student(student_id),

    CONSTRAINT uq_duel_result_student_sitting
        UNIQUE (sitting_id, student_id),

    CONSTRAINT chk_duel_rank
        CHECK (duel_rank > 0),

    CONSTRAINT chk_duel_marks
        CHECK (duel_marks_earned IS NULL OR duel_marks_earned >= 0)
);



DELIMITER $$

CREATE TRIGGER trg_duel_result_before_insert
BEFORE INSERT ON duel_result
FOR EACH ROW
BEGIN
    DECLARE v_has_duel BOOLEAN;

    SELECT has_duel
    INTO v_has_duel
    FROM exam_sitting
    WHERE sitting_id = NEW.sitting_id;

    IF NEW.duel_marks_earned IS NOT NULL AND v_has_duel = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duel marks cannot be recorded because this exam sitting has no duel.';
    END IF;
END$$

CREATE TRIGGER trg_duel_result_before_update
BEFORE UPDATE ON duel_result
FOR EACH ROW
BEGIN
    DECLARE v_has_duel BOOLEAN;

    SELECT has_duel
    INTO v_has_duel
    FROM exam_sitting
    WHERE sitting_id = NEW.sitting_id;

    IF NEW.duel_marks_earned IS NOT NULL AND v_has_duel = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duel marks cannot be recorded because this exam sitting has no duel.';
    END IF;
END$$

DELIMITER ;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '004_task2_create_duel_result.sql',
    'Created duel_result table with FK, unique constraint, and trigger validation.'
);