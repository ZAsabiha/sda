

CREATE TABLE IF NOT EXISTS migration_error_log (
    error_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    old_value VARCHAR(255),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE migrate_guardian_contacts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_student_id INT;
    DECLARE v_contact VARCHAR(255);

    DECLARE cur CURSOR FOR
        SELECT student_id, guardian_contact
        FROM student
        WHERE guardian_contact_migrated = FALSE;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_student_id, v_contact;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Format 1:
        -- Mother - Molly Weasley - The Burrow
        IF v_contact LIKE '% - % - %' THEN

            UPDATE student
            SET
                guardian_relationship = TRIM(SUBSTRING_INDEX(v_contact, ' - ', 1)),
                guardian_name = TRIM(
                    SUBSTRING_INDEX(
                        SUBSTRING_INDEX(v_contact, ' - ', 2),
                        ' - ',
                        -1
                    )
                ),
                guardian_address = TRIM(SUBSTRING_INDEX(v_contact, ' - ', -1)),
                guardian_contact_migrated = TRUE
            WHERE student_id = v_student_id;

        -- Format 2:
        -- Uncle: Vernon Dursley +441234567890
        ELSEIF v_contact LIKE '%:%+%' OR v_contact LIKE '%: %+%' THEN

            UPDATE student
            SET
                guardian_relationship = TRIM(SUBSTRING_INDEX(v_contact, ':', 1)),
                guardian_name = TRIM(
                    SUBSTRING_INDEX(
                        TRIM(SUBSTRING_INDEX(v_contact, ':', -1)),
                        '+',
                        1
                    )
                ),
                guardian_address = CONCAT(
                    '+',
                    TRIM(SUBSTRING_INDEX(v_contact, '+', -1))
                ),
                guardian_contact_migrated = TRUE
            WHERE student_id = v_student_id;

        ELSE
            INSERT INTO migration_error_log
                (student_id, old_value, error_message)
            VALUES
                (v_student_id, v_contact, 'Could not parse guardian_contact format.');
        END IF;

    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

CALL migrate_guardian_contacts();



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '007_phase2_migrate_guardian_contact.sql',
    'Created migration_error_log, migrated guardian_contact data, and logged unparsed rows.'
);