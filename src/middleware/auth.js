const { verify } = require('../utils/jwt');
const config = require('../config/env');

// Xác thực token Bearer; gắn req.user = { id, role, department_id, name }.
function authenticate(req, res, next) {
    const header = req.get('authorization') || '';
    const token = header.startsWith('Bearer ') ? header.slice(7).trim() : null;
    const payload = token ? verify(token, config.jwt.secret) : null;
    if (!payload) {
        return res.status(401).json({ status_code: 401, message: 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn' });
    }
    req.user = {
        id: payload.sub,
        role: payload.role,
        department_id: payload.department_id ?? null,
        name: payload.name || ''
    };
    next();
}

// Chỉ cho các vai trò được liệt kê đi tiếp (ma trận quyền Bảng 2.4, NFR-06).
function requireRole(...roles) {
    return (req, res, next) => {
        if (!req.user || !roles.includes(req.user.role)) {
            return res.status(403).json({ status_code: 403, message: 'Bạn không có quyền thực hiện chức năng này' });
        }
        next();
    };
}

module.exports = { authenticate, requireRole };
