const config = require('./config/env');
const { createDatabasePool } = require('./config/database');
const { createApp } = require('./app');

function startServer() {
    const db = createDatabasePool();
    const app = createApp({ db });
    const server = app.listen(config.port, () => {
        console.log(`Server đang chạy tại http://localhost:${config.port}`);
    });

    let shuttingDown = false;
    function shutdown() {
        if (shuttingDown) return;
        shuttingDown = true;
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
