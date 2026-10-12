# Medical Backend

Hệ thống Backend quản lý trang thiết bị y tế được xây dựng trên nền tảng **Node.js, Express và MySQL**. Hệ thống cung cấp các API RESTful tương thích hoàn toàn với ứng dụng frontend (Flutter) để quản lý danh sách thiết bị, nhân viên, khoa/phòng, thông báo và quy trình bảo trì, báo hỏng.

## 1. Yêu cầu hệ thống
- **Node.js:** Phiên bản 22 trở lên.
- **npm:** Đi kèm với Node.js.
- **Cơ sở dữ liệu:** MySQL đã có sẵn database của dự án (yêu cầu phải có các bảng: `devices`, `medical_equipments`, `users`, `departments`, và `notifications`). 
*Lưu ý: Source code không tự động tạo bảng (schema) hay migration.*

## 2. Hướng dẫn cài đặt và khởi chạy

**Bước 1: Mở dự án**
Giải nén mã nguồn, mở thư mục `medical-backend` bằng VS Code. Mở Terminal trong VS Code (chọn Terminal → New Terminal) đảm bảo đang ở cùng cấp độ với file `package.json`.

**Bước 2: Cài đặt thư viện**
Chạy lệnh sau để cài đặt chính xác các phiên bản thư viện:
```bash
npm ci
```

**Bước 3: Cấu hình biến môi trường (.env)**
Tạo file `.env` từ file mẫu có sẵn. Nếu dùng PowerShell trên Windows, chạy lệnh:
```bash
Copy-Item .env.example .env
```
Mở file `.env` vừa tạo và điền thông tin kết nối MySQL của bạn:
```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=medical_device_db
DB_CONNECTION_LIMIT=10
```
*Lưu ý: Nếu mật khẩu của bạn có chứa khoảng trắng hoặc ký tự đặc biệt (như `#`), hãy đặt nó trong dấu ngoặc kép (ví dụ: `DB_PASSWORD="mat khau#vi du"`). Nếu không có file `.env`, server sẽ chạy với cấu hình mặc định.*

**Bước 4: Khởi động Server**
- Khởi động môi trường thực tế:
  ```bash
  npm start
  ```
- Khởi động môi trường phát triển (tự động khởi động lại khi có thay đổi code):
  ```bash
  npm run dev
  ```
Để dừng server và đóng kết nối database, nhấn `Ctrl + C` trong Terminal.

**Bước 5: Kiểm tra**
Mở trình duyệt truy cập `http://localhost:3000/` để kiểm tra server HTTP đã hoạt động chưa. Để kiểm tra kết nối dữ liệu thật, hãy gọi thử API `http://localhost:3000/api/v1/equipments`.

---

## 3. Cấu trúc thư mục và Kiến trúc

Dự án được tổ chức theo mô hình phân lớp rõ ràng (Routes -> Controllers -> Repositories) giúp dễ dàng bảo trì và mở rộng:

| Đường dẫn | Trách nhiệm |
| :--- | :--- |
| `index.js` | Điểm khởi chạy của ứng dụng, gọi hàm startServer(). |
| `src/server.js` | Tạo pool MySQL, mở cổng HTTP, đóng tài nguyên an toàn khi dừng. |
| `src/app.js` | Khởi tạo Express app, cấu hình CORS, JSON parser và gắn các Routes. |
| `src/config/env.js` | Đọc file `.env`, thiết lập giá trị mặc định và kiểm tra cấu hình. |
| `src/config/database.js`| Tạo pool kết nối MySQL. |
| `src/routes/` | Khai báo các API (HTTP method, URL) và định tuyến tới Controller tương ứng. |
| `src/controllers/`| Nhận Request, gọi Repository xử lý nghiệp vụ, định dạng và trả về Response. |
| `src/repositories/`| Chứa các câu lệnh SQL và thao tác trực tiếp với Database. |
| `src/formatters/` | Chuẩn hóa dữ liệu thô từ Database thành JSON đúng chuẩn cho Flutter. |
| `src/data/demo-staff.js`| Dữ liệu nhân viên tĩnh dùng cho các lịch sử mẫu. |
| `src/utils/date.js` | Các hàm tiện ích hỗ trợ định dạng ngày tháng. |
| `tests/` | Bộ kiểm thử (Testing) cho HTTP và hợp đồng dữ liệu. |
| `scripts/check-syntax.js`| Kiểm tra lỗi cú pháp JavaScript. |

---

## 4. Danh sách API

*(Ghi chú: Ký hiệu `v{1,2}` nghĩa là API hỗ trợ cả `/api/v1/...` và `/api/v2/...`. Ký hiệu `{equipment,equipments}` hỗ trợ cả số ít và số nhiều).*

