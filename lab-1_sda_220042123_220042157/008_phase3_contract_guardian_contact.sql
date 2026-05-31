

DELIMITER $$

CREATE PROCEDURE contract_guardian_contact()
BEGIN
    DECLARE v_unmigrated_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_unmigrated_count
    FROM student
    WHERE guardian_contact_migrated = FALSE;

    IF v_unmigrated_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot drop guardian_contact because some rows are not migrated.';
    END IF;
END$$

DELIMITER ;

CALL contract_guardian_contact();

ALTER TABLE student
MODIFY guardian_name VARCHAR(100) NOT NULL;

ALTER TABLE student
MODIFY guardian_address VARCHAR(255) NOT NULL;

ALTER TABLE student
DROP COLUMN guardian_contact;

ALTER TABLE student
DROP COLUMN guardian_contact_migrated;

DELIMITER $$

CREATE PROCEDURE get_student_guardian_contact(
    IN p_student_id INT
)
BEGIN
    SELECT
        student_id,
        name AS student_name,
        guardian_name,
        guardian_relationship,
        guardian_address
    FROM student
    WHERE student_id = p_student_id;
END$$

DELIMITER ;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '008_phase3_contract_guardian_contact.sql',
    'Dropped old guardian_contact columns and created get_student_guardian_contact procedure.'
);