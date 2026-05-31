

DELIMITER $$

CREATE PROCEDURE parse_brew_times()
BEGIN
    UPDATE potion_attempt
    SET
        brew_minutes = CAST(SUBSTRING_INDEX(brew_time_recorded, ':', 1) AS UNSIGNED),

        brew_seconds = CAST(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(brew_time_recorded, ':', -1),
                '.',
                1
            ) AS UNSIGNED
        ),

        brew_milliseconds = CAST(
            SUBSTRING_INDEX(brew_time_recorded, '.', -1)
            AS UNSIGNED
        )
    WHERE brew_time_recorded IS NOT NULL;
END$$

CREATE PROCEDURE get_brew_time_as_seconds(
    IN p_attempt_id INT
)
BEGIN
    SELECT
        attempt_id,
        (
            COALESCE(brew_minutes, 0) * 60
            + brew_seconds
            + brew_milliseconds / 1000
        ) AS total_brew_seconds
    FROM potion_attempt
    WHERE attempt_id = p_attempt_id;
END$$

DELIMITER ;

CALL parse_brew_times();



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '010_phase2_migrate_brew_time.sql',
    'Parsed brew_time_recorded into structured time columns and created get_brew_time_as_seconds procedure.'
);