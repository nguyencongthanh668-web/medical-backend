// Lỗi nghiệp vụ có mã HTTP; middleware xử lý lỗi trong app.js trả về JSON thống nhất.
class HttpError extends Error {
    constructor(status, message, extra) {
        super(message);
        this.status = status;
        this.extra = extra;
    }
}

module.exports = HttpError;
