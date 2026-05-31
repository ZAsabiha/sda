

ALTER TABLE exam_sitting
ADD COLUMN has_duel BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE exam_sitting
ADD COLUMN duel_date TIMESTAMP NULL;



INSERT INTO change_log (created_by, script_name, script_details)
VALUES (
    'admin',
    '003_task1_extend_exam_sitting.sql',
    'Added has_duel and duel_date columns to exam_sitting.'
);