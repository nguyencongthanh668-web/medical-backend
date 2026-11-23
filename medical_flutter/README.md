# Medical Device Tracking (Flutter)

Ứng dụng Flutter của hệ thống quản lý thiết bị y tế: tra cứu hồ sơ thiết bị, quét mã QR, báo hỏng, ghi kết quả kiểm tra, nghiệm thu, cảnh báo bảo dưỡng. Ứng dụng gọi API của backend ở thư mục gốc repository, nên cần chạy backend trước.

## Yêu cầu

- Flutter SDK hỗ trợ Dart `^3.10.0`.
- Máy ảo hoặc điện thoại Android, hoặc trình duyệt (bản web).
- Backend đang chạy, đã tạo tài khoản demo (`npm run accounts`).

## Cách chạy

```powershell
flutter pub get
flutter run              # chọn máy ảo/điện thoại Android
flutter run -d chrome    # hoặc chạy bản web
```

**Địa chỉ máy chủ** (`lib/network/url/app_url.dart`):

| Chạy trên | Địa chỉ API mặc định |
| --- | --- |
| Máy ảo Android | `http://10.0.2.2:3000/` (trỏ về `localhost` của máy tính) |
| Web do backend phục vụ (`http://localhost:3000/`) | Cùng địa chỉ với trang |
| Web chạy ở cổng khác | `http://localhost:3000/` |
| Điện thoại thật | Nhập IP LAN của máy chạy backend ở màn hình nhập địa chỉ máy chủ, ví dụ `http://192.168.1.10:3000/` (điện thoại và máy tính cùng mạng Wi-Fi) |

**Đóng gói bản web cùng backend:** `flutter build web`, chép toàn bộ `build/web` vào thư mục `public/` của backend, khởi động lại backend và mở `http://localhost:3000/`.

**Tạo file APK:** `flutter build apk --release` (file ở `build/app/outputs/flutter-apk/`).

## Chức năng theo vai trò

Sau khi đăng nhập, ứng dụng đọc vai trò từ token và chỉ hiện nút phù hợp (máy chủ vẫn kiểm tra quyền lần nữa).

| Vai trò | Tài khoản demo | Thao tác trong ứng dụng |
| --- | --- | --- |
| U1 Khoa/Phòng | `khoa@demo.vn` | Quét QR hoặc mở thiết bị của khoa mình → **Báo hỏng** |
| U2 Kỹ thuật viên | `ktv@demo.vn` | Thiết bị đang hỏng → **Ghi kết quả kiểm tra** (tự sửa, sửa nội bộ, thuê ngoài) |
| U3 Phòng Vật tư | `vattu@demo.vn` | **Thêm thiết bị** và hiển thị mã QR; **Cảnh báo bảo dưỡng** (7/15/30 ngày); **Nghiệm thu sửa chữa** hoặc **Ghi kết quả bảo dưỡng** kèm chi phí |
| U4 Quản trị | `admin@gmail.com` | Xem danh mục; quản lý tài khoản thực hiện qua API |

Mật khẩu demo: `123456`. Mọi vai trò đều xem được danh sách thiết bị, khoa phòng, nhân viên, thông báo, thống kê và lịch sử từng thiết bị.

Khi báo hỏng, ứng dụng gửi kèm `request_id`; nếu mất mạng và gửi lại, máy chủ không tạo bản ghi trùng.

## Cấu trúc mã nguồn

| Thư mục `lib/` | Trách nhiệm |
| --- | --- |
| `screen/` | Giao diện: đăng nhập, trang chủ, danh sách và chi tiết thiết bị, quét QR, thông báo, thống kê, hồ sơ cá nhân |
| `screen/workflow/` | Biểu mẫu nghiệp vụ: thêm thiết bị, kết quả kiểm tra, nghiệm thu, cảnh báo bảo dưỡng |
| `cubit/` | Quản lý trạng thái màn hình (flutter_bloc) |
| `provider/` | Số liệu thống kê trên trang chủ (provider) |
| `features/workflow/workflow_api.dart` | Gọi các API nghiệp vụ FR-01 đến FR-06, chuyển lỗi máy chủ thành thông báo tiếng Việt |
| `features/` (khác) | Đăng nhập/đăng xuất, lưu token, ghi nhớ tài khoản, địa chỉ máy chủ, quét QR |
| `network/` | Cấu hình Dio (tự gắn `Authorization: Bearer`) và danh sách endpoint |
| `model/` | Lớp dữ liệu ánh xạ JSON từ API |
| `di/` | Đăng ký phụ thuộc (get_it) |
| `utils/`, `widget/`, `animation/` | Màu, logo, vai trò, widget dùng chung, hiệu ứng chuyển trang |

## Thư viện chính

`flutter_bloc`, `provider`, `dio`, `get_it`, `hive_flutter` (lưu địa chỉ máy chủ, phiên đăng nhập), `flutter_secure_storage`, `mobile_scanner` (quét QR), `qr_flutter` (tạo QR), `intl`, `flutter_svg`.