| Phương thức | Endpoint | Chức năng |
| :--- | :--- | :--- |
| **GET** | `/` | Kiểm tra trạng thái server. |
| **POST** | `/api/login` | Đăng nhập hệ thống (Mẫu). |
| **POST** | `/api/v1/logout` | Đăng xuất. |
| **GET** | `/api/devices` | Lấy danh mục thiết bị từ bảng devices. |
| **GET** | `/api/v1/users` | Danh sách nhân viên (có thể lọc theo department_id). |
| **GET** | `/api/v1/users/:id` | Xem chi tiết nhân viên. |
| **GET** | `/api/v1/departments` | Lấy danh sách khoa/phòng. |
| **GET** | `/api/v{1,2}/departments/:id` | Xem chi tiết khoa/phòng. |
| **GET** | `/api/v1/notification` | Lấy danh sách thông báo. |
| **GET** | `/api/v1/equipments` | Danh sách thiết bị (trả về mảng). Hỗ trợ lọc theo `status`. |
| **GET** | `/api/v2/equipments` | Danh sách thiết bị có **phân trang**. Hỗ trợ `page`, `limit`, `status`. |
| **GET** | `/api/v1/equipment` | Alias số ít của danh sách thiết bị. |
| **GET** | `/api/v{1,2}/{equipment,equipments}/:id` | Xem chi tiết 1 thiết bị. |
| **GET** | `/api/v{1,2}/equipments/:id/inspections`| Lấy lịch sử kiểm định (Dữ liệu mẫu). |
| **GET** | `/api/v{1,2}/equipments/:id/maintenances`| Lấy lịch sử bảo trì (Dữ liệu mẫu). |
| **POST/PUT**| `/api/v{1,2}/{equipment,equipments}/:id` | Báo hỏng thiết bị. |
| **POST** | `/api/v{1,2}/{equipment,equipments}/:id/repair` | Báo hỏng thiết bị. |
| **POST** | `/api/v{1,2}/{equipment,equipments}/:id/failure`| Báo hỏng thiết bị. |
| **POST** | `/api/v{1,2}/equipments/repair` | Báo hỏng (Lấy ID thiết bị từ body request). |
| **POST** | `/api/v{1,2}/repairs` | Báo hỏng (Lấy ID thiết bị từ body request). |
| **GET** | `/api/v1/auto-seed` | **[NGUY HIỂM]** Xóa sạch DB và tạo 455 thiết bị mẫu. |

**Chi tiết về Phân trang:** 
Khi dùng `v2` và truyền tham số `?page=1`, mảng dữ liệu sẽ nằm gọn trong cấu trúc `data.data` kèm theo metadata phân trang.

---

## 5. Kiểm thử (Testing)

Hệ thống được trang bị bộ kiểm thử độc lập, không làm ảnh hưởng đến cơ sở dữ liệu thật của bạn. Bao gồm 60 test case kiểm tra cấu trúc API, xử lý lỗi, phân trang và định dạng dữ liệu.

- Chạy kiểm tra lỗi cú pháp code: 
  ```bash
  npm run check
  ```
- Chạy toàn bộ Test: 
  ```bash
  npm test
  ```

---

## 6. Các lưu ý quan trọng về Dữ liệu nghiệp vụ

- **Xác thực (Auth):** Chức năng đăng nhập hiện đang sử dụng tài khoản mẫu (`admin@gmail.com` / `123456`) và trả về token tĩnh. Hệ thống chưa áp dụng xác thực/phân quyền chặn các API.
- **Lịch sử & Khoa phòng:** Các API lấy lịch sử kiểm định/bảo trì và chi tiết khoa phòng đang sử dụng hàm sinh dữ liệu mẫu (`demo-staff.js` và ngày ngẫu nhiên) để mô phỏng hiển thị trên UI.
- **Báo hỏng:** Khi gọi API báo hỏng, hệ thống sẽ ngay lập tức cập nhật trạng thái thiết bị thành lỗi, thay đổi ngày giờ cập nhật và sinh ra một thông báo trong bảng `notifications`.
- **Cảnh báo tính năng Auto-Seed:** Endpoint `/api/v1/auto-seed` thực thi lệnh `TRUNCATE TABLE medical_equipments`. Nó sẽ xóa toàn bộ dữ liệu thiết bị hiện có và bơm lại 455 thiết bị ảo. **Chỉ gọi API này trên môi trường thử nghiệm**, tuyệt đối không dùng trên database đang chứa dữ liệu thật.
