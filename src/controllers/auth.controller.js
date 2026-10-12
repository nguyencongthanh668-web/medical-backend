// Đăng nhập minh họa được giữ từ mã nguồn gốc để Flutter tiếp tục chạy.
// Token cố định này chưa phải cơ chế xác thực cho môi trường production.
function login(req, res) {
    const { email, password } = req.body;

    if (email === 'admin@gmail.com' && password === '123456') {
        return res.status(200).json({
            status_code: 200,
            access_token: 'chuoi_token_bi_mat_cua_admin_123456',
            token_type: 'Bearer',
            data: {
                id: 1,
                displayName: 'Quản trị viên Hệ thống',
                email: 'admin@gmail.com',
                phone: '0987654321',
                birthday: '1990-01-01',
                gender: '1',
                profilePhotoUrl: 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
            }
        });
    }

    res.status(401).json({ message: 'Sai tài khoản hoặc mật khẩu' });
}

function logout(req, res) {
    res.status(200).json({ status_code: 200, message: 'Đăng xuất thành công' });
}

module.exports = { login, logout };
