const express = require('express');
const cors = require('cors');
const createApiRouter = require('./routes');

// webDir: thư mục bản build Flutter web (flutter build web). Khi có, ứng dụng web và API
// chạy chung một địa chỉ http://localhost:3000 nên không cần cấu hình CORS khi demo.
function createApp({ db, webDir = null }) {
    const app = express();
    app.use(cors());
    app.use(express.json({ limit: '1mb' }));

    app.get('/api/health', (req, res) => {
        res.json({ message: 'Máy chủ đang hoạt động!' });
    });
    if (webDir) {
        app.use(express.static(webDir));
    } else {
        app.get('/', (req, res) => {
            res.json({ message: 'Máy chủ đang hoạt động!' });
        });
    }
    app.use('/api', createApiRouter(db));

    // Lỗi nghiệp vụ (HttpError) trả đúng mã 400/403/404/409; lỗi khác trả 500 và ghi log.
    // Mã lỗi giúp ứng dụng phân biệt lỗi dữ liệu, lỗi quyền và lỗi mạng (NFR-03, NFR-04).
    app.use((err, req, res, next) => {
        if (err.type === 'entity.parse.failed') {
            return res.status(400).json({ status_code: 400, message: 'Dữ liệu gửi lên không đúng định dạng JSON' });
        }
        if (err.status && err.status < 500) {
            return res.status(err.status).json({ status_code: err.status, message: err.message, ...(err.extra || {}) });
        }
        console.error('Lỗi máy chủ:', err);
        res.status(500).json({ status_code: 500, message: 'Lỗi máy chủ' });
    });
    return app;
}

module.exports = { createApp };
