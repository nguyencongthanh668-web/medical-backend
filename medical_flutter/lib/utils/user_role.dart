/// Bốn nhóm người dùng theo ma trận quyền (Bảng 2.4); giá trị khớp cột users.role ở máy chủ.
class UserRole {
  static const String department = 'department'; // U1 Khoa/Phòng sử dụng
  static const String technician = 'technician'; // U2 Kỹ thuật viên
  static const String manager = 'manager'; // U3 Cán bộ quản lý Phòng Vật tư
  static const String admin = 'admin'; // U4 Quản trị hệ thống

  static String label(String? role) {
    switch (role) {
      case department:
        return 'Khoa/Phòng sử dụng';
      case technician:
        return 'Kỹ thuật viên';
      case manager:
        return 'Cán bộ Phòng Vật tư';
      case admin:
        return 'Quản trị hệ thống';
      default:
        return 'Chưa xác định';
    }
  }
}
