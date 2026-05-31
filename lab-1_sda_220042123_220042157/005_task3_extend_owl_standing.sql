
ALTER TABLE owl_standing
ADD COLUMN duel_marks INT NOT NULL DEFAULT 0;

DELIMITER $$

CREATE PROCEDURE update_duel_standing(
    IN p_student_id INT,
    IN p_academic_year YEAR
)
BEGIN
    DECLARE v_duel_marks INT DEFAULT 0;

    SELECT COALESCE(SUM(dr.duel_marks_earned), 0)
    INTO v_duel_marks
    FROM duel_result dr
    JOIN exam_sitting es
        ON dr.sitting_id = es.sitting_id
    WHERE dr.student_id = p_student_id
      AND es.academic_year = p_academic_year
      AND dr.is_disqualified = FALSE;

    UPDATE owl_standing
    SET duel_marks = v_duel_marks
    WHERE student_id = p_student_id
      AND academic_year = p_academic_year;
END$$

DELIMITER ;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '005_task3_extend_owl_standing.sql',
    'Added duel_marks to owl_standing and created update_duel_standing procedure.'
);