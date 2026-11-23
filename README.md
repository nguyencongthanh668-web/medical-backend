# Medical Backend

Backend quản lý trang thiết bị y tế dùng Node.js, Express và MySQL, được tách từ `index.js` của [repository gốc](https://github.com/nguyencongthanh668-web/medical-backend), commit `2bb323b195a9004e4816b8c5d0eb03e24ab1cdde`.

`index.js` là điểm khởi động; mã ứng dụng nằm trong `src/` theo kiến trúc phân tầng routes → controllers → repositories (Hình 3.2 của báo cáo). Bản hiện tại hiện thực đầy đủ FR-01 đến FR-06 và phân quyền NFR-06 của báo cáo; mục 4 ghi các thay đổi so với bản tách file trước.

Repository gồm hai phần của đồ án "Hệ thống quản lý thiết bị y tế" (quy trình bảo trì QT.QLD.09.01):

| Vị trí | Nội dung |
| --- | --- |
| Thư mục gốc | Backend Node.js/Express + MySQL (tài liệu này) |
| [`medical_flutter/`](medical_flutter) | Ứng dụng Flutter (Android, web) gọi API của backend, xem [README Flutter](medical_flutter/README.md) |

## 1. Cách chạy trên Windows (XAMPP)

Yêu cầu Node.js **22 trở lên**, npm và MySQL/MariaDB của XAMPP có database `medical_device_db`. Không cần cài thêm thư viện: JWT, băm mật khẩu và bộ lập lịch dùng sẵn `node:crypto`, `setTimeout` của Node.js.

1. Bật **MySQL** trong XAMPP Control Panel (không cần Apache, server Node.js tự phục vụ API).
2. Mở thư mục `medical-backend` trong VS Code, mở terminal tại thư mục chứa `package.json`, cài thư viện:

   ```powershell
   npm ci
   ```

3. Tạo `.env` từ file mẫu rồi điền thông tin MySQL (XAMPP mặc định: `root`, mật khẩu rỗng) và một chuỗi bí mật bất kỳ cho `JWT_SECRET`:

   ```powershell
   Copy-Item .env.example .env
   ```

4. **Cập nhật cấu trúc database** (chỉ cần chạy một lần, chạy lại cũng không sao):

   ```powershell
   npm run migrate
   ```

   Lệnh thêm cột `users.role`, `users.password_hash`, các cột ngày bảo dưỡng còn thiếu và tạo ba bảng `inspection_results`, `maintenance_records`, `maintenance_alerts`. Kiểu cột khóa ngoại được lấy đúng theo bảng gốc. File `database/001_workflow_tables.sql` là bản tham khảo cùng nội dung.

5. **Tạo tài khoản demo** cho bốn vai trò (mật khẩu `123456`):

   ```powershell
   npm run accounts
   ```

   | Email | Vai trò | Được làm |
   | --- | --- | --- |
   | `khoa@demo.vn` | U1 Khoa/Phòng (`department`) | Xem thiết bị của khoa mình, báo hỏng |
   | `ktv@demo.vn` | U2 Kỹ thuật viên (`technician`) | Ghi kết quả kiểm tra sơ bộ |
   | `vattu@demo.vn` | U3 Phòng Vật tư (`manager`) | Thêm hồ sơ, cảnh báo bảo dưỡng, nghiệm thu |
   | `admin@gmail.com` | U4 Quản trị (`admin`) | Tạo tài khoản, đổi vai trò |

6. Khởi động server: `npm start` (hoặc `npm run dev` khi lập trình). Server chạy bộ quét hạn bảo dưỡng ngay khi khởi động và mỗi ngày lúc `ALERT_SCAN_HOUR` giờ.
7. (Tùy chọn) Chạy ứng dụng web cùng địa chỉ với API: trong thư mục `medical_flutter` chạy `flutter build web`, chép toàn bộ `build/web` vào `medical-backend/public/`, rồi khởi động lại server. Mở `http://localhost:3000/`, ở màn hình liên kết giữ nguyên `http://localhost:3000/` và đăng nhập bằng tài khoản ở bước 5. Khi chưa có `public/`, đường dẫn `/` trả về JSON kiểm tra sức khỏe (luôn có ở `/api/health`).

Kiểm tra: `npm run check` (cú pháp) và `npm test` (65 ca kiểm thử với database giả, không đụng dữ liệu thật).

## 2. Kiến trúc mã nguồn

| Thư mục | Trách nhiệm |
| --- | --- |
| `src/routes/` | Khai báo URL, gắn middleware phân quyền theo vai trò. |
| `src/middleware/auth.js` | Xác thực token JWT (`authenticate`) và kiểm tra vai trò (`requireRole`). |
| `src/controllers/` | Kiểm tra dữ liệu vào, điều phối nghiệp vụ, trả JSON. |
| `src/services/` | Logic dùng chung: kiểm tra quyền theo khoa, bộ quét hạn bảo dưỡng. |
| `src/repositories/` | Câu lệnh SQL cho từng bảng; nhận `db` hoặc connection của giao dịch. |
| `src/jobs/scheduler.js` | Chạy bộ quét hằng ngày, không cần thư viện cron. |
| `src/utils/` | JWT, băm mật khẩu (scrypt), giao dịch MySQL, kiểm tra dữ liệu, định dạng ngày. |
| `scripts/` | `migrate.js`, `create-accounts.js`, kiểm tra cú pháp. |
| `tests/` | Kiểm thử HTTP với database giả lập (có giả lập giao dịch). |

Mọi API trừ `POST /api/login` đều yêu cầu header `Authorization: Bearer <token>`. Lỗi trả JSON `{status_code, message}` với mã 400 (dữ liệu sai), 401 (chưa đăng nhập/hết phiên), 403 (sai quyền), 404 (không tìm thấy), 409 (xung đột trạng thái, trùng mã).

## 3. API theo yêu cầu chức năng

| Yêu cầu | Method, đường dẫn | Vai trò | Ghi chú |
| --- | --- | --- | --- |
| NFR-06 | `POST /api/login`, `POST /api/v1/logout`, `GET /api/v1/me` | Tất cả | Đăng nhập trả JWT có `role`, `department_id` |
| FR-01 | `GET /api/v1/equipments`, `GET /api/v2/equipments?page&limit&status`, `GET /api/v1/equipments/:id` | Tất cả | U1 chỉ thấy thiết bị của khoa mình |
| FR-01 | `POST /api/v1/equipments`, `PUT /api/v1/equipments/:id` | U3 | Chặn trùng mã (409); trả `qr_content` để in QR |
| FR-02 | `POST /api/v1/equipments/:id/repair` | U1 | Body `symptom`, `critical_level`, `request_id`; ghi trong một giao dịch, gửi lại cùng `request_id` không tạo bản ghi trùng |
| FR-03 | `POST`, `GET /api/v1/equipments/:id/inspection-results` | U2 (ghi) | `decision`: `self_fix`, `in_house`, `outsourced`; thiết bị chuyển `corrected` |
| FR-04 | `GET /api/v1/maintenance-alerts?days=7|15|30`, `POST /api/v1/maintenance-alerts/scan` | U3 | Mỗi mốc 30/15/7 ngày chỉ cảnh báo một lần |
| FR-05 | `GET /api/v1/equipments/:id/history` | Tất cả | Báo hỏng, kiểm tra, nghiệm thu, số lần hỏng, tổng chi phí |
| FR-06 | `PUT /api/v1/equipments/:id/acceptance` | U3 | `type` `repair`/`maintenance`, `result` `pass`/`fail`, `cost`; bảo dưỡng đạt thì cập nhật `last_maintenance` và `next_maintenance` theo thứ tự ưu tiên: ngày U3 nhập (`next_maintenance`) → chu kỳ `regular_maintenance` (tháng) → `DEFAULT_MAINTENANCE_MONTHS` (mặc định 6) |
| U4 | `POST /api/v1/users`, `PATCH /api/v1/users/:id` | U4 | Tạo tài khoản, đổi vai trò, khóa tài khoản, đặt lại mật khẩu |
| Khác | `GET /api/devices`, `/api/v1/users`, `/api/v1/departments`, `/api/v1/notification` | Tất cả | Danh mục tham chiếu |

Đường dẫn cũ vẫn chạy: `/v2/...`, số ít `/equipment/...`, `/failure`, `/equipments/repair`, `/repairs` (báo hỏng); `/inspections`, `/maintenances` trả cùng dữ liệu với `/history`.

`GET /api/v1/auto-seed` **xóa toàn bộ bảng thiết bị** để tạo dữ liệu mẫu; chỉ U4 gọi được và chỉ khi `.env` có `ALLOW_SEED=true`.

## 4. Thay đổi so với bản tách file trước

- Đăng nhập thật bằng bảng `users` (mật khẩu băm scrypt, JWT HS256 hết hạn sau `JWT_EXPIRES_HOURS`), thay cho tài khoản và token cố định.
- Phân quyền theo bốn vai trò ở mọi API; U1 bị giới hạn theo khoa.
- Báo hỏng chờ MySQL hoàn tất, ghi trạng thái và thông báo trong một giao dịch, lưu `reason`, `critical_level`, `date_failure`; trả 201 khi thành công.
- Lịch sử thiết bị lấy từ dữ liệu thật thay cho danh sách nhân viên mẫu (`src/data/demo-staff.js` không còn được dùng).
- Thêm kiểm tra sơ bộ, nghiệm thu, cảnh báo bảo dưỡng, tạo/sửa hồ sơ, quản lý tài khoản.
- Chi tiết khoa/phòng (`/departments/:id`) vẫn là dữ liệu mẫu như bản gốc; Web Push chưa làm, thông báo hiện ở màn hình Thông báo của ứng dụng.
