
ALTER TABLE potion_attempt
ADD COLUMN brew_minutes INT NULL;

ALTER TABLE potion_attempt
ADD COLUMN brew_seconds INT NULL;

ALTER TABLE potion_attempt
ADD COLUMN brew_milliseconds INT NULL;

ALTER TABLE potion_attempt
ADD CONSTRAINT chk_brew_minutes
CHECK (brew_minutes IS NULL OR brew_minutes >= 0);

ALTER TABLE potion_attempt
ADD CONSTRAINT chk_brew_seconds
CHECK (brew_seconds IS NULL OR brew_seconds BETWEEN 0 AND 59);

ALTER TABLE potion_attempt
ADD CONSTRAINT chk_brew_milliseconds
CHECK (brew_milliseconds IS NULL OR brew_milliseconds BETWEEN 0 AND 999);



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '009_phase1_expand_brew_time.sql',
    'Added brew_minutes, brew_seconds, and brew_milliseconds columns.'
);