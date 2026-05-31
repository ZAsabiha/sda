

ALTER TABLE student
ADD COLUMN guardian_name VARCHAR(100) NULL;

ALTER TABLE student
ADD COLUMN guardian_relationship VARCHAR(50) NULL;

ALTER TABLE student
ADD COLUMN guardian_address VARCHAR(255) NULL;

ALTER TABLE student
ADD COLUMN guardian_contact_migrated BOOLEAN NOT NULL DEFAULT FALSE;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '006_phase1_expand_guardian_contact.sql',
    'Added structured guardian columns beside old guardian_contact column.'
);