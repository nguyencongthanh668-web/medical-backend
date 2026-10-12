const fs = require('node:fs');
const path = require('node:path');
const { loadEnvFile } = require('node:process');

// Đọc .env tại thư mục gốc dự án; biến môi trường đã có vẫn được ưu tiên.
const envPath = path.resolve(__dirname, '../../.env');
if (fs.existsSync(envPath)) loadEnvFile(envPath);

function readInteger(name, fallback, min, max) {
    const raw = process.env[name];
    if (raw === undefined || raw === '') return fallback;

    const value = Number(raw);
    if (!Number.isInteger(value) || value < min || value > max) {
        throw new Error(`${name} phải là số nguyên từ ${min} đến ${max}.`);
    }
    return value;
}

module.exports = {
    port: readInteger('PORT', 3000, 1, 65535),
    database: {
        host: process.env.DB_HOST || 'localhost',
        port: readInteger('DB_PORT', 3306, 1, 65535),
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'medical_device_db',
        waitForConnections: true,
        connectionLimit: readInteger('DB_CONNECTION_LIMIT', 10, 1, 1000),
        queueLimit: 0
    }
};
