

DELIMITER $$

CREATE PROCEDURE contract_brew_time()
BEGIN
    DECLARE v_mismatch_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_mismatch_count
    FROM potion_attempt
    WHERE brew_time_recorded <>
        CONCAT(
            brew_minutes,
            ':',
            LPAD(brew_seconds, 2, '0'),
            '.',
            LPAD(brew_milliseconds, 3, '0')
        );

    IF v_mismatch_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot drop brew_time_recorded because validation mismatches exist.';
    END IF;
END$$

DELIMITER ;

CALL contract_brew_time();

ALTER TABLE potion_attempt
MODIFY brew_seconds INT NOT NULL;

ALTER TABLE potion_attempt
MODIFY brew_milliseconds INT NOT NULL;

ALTER TABLE potion_attempt
DROP COLUMN brew_time_recorded;

CREATE OR REPLACE VIEW v_potion_attempt_display AS
SELECT
    attempt_id,
    sitting_id,
    student_id,
    attempt_number,
    brew_duration_seconds,
    CONCAT(
        COALESCE(brew_minutes, 0),
        ':',
        LPAD(brew_seconds, 2, '0'),
        '.',
        LPAD(brew_milliseconds, 3, '0')
    ) AS brew_time_display,
    cauldron_explosion
FROM potion_attempt;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '011_phase3_contract_brew_time.sql',
    'Dropped brew_time_recorded and created v_potion_attempt_display view.'
);