# Medical Backend

Backend quản lý trang thiết bị y tế dùng Node.js, Express và MySQL, được tách từ `index.js` của [repository gốc](https://github.com/nguyencongthanh668-web/medical-backend), commit `2bb323b195a9004e4816b8c5d0eb03e24ab1cdde`.

File `index.js` trước đây có 934 dòng. Bản này giữ `index.js` làm điểm khởi động 7 dòng và chuyển mã ứng dụng vào 32 file trong `src/`. Các endpoint, tên trường và cấu trúc JSON đang dùng với Flutter được giữ tương thích, với những chỉnh sửa nhỏ được ghi ở cuối tài liệu.

## 1. Cách chạy trên Windows

Yêu cầu Node.js **22 trở lên**, npm và MySQL có database hiện tại của dự án. Không có thư viện mới được thêm vào; cấu hình `.env`, chế độ theo dõi thay đổi và bộ kiểm thử dùng tính năng có sẵn của Node.js.

1. Giải nén bản ZIP, mở thư mục `medical-backend` trong VS Code. Chọn **Terminal → New Terminal**; terminal phải đang ở thư mục chứa `package.json`.
2. Cài các phiên bản thư viện đã ghi trong lockfile:

   ```powershell
   npm ci
   ```

3. Nếu chưa có `.env`, tạo từ file mẫu bằng PowerShell:

   ```powershell
   Copy-Item .env.example .env
   ```

   Nếu đã có `.env`, giữ file đó và bổ sung các biến cần thiết. Mở `.env` để điền cấu hình MySQL của bạn:

   ```dotenv
   PORT=3000
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=medical_device_db
   DB_CONNECTION_LIMIT=10
   ```

   Mật khẩu có ký tự `#` hoặc khoảng trắng nên đặt trong dấu nháy, ví dụ `DB_PASSWORD="mat khau#vi du"`. Biến môi trường được thiết lập bên ngoài ứng dụng có độ ưu tiên cao hơn `.env`. Khi thiếu `.env`, cấu hình mặc định giống bản cũ: cổng 3000, MySQL localhost, tài khoản root, mật khẩu rỗng, database `medical_device_db`.

4. Khởi động server:

   ```powershell
   npm start
   ```

   Cách cũ `node index.js` vẫn chạy. Khi lập trình, dùng `npm run dev` để Node tự khởi động lại khi code thay đổi. Nhấn **Ctrl+C** để dừng server và đóng pool MySQL.

Mở [http://localhost:3000/](http://localhost:3000/) để kiểm tra HTTP server. Đường dẫn này không truy vấn MySQL; kiểm tra dữ liệu qua một endpoint đọc, ví dụ `/api/v1/equipments`, sau khi đã cấu hình database.

**Database:** repository gốc không có file schema SQL, migration hoặc bản sao dữ liệu. Bạn cần dùng database hiện tại với các bảng `devices`, `medical_equipments`, `users`, `departments` và `notifications`. Bản tách không tự tạo hoặc thay đổi cấu trúc database.

## 2. Vai trò các file và thư mục

| Đường dẫn | Trách nhiệm |
| --- | --- |
| `index.js` | Điểm chạy, gọi `startServer()`. |
| `src/server.js` | Tạo pool MySQL, mở cổng HTTP, đóng tài nguyên khi dừng. |
| `src/app.js` | Tạo Express app, gắn CORS, JSON parser và routes. |
| `src/config/env.js` | Đọc `.env`, đặt giá trị mặc định và kiểm tra cấu hình số. |
| `src/config/database.js` | Tạo pool kết nối MySQL. |
| `src/routes/` | Khai báo HTTP method, URL và controller tương ứng. |
| `src/controllers/` | Nhận request, gọi repository, xử lý dữ liệu và trả response. |
| `src/repositories/` | Chứa câu lệnh SQL và thao tác database. |
| `src/formatters/` | Chuyển một dòng dữ liệu thành JSON đúng định dạng Flutter. |
| `src/data/demo-staff.js` | Danh sách nhân viên cố định dùng cho lịch sử mẫu. |
| `src/utils/date.js` | Các hàm định dạng ngày dùng chung. |
| `tests/` | Kiểm thử HTTP và hợp đồng dữ liệu bằng database giả lập. |
| `scripts/check-syntax.js` | Kiểm tra cú pháp JavaScript. |
| `.env.example` | Mẫu cấu hình để sao chép thành `.env`. |

Ví dụ với danh sách thiết bị: URL nằm trong `equipment.routes.js`; cách trả phản hồi nằm trong `equipment.controller.js`; câu lệnh SQL nằm trong `equipment.repository.js`; các trường của DeviceModel nằm trong `equipment.formatter.js`.

### Các nhóm chức năng

| Chức năng | File route | File controller | File repository |
| --- | --- | --- | --- |
| Đăng nhập, đăng xuất | `auth.routes.js` | `auth.controller.js` | Chưa dùng MySQL, giữ đăng nhập mẫu. |
| Danh mục devices | `device.routes.js` | `device.controller.js` | `device.repository.js` |
| Nhân viên | `user.routes.js` | `user.controller.js` | `user.repository.js` |
| Khoa/phòng | `department.routes.js` | `department.controller.js` | `department.repository.js` |
| Thông báo | `notification.routes.js` | `notification.controller.js` | `notification.repository.js` |
| Danh sách, chi tiết thiết bị | `equipment.routes.js` | `equipment.controller.js` | `equipment.repository.js` |
| Kiểm định, bảo trì mẫu | `equipment.routes.js` | `history.controller.js` | Dùng `demo-staff.js`. |
| Báo hỏng | `equipment.routes.js` | `repair.controller.js` | Equipment và notification repositories. |
| Tạo dữ liệu mẫu | `seed.routes.js` | `seed.controller.js` | `equipment.repository.js` |

Các repository nhận `db` qua tham số và các controller nhận repository qua tham số. Nhờ vậy, ứng dụng dùng chung một pool khi chạy thật, còn bộ kiểm thử có thể thay bằng database giả mà không cần sửa code ứng dụng.

## 3. Các API được giữ lại

Trong bảng, `v{1,2}` có nghĩa là cả `v1` lẫn `v2`; `{equipment,equipments}` có nghĩa là cả cách viết số ít lẫn số nhiều. Đây là ký hiệu mô tả, không nhập nguyên dấu ngoặc vào URL.

| Method | Endpoint | Chức năng |
| --- | --- | --- |
| GET | `/` | Kiểm tra HTTP server. |
| POST | `/api/login` | Đăng nhập mẫu. |
| POST | `/api/v1/logout` | Đăng xuất. |
| GET | `/api/devices` | Danh sách từ bảng `devices`. |
| GET | `/api/v1/users` | Nhân viên; nhận `department_id`. |
| GET | `/api/v1/users/:id` | Chi tiết nhân viên. |
| GET | `/api/v1/departments` | Danh sách khoa/phòng. |
| GET | `/api/v{1,2}/departments/:id` | Chi tiết khoa/phòng mẫu. |
| GET | `/api/v1/notification` | Danh sách thông báo. |
| GET | `/api/v1/equipments` | Danh sách thiết bị dạng mảng, nhận `status`. |
| GET | `/api/v2/equipments` | Danh sách thiết bị, nhận `page`, `limit`, `status`. |
| GET | `/api/v1/equipment` | Alias số ít, giữ cấu trúc `data.data` cũ. |
| GET | `/api/v{1,2}/{equipment,equipments}/:id` | Chi tiết thiết bị. |
| GET | `/api/v{1,2}/equipments/:id/inspections` | Lịch sử kiểm định mẫu. |
| GET | `/api/v{1,2}/equipments/:id/maintenances` | Lịch sử bảo trì mẫu. |
| POST, PUT | `/api/v{1,2}/{equipment,equipments}/:id` | Báo hỏng theo API cũ. |
| POST | `/api/v{1,2}/{equipment,equipments}/:id/repair` | Báo hỏng. |
| POST | `/api/v{1,2}/{equipment,equipments}/:id/failure` | Báo hỏng. |
| POST | `/api/v{1,2}/equipments/repair` | Báo hỏng, lấy ID từ body. |
| POST | `/api/v{1,2}/repairs` | Báo hỏng, lấy ID từ body. |
| GET | `/api/v1/auto-seed` | **Xóa toàn bộ thiết bị rồi tạo 455 thiết bị mẫu.** |

V2 có `?page=1` trả cấu trúc phân trang với mảng ở `data.data`; khi không có `page`, mảng ở `data`. Kiểu số/chuỗi của các trường `status`, các trường mặc định và cách gộp `corrected`/`was_broken` giữ theo từng API gốc.

## 4. Những điểm đã sửa khi tách file

- Bỏ lần khai báo thứ hai của `GET /api/v1/departments`, vì route trước đã trả response. Giữ định dạng JSON của route thực sự được chạy.
- Bỏ các khai báo lặp `/api/v1/equipments` và `/api/v2/equipments` trong nhóm alias phía sau. Giữ riêng `/api/v1/equipment` với định dạng phản hồi cũ.
- Đặt các route POST cố định `/equipments/repair` trước `/equipments/:id`. Trước đây `repair` bị coi là ID, dẫn đến ID `null` trong JSON và không cập nhật database; bây giờ API dùng `body.id` hoặc `body.equipment_id` đúng mục đích.
- Bắt lỗi định dạng ngày ngay trong callback truy vấn chi tiết thiết bị để ngày sai trả HTTP 500 thay vì làm văng lỗi ra ngoài callback.
- Bỏ hàm định dạng ngày không được sử dụng và lần format danh sách bị lặp. Thêm `.env.example`, lệnh chạy, kiểm tra cú pháp và bộ kiểm thử.

## 5. Kiểm tra

```powershell
npm run check
npm test
```

Bộ kiểm thử có **60 test**: kiểm tra các nhóm API, định dạng đầy đủ của thiết bị, lọc trạng thái, phân trang, alias, trường hợp dữ liệu rỗng/không tồn tại, lỗi truy vấn và việc tạo dữ liệu mẫu. Các test dùng HTTP thật trên cổng local ngẫu nhiên với database giả lập, không kết nối MySQL và không tác động dữ liệu thực.

Khi thực hiện bản tách, đã đối chiếu thêm **81 tình huống** giữa code gốc tại commit nêu trên và code mới: mã HTTP, nội dung phản hồi, SQL và tham số truy vấn khớp nhau. Hai alias `/equipments/repair` được kiểm tra riêng vì đã sửa lỗi như mô tả ở trên. Chưa kiểm thử tích hợp với database và ứng dụng Flutter của bạn.

## 6. Các phần mẫu vẫn có trong code gốc

- Đăng nhập dùng tài khoản cố định `admin@gmail.com` / `123456` và token cố định; chưa có xác thực hoặc phân quyền cho các API.
- Lịch sử kiểm định/bảo trì lấy nhân viên từ danh sách cố định và tạo ngày mẫu; chi tiết khoa/phòng cũng là dữ liệu mẫu. Tách file không biến các dữ liệu này thành dữ liệu nghiệp vụ thật.
- Báo hỏng giữ cách xử lý cũ: trả thành công trước khi MySQL hoàn tất; cập nhật `status`, `updated_at` và tạo thông báo. `reason`, `critical_level`, `date_failure`, `update_day` được trả về nhưng không được lưu thành các cột thiết bị bởi câu UPDATE hiện tại.
- **Không dùng `/api/v1/auto-seed` để kiểm tra kết nối.** Endpoint này chạy `TRUNCATE TABLE medical_equipments`, xóa toàn bộ dữ liệu trong bảng rồi tạo mẫu. Chỉ dùng trên database thử nghiệm có thể xóa bỏ.

## 7. Đưa bản tách vào dự án hiện có

Giữ bản sao dự án cũ. Chép toàn bộ thư mục `src/`, `scripts/`, `tests/` và các file gốc của bản này vào thư mục backend; giữ `.env` đang chứa thông tin kết nối của bạn. Không chỉ chép riêng `index.js`, vì file này cần các module trong `src/`.

Chạy `npm ci`, `npm run check`, `npm test`, rồi `npm start`. Frontend tiếp tục dùng địa chỉ backend và các endpoint hiện tại; cập nhật địa chỉ server nếu bạn đổi `PORT` hoặc máy chủ.
