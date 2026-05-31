

CREATE TABLE IF NOT EXISTS change_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) NOT NULL,
    script_name VARCHAR(100) NOT NULL,
    script_details TEXT
);

INSERT INTO change_log (created_by, script_name, script_details)
VALUES ('admin', '000_change_log.sql', 'Created change_log table.');