const fs = require('node:fs');
const path = require('node:path');
const config = require('./config/env');
const { createDatabasePool } = require('./config/database');
const { createApp } = require('./app');
const { scheduleDaily } = require('./jobs/scheduler');
const { scanMaintenanceDue } = require('./services/maintenance-alert.service');
const createMaintenanceAlertRepository = require('./repositories/maintenance-alert.repository');
const createNotificationRepository = require('./repositories/notification.repository');

function startServer() {
    const db = createDatabasePool();
    // Nếu đã chạy `flutter build web` và chép vào public/ thì phục vụ luôn ứng dụng web.
    const webDir = path.join(__dirname, '..', 'public');
    const hasWeb = fs.existsSync(path.join(webDir, 'index.html'));
    const app = createApp({ db, webDir: hasWeb ? webDir : null });
    const server = app.listen(config.port, () => {
        console.log(`Server đang chạy tại http://localhost:${config.port}`);
        if (hasWeb) console.log(`Ứng dụng web: http://localhost:${config.port}/`);
    });

    // FR-04: quét hạn bảo dưỡng khi khởi động và mỗi ngày vào ALERT_SCAN_HOUR giờ.
    const stopScheduler = config.alertScanEnabled
        ? scheduleDaily(config.alertScanHour, () => scanMaintenanceDue({
            db,
            alertRepository: createMaintenanceAlertRepository(db),
            notificationRepository: createNotificationRepository(db)
        }))
        : () => {};

    let shuttingDown = false;
    function shutdown() {
        if (shuttingDown) return;
        shuttingDown = true;
        stopScheduler();
        server.close(() => {
            db.end((err) => {
                if (err) {
                    console.error('Lỗi đóng kết nối MySQL:', err.message);
                    process.exitCode = 1;
                }
            });
        });
    }

    process.once('SIGINT', shutdown);
    process.once('SIGTERM', shutdown);
    return { app, server, db };
}

module.exports = { startServer };
