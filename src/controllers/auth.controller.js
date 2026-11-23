const config = require('../config/env');
const { ROLES, ALL_ROLES } = require('../config/roles');
const { sign } = require('../utils/jwt');
const { verifyPassword } = require('../utils/password');

// Đăng nhập bằng tài khoản trong bảng users (NFR-06). Mật khẩu so khớp với password_hash (scrypt).
function createAuthController(userRepository) {
    async function login(req, res) {
        const { email, password } = req.body || {};
        if (!email || !password) {
            return res.status(400).json({ status_code: 400, message: 'Vui lòng nhập email và mật khẩu' });
        }

        const user = await userRepository.findByEmail(String(email).trim());
        const valid = user && Number(user.is_disabled) !== 1 && verifyPassword(password, user.password_hash);
        if (!valid) return res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });

        const role = ALL_ROLES.includes(user.role) ? user.role : ROLES.DEPARTMENT;
        const name = user.displayname || user.name || user.email;
        const departmentId = user.department_id != null ? Number(user.department_id) : null;
        const token = sign({ sub: Number(user.id), role, department_id: departmentId, name },
            config.jwt.secret, config.jwt.expiresInSeconds);

        res.status(200).json({
            status_code: 200,
            access_token: token,
            token_type: 'Bearer',
            expires_in: config.jwt.expiresInSeconds,
            data: {
                id: Number(user.id),
                displayName: name,
                email: user.email,
                phone: user.phone || '',
                birthday: user.birthday ? String(user.birthday) : '',
                gender: user.gender != null ? String(user.gender) : '',
                profilePhotoUrl: user.profile_photo_url || '',
                role,
                department_id: departmentId
            }
        });
    }

    // Token không lưu ở máy chủ; ứng dụng xóa token khi đăng xuất, token cũ tự hết hạn.
    function logout(req, res) {
        res.status(200).json({ status_code: 200, message: 'Đăng xuất thành công' });
    }

    function me(req, res) {
        res.status(200).json({ status_code: 200, data: req.user });
    }

    return { login, logout, me };
}

module.exports = createAuthController;
