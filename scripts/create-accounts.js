// Tạo (hoặc cập nhật mật khẩu, vai trò của) bốn tài khoản demo, mỗi vai trò một tài khoản.
// Cách chạy: npm run accounts   — mật khẩu mặc định 123456, đổi bằng biến DEMO_PASSWORD.
const mysql = require('mysql2/promise');
const config = require('../src/config/env');
const { hashPassword } = require('../src/utils/password');

const PASSWORD = process.env.DEMO_PASSWORD || '123456';

async function main() {
    const { host, port, user, password, database } = config.database;
    const conn = await mysql.createConnection({ host, port, user, password, database });
    // U1 demo thuộc khoa đang quản lý nhiều thiết bị nhất để có dữ liệu thử ngay.
    const [[dept]] = await conn.query('SELECT department_id AS id FROM medical_equipments WHERE department_id IS NOT NULL GROUP BY department_id ORDER BY COUNT(*) DESC LIMIT 1');
    const departmentId = dept ? dept.id : null;

    const accounts = [
        { email: 'khoa@demo.vn', name: 'Điều dưỡng Khoa (U1)', role: 'department', department_id: departmentId },
        { email: 'ktv@demo.vn', name: 'Kỹ thuật viên (U2)', role: 'technician', department_id: null },
        { email: 'vattu@demo.vn', name: 'Cán bộ Phòng Vật tư (U3)', role: 'manager', department_id: null },
        { email: 'admin@gmail.com', name: 'Quản trị hệ thống (U4)', role: 'admin', department_id: null }
    ];

    // Các cột bắt buộc khác của bảng users gốc: điền giá trị rỗng phù hợp kiểu dữ liệu.
    const [cols] = await conn.query(
        "SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND IS_NULLABLE = 'NO' AND COLUMN_DEFAULT IS NULL AND EXTRA NOT LIKE '%auto_increment%'");
    const [allCols] = await conn.query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users'");
    const hasColumn = new Set(allCols.map(c => c.COLUMN_NAME));
    const fillers = {};
    for (const c of cols) {
        if (['name', 'email', 'password_hash', 'role', 'department_id', 'created_at', 'updated_at'].includes(c.COLUMN_NAME)) continue;
        if (/int|decimal|float|double|bit/.test(c.DATA_TYPE)) fillers[c.COLUMN_NAME] = 0;
        else if (/date|time/.test(c.DATA_TYPE)) fillers[c.COLUMN_NAME] = new Date();
        else fillers[c.COLUMN_NAME] = '';
    }

    for (const a of accounts) {
        const hash = hashPassword(PASSWORD);
        const [[existing]] = await conn.query('SELECT id FROM users WHERE email = ?', [a.email]);
        if (existing) {
            await conn.query('UPDATE users SET role = ?, password_hash = ?, department_id = COALESCE(?, department_id), is_disabled = 0 WHERE id = ?',
                [a.role, hash, a.department_id, existing.id]);
            console.log(`~ ${a.email} (${a.role}) đã cập nhật`);
        } else {
            if ('displayname' in fillers) fillers.displayname = a.name;
            const row = { ...fillers, name: a.name, email: a.email, password_hash: hash, role: a.role,
                department_id: a.department_id };
            if (hasColumn.has('created_at')) row.created_at = new Date();
            if (hasColumn.has('updated_at')) row.updated_at = new Date();
            const keys = Object.keys(row);
            await conn.query(`INSERT INTO users (${keys.map(k => `\`${k}\``).join(', ')}) VALUES (${keys.map(() => '?').join(', ')})`, keys.map(k => row[k]));
            console.log(`+ ${a.email} (${a.role}) đã tạo`);
        }
    }
    console.log(`Mật khẩu của các tài khoản demo: ${PASSWORD}`);
    await conn.end();
}

main().catch((err) => {
    console.error('Lỗi tạo tài khoản:', err.message);
    process.exitCode = 1;
});
