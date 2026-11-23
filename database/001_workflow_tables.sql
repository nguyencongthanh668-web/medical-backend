-- Tham khảo: cấu trúc bổ sung cho FR-03, FR-04, FR-06 và NFR-06.
-- Nên chạy `npm run migrate` thay vì file này: script tự lấy đúng kiểu cột khóa ngoại
-- của bảng gốc và bỏ qua phần đã có. File này giả định khóa chính bảng gốc là BIGINT UNSIGNED
-- và notifications.id là CHAR(36) như Laravel.

ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'department';
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NULL;

CREATE TABLE inspection_results (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    equipment_id BIGINT UNSIGNED NOT NULL,
    notification_id CHAR(36) NULL,
    inspector_id BIGINT UNSIGNED NULL,
    cause TEXT NOT NULL,
    decision ENUM('self_fix', 'in_house', 'outsourced') NOT NULL,
    note TEXT NULL,
    inspected_at DATETIME NOT NULL,
    KEY idx_inspection_equipment (equipment_id, inspected_at),
    CONSTRAINT fk_inspection_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE,
    CONSTRAINT fk_inspection_notification FOREIGN KEY (notification_id) REFERENCES notifications (id) ON DELETE SET NULL,
    CONSTRAINT fk_inspection_user FOREIGN KEY (inspector_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE maintenance_records (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    equipment_id BIGINT UNSIGNED NOT NULL,
    inspection_id INT UNSIGNED NULL,
    type ENUM('repair', 'maintenance') NOT NULL,
    result ENUM('pass', 'fail') NOT NULL,
    cost DECIMAL(15, 2) NOT NULL DEFAULT 0,
    performed_by VARCHAR(255) NULL,
    document_url VARCHAR(500) NULL,
    note TEXT NULL,
    completed_at DATE NOT NULL,
    accepted_by BIGINT UNSIGNED NULL,
    created_at DATETIME NOT NULL,
    KEY idx_record_equipment (equipment_id, completed_at),
    CONSTRAINT fk_record_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE,
    CONSTRAINT fk_record_inspection FOREIGN KEY (inspection_id) REFERENCES inspection_results (id) ON DELETE SET NULL,
    CONSTRAINT fk_record_user FOREIGN KEY (accepted_by) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE maintenance_alerts (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    equipment_id BIGINT UNSIGNED NOT NULL,
    due_date DATE NOT NULL,
    milestone TINYINT UNSIGNED NOT NULL,
    alerted_at DATETIME NOT NULL,
    UNIQUE KEY uq_alert (equipment_id, due_date, milestone),
    CONSTRAINT fk_alert_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
