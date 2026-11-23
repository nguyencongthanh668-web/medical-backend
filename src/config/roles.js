// Bốn nhóm người dùng theo Bảng 2.4 của báo cáo.
const ROLES = Object.freeze({
    DEPARTMENT: 'department', // U1 Khoa/Phòng sử dụng thiết bị
    TECHNICIAN: 'technician', // U2 Kỹ thuật viên Phòng Vật tư
    MANAGER: 'manager',       // U3 Cán bộ quản lý Phòng Vật tư
    ADMIN: 'admin'            // U4 Quản trị hệ thống
});

const ALL_ROLES = Object.values(ROLES);

module.exports = { ROLES, ALL_ROLES };
