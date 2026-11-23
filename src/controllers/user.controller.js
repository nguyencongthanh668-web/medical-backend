const formatUser = require('../formatters/user.formatter');
const HttpError = require('../utils/http-error');
const { ALL_ROLES } = require('../config/roles');
const { hashPassword } = require('../utils/password');
const { parseId, requiredText, oneOf } = require('../utils/validate');

function createUserController(userRepository) {
    return {
        list(req, res) {
            userRepository.findAll(req.query.department_id, (err, results) => {
                if (err) return res.status(500).json({ error: 'Lỗi Server' });

                const data = results.map(formatUser);
                res.status(200).json({ data, dataLength: data.length });
            });
        },

        detail(req, res) {
            userRepository.findById(req.params.id, (err, results) => {
                if (err) {
                    console.error('Lỗi truy vấn:', err);
                    return res.status(500).json({ status_code: 500, message: 'Lỗi Server' });
                }
                if (results.length === 0) {
                    return res.status(404).json({ status_code: 404, message: 'Không tìm thấy người dùng' });
                }
                res.status(200).json({ status_code: 200, data: results[0] });
            });
        },

        // U4 tạo tài khoản và gán vai trò (Bảng 2.4).
        async create(req, res) {
            const body = req.body || {};
            const name = requiredText(body.name, 'Vui lòng nhập họ tên', 255);
            const email = requiredText(body.email, 'Vui lòng nhập email', 255).toLowerCase();
            const password = requiredText(body.password, 'Vui lòng nhập mật khẩu', 100);
            if (password.length < 6) throw new HttpError(400, 'Mật khẩu phải có ít nhất 6 ký tự');
            const role = oneOf(body.role, ALL_ROLES, 'Vai trò không hợp lệ');
            const departmentId = body.department_id ? parseId(body.department_id, 'khoa/phòng') : null;
            if (await userRepository.findByEmail(email)) throw new HttpError(409, 'Email đã được sử dụng');
            const id = await userRepository.create({ name, email, passwordHash: hashPassword(password), role, departmentId });
            res.status(201).json({ status_code: 201, data: { id, name, email, role, department_id: departmentId } });
        },

        async update(req, res) {
            const id = parseId(req.params.id, 'người dùng');
            const body = req.body || {};
            const fields = {};
            if (body.role !== undefined) fields.role = oneOf(body.role, ALL_ROLES, 'Vai trò không hợp lệ');
            if (body.department_id !== undefined) fields.department_id = body.department_id ? parseId(body.department_id, 'khoa/phòng') : null;
            if (body.is_disabled !== undefined) fields.is_disabled = body.is_disabled ? 1 : 0;
            if (body.password !== undefined) {
                const password = requiredText(body.password, 'Mật khẩu không được để trống', 100);
                if (password.length < 6) throw new HttpError(400, 'Mật khẩu phải có ít nhất 6 ký tự');
                fields.password_hash = hashPassword(password);
            }
            const changed = await userRepository.update(id, fields);
            if (!changed) throw new HttpError(404, 'Không tìm thấy người dùng hoặc không có thay đổi');
            res.status(200).json({ status_code: 200, message: 'Đã cập nhật tài khoản' });
        }
    };
}

module.exports = createUserController;
