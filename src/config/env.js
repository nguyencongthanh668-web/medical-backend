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

const jwtSecret = process.env.JWT_SECRET || 'dev-secret-doi-ngay-khi-trien-khai';
if (!process.env.JWT_SECRET && process.env.NODE_ENV !== 'test') {
    console.warn('[Cảnh báo] Chưa đặt JWT_SECRET trong .env; đang dùng khóa mặc định chỉ dành cho máy phát triển.');
}

module.exports = {
    port: readInteger('PORT', 3000, 1, 65535),
    jwt: {
        secret: jwtSecret,
        expiresInSeconds: readInteger('JWT_EXPIRES_HOURS', 8, 1, 720) * 3600
    },
    // Bộ quét hạn bảo dưỡng (FR-04): chạy lúc khởi động và mỗi ngày vào giờ này.
    alertScanHour: readInteger('ALERT_SCAN_HOUR', 0, 0, 23),
    // Chu kỳ dùng khi thiết bị chưa khai báo regular_maintenance và U3 không nhập ngày kế tiếp.
    defaultMaintenanceMonths: readInteger('DEFAULT_MAINTENANCE_MONTHS', 6, 1, 120),
    alertScanEnabled: process.env.ALERT_SCAN_ENABLED !== 'false',
    // API /api/v1/auto-seed xóa toàn bộ thiết bị; chỉ bật trên database thử nghiệm.
    allowSeed: process.env.ALLOW_SEED === 'true',
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
