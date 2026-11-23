// Bổ sung cấu trúc CSDL cho các chức năng mới (FR-03, FR-04, FR-06, NFR-06).
// Chạy được nhiều lần: cột/bảng đã có thì bỏ qua. Kiểu khóa ngoại lấy đúng theo bảng gốc.
// Cách chạy: npm run migrate   (đọc cấu hình MySQL từ .env)
const mysql = require('mysql2/promise');
const config = require('../src/config/env');

async function main() {
    const { host, port, user, password, database } = config.database;
    const conn = await mysql.createConnection({ host, port, user, password, database });
    const log = (msg) => console.log('  ' + msg);
    const [[{ db }]] = await conn.query('SELECT DATABASE() AS db');
    console.log(`Đang cập nhật database "${db}"...`);

    async function column(table, name) {
        const [rows] = await conn.query(
            'SELECT COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, CHARACTER_SET_NAME, COLLATION_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
            [table, name]);
        return rows[0] || null;
    }
    async function tableExists(table) {
        const [rows] = await conn.query('SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?', [table]);
        return rows.length > 0;
    }
    async function hasIndexOn(table, col) {
        const [rows] = await conn.query('SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ? AND SEQ_IN_INDEX = 1', [table, col]);
        return rows.length > 0;
    }
    async function addColumn(table, name, definition) {
        if (await column(table, name)) return;
        await conn.query(`ALTER TABLE \`${table}\` ADD COLUMN \`${name}\` ${definition}`);
        log(`+ ${table}.${name}`);
    }
    async function addIndex(table, col, indexName) {
        if (await hasIndexOn(table, col)) return;
        await conn.query(`ALTER TABLE \`${table}\` ADD INDEX \`${indexName}\` (\`${col}\`)`);
        log(`+ index ${table}(${col})`);
    }
    // Kiểu cột của khóa ngoại phải giống hệt cột được tham chiếu.
    function refType(col) {
        let t = col.COLUMN_TYPE;
        if (col.CHARACTER_SET_NAME) t += ` CHARACTER SET ${col.CHARACTER_SET_NAME} COLLATE ${col.COLLATION_NAME}`;
        return t;
    }
    async function createTable(name, columns, foreignKeys) {
        if (await tableExists(name)) return log(`= bảng ${name} đã có`);
        const base = `CREATE TABLE \`${name}\` (${columns.join(', ')}`;
        try {
            await conn.query(`${base}${foreignKeys.length ? ', ' + foreignKeys.join(', ') : ''}) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
            log(`+ bảng ${name}`);
        } catch (err) {
            // Bảng gốc dùng MyISAM hoặc khác kiểu: tạo không có ràng buộc khóa ngoại, ứng dụng vẫn kiểm tra liên kết.
            await conn.query(`${base}) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`);
            log(`+ bảng ${name} (không tạo được khóa ngoại: ${err.message})`);
        }
    }

    for (const t of ['medical_equipments', 'users', 'notifications']) {
        if (!(await tableExists(t))) throw new Error(`Thiếu bảng ${t} trong database ${db}`);
    }

    // NFR-06: vai trò và mật khẩu băm cho đăng nhập thật.
    await addColumn('users', 'role', "VARCHAR(20) NOT NULL DEFAULT 'department'");
    await addColumn('users', 'password_hash', 'VARCHAR(255) NULL');
    const legacyPassword = await column('users', 'password');
    if (legacyPassword && legacyPassword.IS_NULLABLE === 'NO' && legacyPassword.COLUMN_DEFAULT === null) {
        await conn.query(`ALTER TABLE users MODIFY \`password\` ${legacyPassword.COLUMN_TYPE} NULL`);
        log('~ users.password cho phép NULL (tài khoản mới dùng password_hash)');
    }

    // Các cột thiết bị mà luồng nghiệp vụ dùng.
    await addColumn('medical_equipments', 'code', 'VARCHAR(100) NULL');
    await addColumn('medical_equipments', 'regular_maintenance', 'INT NOT NULL DEFAULT 0');
    await addColumn('medical_equipments', 'last_maintenance', 'DATE NULL');
    await addColumn('medical_equipments', 'next_maintenance', 'DATE NULL');
    await addColumn('medical_equipments', 'date_failure', 'DATETIME NULL');
    await addColumn('medical_equipments', 'reason', 'VARCHAR(500) NULL');
    await addColumn('medical_equipments', 'critical_level', 'VARCHAR(50) NULL');
    await addIndex('medical_equipments', 'next_maintenance', 'idx_equipment_next_maintenance');
    await addIndex('notifications', 'data_id', 'idx_notification_equipment');

    const eqId = refType(await column('medical_equipments', 'id'));
    const userId = refType(await column('users', 'id'));
    const notifId = refType(await column('notifications', 'id'));

    // FR-03: kết quả kiểm tra sơ bộ.
    await createTable('inspection_results', [
        'id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY',
        `equipment_id ${eqId} NOT NULL`,
        `notification_id ${notifId} NULL`,
        `inspector_id ${userId} NULL`,
        'cause TEXT NOT NULL',
        "decision ENUM('self_fix', 'in_house', 'outsourced') NOT NULL",
        'note TEXT NULL',
        'inspected_at DATETIME NOT NULL',
        'KEY idx_inspection_equipment (equipment_id, inspected_at)'
    ], [
        'CONSTRAINT fk_inspection_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE',
        'CONSTRAINT fk_inspection_notification FOREIGN KEY (notification_id) REFERENCES notifications (id) ON DELETE SET NULL',
        'CONSTRAINT fk_inspection_user FOREIGN KEY (inspector_id) REFERENCES users (id) ON DELETE SET NULL'
    ]);

    // FR-06: kết quả sửa chữa/bảo dưỡng, nghiệm thu và chi phí.
    await createTable('maintenance_records', [
        'id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY',
        `equipment_id ${eqId} NOT NULL`,
        'inspection_id INT UNSIGNED NULL',
        "type ENUM('repair', 'maintenance') NOT NULL",
        "result ENUM('pass', 'fail') NOT NULL",
        'cost DECIMAL(15, 2) NOT NULL DEFAULT 0',
        'performed_by VARCHAR(255) NULL',
        'document_url VARCHAR(500) NULL',
        'note TEXT NULL',
        'completed_at DATE NOT NULL',
        `accepted_by ${userId} NULL`,
        'created_at DATETIME NOT NULL',
        'KEY idx_record_equipment (equipment_id, completed_at)'
    ], [
        'CONSTRAINT fk_record_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE',
        'CONSTRAINT fk_record_inspection FOREIGN KEY (inspection_id) REFERENCES inspection_results (id) ON DELETE SET NULL',
        'CONSTRAINT fk_record_user FOREIGN KEY (accepted_by) REFERENCES users (id) ON DELETE SET NULL'
    ]);

    // FR-04, NFR-03: mỗi (thiết bị, ngày đến hạn, mốc) chỉ cảnh báo một lần.
    await createTable('maintenance_alerts', [
        'id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY',
        `equipment_id ${eqId} NOT NULL`,
        'due_date DATE NOT NULL',
        'milestone TINYINT UNSIGNED NOT NULL',
        'alerted_at DATETIME NOT NULL',
        'UNIQUE KEY uq_alert (equipment_id, due_date, milestone)'
    ], [
        'CONSTRAINT fk_alert_equipment FOREIGN KEY (equipment_id) REFERENCES medical_equipments (id) ON DELETE CASCADE'
    ]);

    // NFR-02: dữ liệu mẫu có thiết bị và người dùng trỏ tới khoa không tồn tại trong bảng departments
    // (ví dụ department_id = 54). Khi đó U3 không chọn được khoa này lúc thêm thiết bị, và U1 của khoa
    // đó không bao giờ thấy thiết bị mới. Bổ sung bản ghi khoa còn thiếu, không sửa dữ liệu thiết bị.
    const [orphans] = await conn.query(
        `SELECT ref.id FROM (
            SELECT DISTINCT department_id AS id FROM medical_equipments WHERE department_id > 0
            UNION SELECT DISTINCT department_id FROM users WHERE department_id > 0
         ) ref LEFT JOIN departments d ON d.id = ref.id WHERE d.id IS NULL`);
    for (const { id } of orphans) {
        await conn.query('INSERT INTO departments (id, title) VALUES (?, ?)', [id, `Khoa dữ liệu mẫu (mã ${id})`]);
        log(`+ departments: bổ sung khoa còn thiếu id ${id}`);
    }

    // Cảnh báo nếu bảng users còn cột bắt buộc khác khiến việc tạo tài khoản mới bị lỗi.
    const [required] = await conn.query(
        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND IS_NULLABLE = 'NO' AND COLUMN_DEFAULT IS NULL AND EXTRA NOT LIKE '%auto_increment%' AND COLUMN_NAME NOT IN ('name', 'displayname', 'email', 'password_hash', 'role', 'department_id', 'created_at', 'updated_at')");
    if (required.length) {
        log(`! users còn cột bắt buộc không có giá trị mặc định: ${required.map(r => r.COLUMN_NAME).join(', ')}. Script tạo tài khoản sẽ tự điền giá trị rỗng.`);
    }

    await conn.end();
    console.log('Hoàn tất.');
}

main().catch((err) => {
    console.error('Lỗi migration:', err.message);
    process.exitCode = 1;
});
