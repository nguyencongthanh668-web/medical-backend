const express = require('express');
const cors = require('cors');
const mysql = require('mysql2'); // Khai báo thư viện MySQL

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Thay thế đoạn mysql.createConnection cũ bằng createPool
const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'medical_device_db', // Điền đúng tên database của bạn
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

/*
db.connect((err) => {
    if (err) {
        console.error('Lỗi kết nối Database:', err);
        return;
    }
    console.log('Đã kết nối thành công với kho dữ liệu MySQL!');
});
*/
// 2. CÁC ĐƯỜNG DẪN API (ENDPOINTS)

// API kiểm tra trạng thái
app.get('/', (req, res) => {
    res.json({ message: "Máy chủ đang hoạt động!" });
});

// API lấy toàn bộ danh sách thiết bị
app.get('/api/devices', (req, res) => {
    const sql = "SELECT * FROM devices";
    db.query(sql, (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Lỗi truy vấn dữ liệu" });
        }
        res.json(results); // Trả mảng dữ liệu JSON về cho Flutter
    });
});
// 5. API DANH SÁCH THÔNG BÁO (TỪ DATABASE MYSQL)
app.get('/api/v1/notification', (req, res) => {
    // Sắp xếp thông báo mới nhất lên đầu
    const sql = "SELECT * FROM notifications ORDER BY created_at DESC";
    
    db.query(sql, (err, results) => {
        if (err) {
            console.error("Lỗi truy vấn thông báo:", err);
            return res.status(500).json({ status_code: 500, message: "Lỗi Server" });
        }
        
        // Node.js giúp "nhào nặn" dữ liệu phẳng từ MySQL thành cấu trúc lồng nhau cho Flutter
        const formattedData = results.map(row => {
            return {
                id: row.id,
                type: row.type,
                notifiable_id: row.notifiable_id,
                notifiable_type: row.notifiable_type,
                read_at: row.read_at,
                created_at: row.created_at,
                updated_at: row.updated_at,
                data: {
                    id: row.data_id,
                    user_id: row.data_user_id,
                    content: row.data_content
                }
            };
        });

        res.status(200).json({
            status: 1,
            total: formattedData.length,
            data: formattedData
        });
    });
});

// 6. API LẤY THÔNG TIN CÁ NHÂN (TỪ DATABASE MYSQL)
app.get('/api/v1/users/:id', (req, res) => {
    const userId = req.params.id; 
    
    // Lệnh yêu cầu MySQL tìm người dùng có id tương ứng
    const sql = "SELECT * FROM users WHERE id = ?";
    
    db.query(sql, [userId], (err, results) => {
        if (err) {
            console.error("Lỗi truy vấn:", err);
            return res.status(500).json({ status_code: 500, message: "Lỗi Server" });
        }
        
        // Nếu tìm thấy ít nhất 1 người dùng
        if (results.length > 0) {
            res.status(200).json({
                status_code: 200,
                data: results[0] // Trả về thông tin người dùng đầu tiên tìm thấy
            });
        } else {
            // Nếu không tìm thấy
            res.status(404).json({ status_code: 404, message: "Không tìm thấy người dùng" });
        }
    });
});

// 7. API LẤY DANH SÁCH KHOA PHÒNG
app.get('/api/v1/departments', (req, res) => {
    const sql = "SELECT * FROM departments";
    
    db.query(sql, (err, results) => {
        if (err) {
            console.error("Lỗi lấy danh sách khoa phòng:", err);
            return res.status(500).json({ status_code: 500, message: "Lỗi Server" });
        }
        
        // Cung cấp ĐẦY ĐỦ các trường bắt buộc theo đúng bản thiết kế DepartmentModel
        const formattedData = results.map(row => {
            return {
                id: row.id,
                title: row.title,
                
                // Các trường bắt buộc (không được null)
                code: "KHOA_" + row.id,
                slug: "khoa-phong-" + row.id,
                phone: "0243123456",
                contact: "Trưởng khoa",
                email: "contact@benhvien.com",
                address: "Khu A - Bệnh viện",
                
                // Bao vây cho cả 2 kiểu viết tên biến (camelCase và snake_case)
                userId: 1,
                user_id: 1,
                createdAt: "2026-09-22T00:00:00.000Z",
                created_at: "2026-09-22T00:00:00.000Z",
                updatedAt: "2026-09-22T00:00:00.000Z",
                updated_at: "2026-09-22T00:00:00.000Z"
            };
        });

        // Trả về cho Flutter
        res.status(200).json({
            status_code: 200,
            data: formattedData
        });
    });
});
// API LẤY DANH SÁCH NHÂN VIÊN (Chuẩn theo response mẫu)
app.get('/api/v1/users', (req, res) => {
    const departmentId = req.query.department_id; 
    let sql = "SELECT * FROM users";
    let queryParams = [];

    if (departmentId) {
        sql += " WHERE department_id = ?";
        queryParams.push(departmentId);
    }
    
    db.query(sql, queryParams, (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Lỗi Server" });
        }
        
        const formattedData = results.map(row => {
            const userName = row.name ? String(row.name) : 'User';
            const defaultAvatar = `https://ui-avatars.com/api/?name=${encodeURIComponent(userName)}&color=7F9CF5&background=EBF4FF`;
            
            return {
                id: parseInt(row.id) || 0,
                name: userName,
                email: row.email ? String(row.email) : '',
                email_verified_at: null,
                current_team_id: null,
                displayname: row.displayname ? String(row.displayname) : userName,
                image: row.profile_photo_url ? String(row.profile_photo_url) : null,
                address: row.address ? String(row.address) : null,
                birthday: row.birthday ? String(row.birthday) : null,
                phone: row.phone ? String(row.phone) : '',
                department_id: parseInt(row.department_id) || 0,
                gender: row.gender ? String(row.gender) : 'Nam',
                is_disabled: parseInt(row.is_disabled) || 0,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
                profile_photo_url: row.profile_photo_url ? String(row.profile_photo_url) : defaultAvatar
            };
        });
        
        // Trả đúng cấu trúc 2 trường ngoài cùng: data và dataLength
        res.status(200).json({
            data: formattedData,
            dataLength: formattedData.length
        });
    });
});

// API Lấy danh sách toàn bộ phòng ban
app.get('/api/v1/departments', (req, res) => {
    const sql = "SELECT * FROM departments ORDER BY id ASC";
    db.query(sql, (err, results) => {
        if (err) {
            return res.status(500).json({ error: "Lỗi Server" });
        }
        res.status(200).json({
            data: results,
            dataLength: results.length
        });
    });
});

// Hàm bọc lót dữ liệu chuẩn 100% theo DeviceModel của Flutter
const formatEquipment = (item) => ({
    id: Number(item.id) || 0,
    title: item.title || "",
    slug: item.slug || "",
    alt: item.alt || "",
    path: item.image_path || item.path || "",
    content: item.content || null, // Có thể null vì content thường là String?
    type: item.type || "jpeg",
    user_id: Number(item.user_id) || 0, 
    created_at: item.created_at || null,
    updated_at: item.updated_at || null,
    model: item.model || "",
    year_manufacture: String(item.year_manufacture || ""),
    warehouse: String(item.warehouse || ""),
    code: item.code || "",
    serial: item.serial || "",
    status: item.status || "active",
    risk: item.risk || "",
    amount: Number(item.amount) || 0,
    manufacturer: item.manufacturer || "",
    origin: item.origin || "",
    maintenance_id: Number(item.maintenance_id) || 0, 
    provider_id: Number(item.provider_id) || 0,
    repair_id: Number(item.repair_id) || 0,
    cate_id: Number(item.cate_id) || 0,
    devices_id: Number(item.devices_id) || 0,
    unit_id: Number(item.unit_id) || 0,
    department_id: Number(item.department_id) || 0,
    image: Number(item.image) || 0,
    last_inspection: item.last_inspection || null,
    next_inspection: item.next_inspection || null,
    last_maintenance: item.last_maintenance || null,
    next_maintenance: item.next_maintenance || null,
    specificat: item.specificat || null,
    first_value: Number(item.first_value) || 0,
    present_value: Number(item.present_value) || 0,
    process: item.process || "",
    year_use: String(item.year_use || ""),
    officer_charge_id: Number(item.officer_charge_id) || 0,
    officers_use_id: Number(item.officers_use_id) || 0,
    first_information: item.first_information || null,
    import_price: String(item.import_price || "0"),
    bid_project_id: Number(item.bid_project_id) || 0,
    warranty_date: item.warranty_date || null,
    configurat: item.configurat || null,
    depreciat: item.depreciat || null,
    note: item.note || "",
    officer_department_charge_id: Number(item.officer_department_charge_id) || 0,
    officers_training_id: Number(item.officers_training_id) || 0,
    supplie_id: Number(item.supplie_id) || 0,
    regular_inspection: Number(item.regular_inspection) || 0,
    regular_maintenance: Number(item.regular_maintenance) || 0,
    parent_id: Number(item.parent_id) || 0,
    date_failure: item.date_failure || null,
    reason: item.reason || "",
    critical_level: item.critical_level || "",
    date_delivery: item.date_delivery || null,
    liquidation_date: item.liquidation_date || null,
    date_person_id: Number(item.date_person_id) || 0,
    update_day: item.update_day || null,
    funding: item.funding || "",
    periodic_radiation_inspection: Number(item.periodic_radiation_inspection) || 0,
    last_radiation_inspection: item.last_radiation_inspection || null,
    next_radiation_inspection: item.next_radiation_inspection || null,
    jv_contract_termination_date: item.jv_contract_termination_date || null,
    period_of_external_quality_assessment: Number(item.period_of_external_quality_assessment) || 0,
    last_external_quality_assessment: item.last_external_quality_assessment || null,
    next_external_quality_assessment: item.next_external_quality_assessment || null,
    period_of_clinic_environment_inspection: Number(item.period_of_clinic_environment_inspection) || 0,
    last_clinic_environment_inspection: item.last_clinic_environment_inspection || null,
    next_clinic_environment_inspection: item.next_clinic_environment_inspection || null,
    period_of_license_renewal_of_radiation_work: Number(item.period_of_license_renewal_of_radiation_work) || 0,
    last_license_renewal_of_radiation_work: item.last_license_renewal_of_radiation_work || null,
    next_license_renewal_of_radiation_work: item.next_license_renewal_of_radiation_work || null,
    hash_code: item.hash_code || item.code || "",
    
    // Đề phòng Flutter bắt buộc phải có các object con (như hiển thị ở log cũ)
    department: {
        id: Number(item.department_id) || 0,
        title: "Khoa phòng"
    },
    equipment_img: {
        id: Number(item.image) || 0,
        path: item.image_path || item.path || ""
    },
    device: {
        id: Number(item.devices_id) || 0,
        cate_id: Number(item.cate_id) || 0,
        unit_id: Number(item.unit_id) || 0,
        title: item.title || ""
    },
    unit: {
        id: Number(item.unit_id) || 0,
        title: "Cái"
    }
});

// HÀM FORMAT DATE CHUẨN XÁC
function formatDateTime(val) {
    if (!val) return null;
    const d = new Date(val);
    if (isNaN(d.getTime())) return typeof val === 'string' ? val : null;
    const pad = n => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

// 1. ROUTE V1 DÀNH RIÊNG CHO TRANG TỔNG QUAN
app.get('/api/v1/equipments', (req, res) => {
    try {
        let whereClauses = [];
        let queryParams = [];
        const status = req.query.status;

        // Xử lý chuẩn xác trạng thái giữa Flutter và Database
        if (status && status !== 'all' && status !== '') {
            if (status === 'corrected' || status === 'was_broken') {
                whereClauses.push("(status = 'corrected' OR status = 'was_broken')");
            } else if (status === 'active') {
                whereClauses.push("status = 'active'");
            } else {
                whereClauses.push("status = ?");
                queryParams.push(status);
            }
        }

        const whereSql = whereClauses.length > 0 ? " WHERE " + whereClauses.join(" AND ") : "";
        const fetchSql = `SELECT * FROM medical_equipments ${whereSql} ORDER BY updated_at DESC, id DESC`;

        db.query(fetchSql, queryParams, (err, results) => {
            if (err) {
                console.error("Lỗi query equipments v1:", err);
                return res.status(500).json({ status: "500", message: err.message });
            }

            const rawList = results || [];

           // Bổ sung đầy đủ các cột và object lồng nhau để Flutter parse thành công
           const formattedList = rawList.map(formatEquipment);

// 1. Chỉ cần một bước làm sạch này là đủ
    const formattedResults = (results || []).map(formatEquipment);

    // 2. Trả về cấu trúc phẳng, data trỏ thẳng vào mảng
    return res.status(200).json({
        status: "200",
        status_code: 200,
        success: true,
        // Bắt buộc data phải là Array để không bị lỗi _JsonMap
        data: formattedResults, 
        
        // Cứ quăng thêm total ra ngoài cho chắc ăn, nếu Flutter cần
        total: formattedResults.length,
        dataLength: formattedResults.length
    });
        });
    } catch (e) {
        console.error("Lỗi server v1:", e);
        return res.status(500).json({ status: "500", message: e.message });
    }
});
// 2. ROUTE V2 DÀNH CHO MÀN HÌNH DANH SÁCH CÓ PHÂN TRANG
app.get('/api/v2/equipments', (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 15;
        const offset = (page - 1) * limit;

        let whereClauses = [];
        let queryParams = [];

        if (req.query.status && req.query.status !== 'all' && req.query.status !== '') {
            if (req.query.status === 'corrected') {
                whereClauses.push("(status = 'corrected' OR status = 'was_broken')");
            } else {
                whereClauses.push("status = ?");
                queryParams.push(req.query.status);
            }
        }

        const whereSql = whereClauses.length > 0 ? " WHERE " + whereClauses.join(" AND ") : "";

        db.query(`SELECT COUNT(*) AS total FROM medical_equipments ${whereSql}`, queryParams, (errCount, countResults) => {
            if (errCount) return res.status(500).json({ status: "500", message: errCount.message });

            const total = countResults[0].total;
            const fetchSql = `SELECT * FROM medical_equipments ${whereSql} ORDER BY updated_at DESC, id DESC LIMIT ? OFFSET ?`;

            db.query(fetchSql, [...queryParams, limit, offset], (errList, results) => {
                if (errList) return res.status(500).json({ status: "500", message: errList.message });

const formattedList = (results || []).map(formatEquipment);

                const baseUrlStr = `${req.protocol}://${req.get('host')}/api/v2/equipments`;

        // Nếu request đến từ Dashboard (gọi /api/v1/ hoặc không truyền ?page=)
        const isDashboard = req.originalUrl.includes('/api/v1') || !req.query.page;

        if (isDashboard) {
            // Trả về đúng mảng data: [...] chuẩn theo web mẫu để Dashboard đếm số lượng
            return res.status(200).json({
    status: "200",
    data: formattedList,
    // Thêm các trường phân trang giả để Dashboard đếm được số lượng
    total: formattedList.length,
    per_page: formattedList.length || 15,
    current_page: 1,
    last_page: 1,
    from: 1,
    to: formattedList.length
});
        }

        // Dành cho màn hình danh sách thiết bị có phân trang (?page=1...)
        return res.status(200).json({
            status: "200",
            status_code: 200,
            total: total,
            data: {
                total: total,
                current_page: page,
                data: formattedList,
                first_page_url: `${baseUrlStr}?page=1`,
                from: total > 0 ? offset + 1 : 0,
                next_page_url: (offset + limit < total) ? `${baseUrlStr}?page=${page + 1}` : null,
                path: baseUrlStr,
                per_page: limit,
                prev_page_url: page > 1 ? `${baseUrlStr}?page=${page - 1}` : null,
                to: Math.min(offset + limit, total)
            },
            dataLength: formattedList.length
        });
            });
        });
    } catch (e) {
        return res.status(500).json({ status: "500", message: e.message });
    }
});

// API LẤY LỊCH SỬ KIỂM ĐỊNH / BẢO TRÌ CHO TIMELINE CHI TIẾT
app.get([
    '/api/v1/equipments/:id/inspections',
    '/api/v2/equipments/:id/inspections',
    '/api/v1/equipments/:id/maintenances',
    '/api/v2/equipments/:id/maintenances'
], (req, res) => {
    try {
        const id = req.params.id;
        const now = new Date();
        
        const pastDate = new Date(now);
        pastDate.setMonth(now.getMonth() - 2);
        
        const futureDate = new Date(now);
        futureDate.setMonth(now.getMonth() + 4);

        // Chuẩn ngày tháng gốc của bạn (YYYY-MM-DD)
        const formatDate = (d) => d.toISOString().split('T')[0];
        const lastMaint = formatDate(pastDate);
        const nextMaint = formatDate(futureDate);

        // Lấy 2 nhân viên ngẫu nhiên từ danh sách thực tế của bạn
        const staff1 = realStaffList[Math.floor(Math.random() * realStaffList.length)];
        const staff2 = realStaffList[Math.floor(Math.random() * realStaffList.length)];

        const inspectionList = [
            {
                id: 1,
                equipment_id: Number(id),
                title: "Kiểm tra định kỳ",
                type: "inspection",
                time: lastMaint,
                date: lastMaint,
                created_at: lastMaint,
                last_inspection: lastMaint,
                next_inspection: nextMaint,
                status: 1,
                person: staff1.name,
                user_name: staff1.name,
                user_id: staff1.id,
                user: {
                    id: staff1.id, name: staff1.name, code: staff1.code,
                    display_name: `${staff1.name} (${staff1.code})`,
                    email: staff1.email, phone: staff1.phone
                }
            },
            {
                id: 2,
                equipment_id: Number(id),
                title: "Kiểm tra định kỳ",
                type: "inspection",
                time: nextMaint,
                date: nextMaint,
                created_at: nextMaint,
                last_inspection: lastMaint,
                next_inspection: nextMaint,
                status: 0,
                person: staff2.name,
                user_name: staff2.name,
                user_id: staff2.id,
                user: {
                    id: staff2.id, name: staff2.name, code: staff2.code,
                    display_name: `${staff2.name} (${staff2.code})`,
                    email: staff2.email, phone: staff2.phone
                }
            }
        ];

        return res.status(200).json({
            status: "200",
            status_code: 200, // <--- ĐÃ THÊM DÒNG NÀY ĐỂ FLUTTER CHỊU ĐỌC DỮ LIỆU
            message: "Thành công",
            data: inspectionList
        });
    } catch (err) {
        console.error("Lỗi lấy lịch sử kiểm định:", err);
        return res.status(500).json({ status_code: 500, message: err.message });
    }
});

// DANH SÁCH NHÂN VIÊN THỰC TẾ LẤY CHUẨN XÁC TỪ CƠ SỞ DỮ LIỆU
const realStaffList = [
    { id: 5, code: "user5", name: "Hoàng Văn Nam", email: "user5@gmail.com", phone: "0935808880" },
    { id: 6, code: "user6", name: "Hoàng Hồng Linh", email: "user6@gmail.com", phone: "0963203366" },
    { id: 7, code: "user7", name: "Trần Văn Khoa", email: "user7@gmail.com", phone: "0978236187" },
    { id: 8, code: "user8", name: "Trần Thanh Linh", email: "user8@gmail.com", phone: "0915540404" },
    { id: 9, code: "user9", name: "Bùi Thị Bình", email: "user9@gmail.com", phone: "0993228218" },
    { id: 10, code: "user10", name: "Phạm Thị Khoa", email: "user10@gmail.com", phone: "0918507085" },
    { id: 11, code: "user11", name: "Lê Đức Hải", email: "user11@gmail.com", phone: "0996445470" },
    { id: 12, code: "user12", name: "Vũ Thanh Bình", email: "user12@gmail.com", phone: "0981723272" },
    { id: 13, code: "user13", name: "Hoàng Quốc Cường", email: "user13@gmail.com", phone: "0918999994" },
    { id: 14, code: "user14", name: "Lê Thị Nam", email: "user14@gmail.com", phone: "0997413838" },
    { id: 15, code: "user15", name: "Đỗ Thị Nam", email: "user15@gmail.com", phone: "0973947883" },
    { id: 16, code: "user16", name: "Vũ Hồng Nam", email: "user16@gmail.com", phone: "0973603875" },
    { id: 17, code: "user17", name: "Hoàng Thanh Tuấn", email: "user17@gmail.com", phone: "0956351654" },
    { id: 18, code: "user18", name: "Bùi Hồng Bình", email: "user18@gmail.com", phone: "0966704280" },
    { id: 19, code: "user19", name: "Bùi Minh Bình", email: "user19@gmail.com", phone: "0915084970" },
    { id: 20, code: "user20", name: "Phạm Thanh Bình", email: "user20@gmail.com", phone: "0971098806" },
    { id: 21, code: "user21", name: "Nguyễn Đức Dũng", email: "user21@gmail.com", phone: "0965008891" },
    { id: 34, code: "user34", name: "Bùi Quốc Phương", email: "user34@gmail.com", phone: "0950009402" },
    { id: 35, code: "user35", name: "Nguyễn Minh Thảo", email: "user35@gmail.com", phone: "0979591388" },
    { id: 36, code: "user36", name: "Phạm Hồng An", email: "user36@gmail.com", phone: "0949085485" },
    { id: 37, code: "user37", name: "Phạm Ngọc An", email: "user37@gmail.com", phone: "0989419856" },
    { id: 38, code: "user38", name: "Lê Văn Cường", email: "user38@gmail.com", phone: "0995087277" },
    { id: 39, code: "user39", name: "Nguyễn Quốc Nam", email: "user39@gmail.com", phone: "0971928447" },
    { id: 40, code: "user40", name: "Phạm Đức Bình", email: "user40@gmail.com", phone: "0969388807" },
    { id: 41, code: "user41", name: "Nguyễn Đức Bình", email: "user41@gmail.com", phone: "0974157646" },
    { id: 42, code: "user42", name: "Phạm Thanh Hương", email: "user42@gmail.com", phone: "0915580073" },
    { id: 43, code: "user43", name: "Phạm Ngọc Tuấn", email: "user43@gmail.com", phone: "0937196521" },
    { id: 44, code: "user44", name: "Nguyễn Ngọc Linh", email: "user44@gmail.com", phone: "0996421913" },
    { id: 45, code: "user45", name: "Bùi Minh Hương", email: "user45@gmail.com", phone: "0959798764" },
    { id: 46, code: "user46", name: "Vũ Thanh Cường", email: "user46@gmail.com", phone: "0900802146" },
    { id: 47, code: "user47", name: "Phạm Đức An", email: "user47@gmail.com", phone: "0931437154" },
    { id: 48, code: "user48", name: "Phạm Ngọc Nam", email: "user48@gmail.com", phone: "0917970922" },
    { id: 81, code: "user81", name: "Vũ Thị An", email: "user81@gmail.com", phone: "0964784418" },
    { id: 82, code: "user82", name: "Nguyễn Văn Hải", email: "user82@gmail.com", phone: "0981072813" },
    { id: 83, code: "user83", name: "Đỗ Thanh Nam", email: "user83@gmail.com", phone: "0960437981" },
    { id: 84, code: "user84", name: "Bùi Minh Hương", email: "user84@gmail.com", phone: "0963330470" },
    { id: 85, code: "user85", name: "Đỗ Ngọc Khoa", email: "user85@gmail.com", phone: "0926875685" },
    { id: 86, code: "user86", name: "Đỗ Đức Cường", email: "user86@gmail.com", phone: "0988592680" },
    { id: 87, code: "user87", name: "Bùi Minh Khoa", email: "user87@gmail.com", phone: "0910359573" },
    { id: 88, code: "user88", name: "Bùi Đức Tuấn", email: "user88@gmail.com", phone: "0977327320" },
    { id: 89, code: "user89", name: "Bùi Quốc Nam", email: "user89@gmail.com", phone: "0984146151" },
    { id: 90, code: "user90", name: "Trần Đức Cường", email: "user90@gmail.com", phone: "0998617903" },
    { id: 91, code: "user91", name: "Lê Thanh Cường", email: "user91@gmail.com", phone: "0910103293" },
    { id: 92, code: "user92", name: "Bùi Thị Khoa", email: "user92@gmail.com", phone: "0977380483" },
    { id: 93, code: "user93", name: "Lê Ngọc Hải", email: "user93@gmail.com", phone: "0923139983" },
    { id: 94, code: "user94", name: "Trần Văn Phương", email: "user94@gmail.com", phone: "0969196112" },
    { id: 95, code: "user95", name: "Trần Minh Hải", email: "user95@gmail.com", phone: "0959928820" },
    { id: 96, code: "user96", name: "Đỗ Đức Dũng", email: "user96@gmail.com", phone: "0950700938" },
    { id: 97, code: "user97", name: "Hoàng Đức Bình", email: "user97@gmail.com", phone: "0936188144" },
    { id: 98, code: "user98", name: "Hoàng Quốc Hải", email: "user98@gmail.com", phone: "0905758428" },
    { id: 99, code: "user99", name: "Trần Thanh Bình", email: "user99@gmail.com", phone: "0943902184" },
    { id: 100, code: "user100", name: "Đỗ Thanh Cường", email: "user100@gmail.com", phone: "0992017342" }
];

// API CHI TIẾT THIẾT BỊ KHỚP CHUẨN NHÂN VIÊN VÀ NGÀY THỰC TẾ
app.get(['/api/v1/equipments/:id', '/api/v2/equipments/:id', '/api/v1/equipment/:id', '/api/v2/equipment/:id'], (req, res) => {
    try {
        const id = req.params.id;
        const sql = "SELECT * FROM medical_equipments WHERE id = ?";
        
        db.query(sql, [id], (err, results) => {
            if (err) {
                console.error("Lỗi lấy chi tiết thiết bị:", err);
                return res.status(500).json({ status_code: 500, message: err.message });
            }
            if (!results || results.length === 0) {
                return res.status(404).json({ status_code: 404, message: "Không tìm thấy thiết bị" });
            }

            const item = results[0];

           const detailData = typeof formatEquipment === 'function' ? formatEquipment(item) : item;

// --- ĐOẠN FIX LỖI: Ép ngày tháng từ Database về chuẩn YYYY-MM-DD ---
const dateFields = ['last_inspection', 'next_inspection', 'last_maintenance', 'next_maintenance', 'created_at', 'updated_at', 'warranty_date'];
dateFields.forEach(field => {
    // Đã thay item thành detailData ở các vị trí dưới đây
    if (detailData[field]) {
        // Cắt bỏ phần giờ phút giây, chỉ lấy đúng YYYY-MM-DD
        detailData[field] = new Date(detailData[field]).toISOString().split('T')[0]; 
    }
});
            // -------------------------------------------------------------------

            

            return res.status(200).json({
                status: "200",
                message: "Thành công",
                data: detailData
            });
        });
    } catch (error) {
        return res.status(500).json({ status_code: 500, message: error.message });
    }
});

// DÁN ĐOẠN ROUTE LẤY DANH SÁCH THIẾT BỊ VÀO ĐÂY:
app.get(['/api/v1/equipments', '/api/v1/equipment', '/api/v2/equipments'], (req, res) => {
    try {
        let sql = "SELECT * FROM medical_equipments WHERE 1=1";
        const params = [];

        if (req.query.status) {
            sql += " AND status = ?";
            params.push(req.query.status);
        }

        sql += " ORDER BY updated_at DESC, id DESC";

        db.query(sql, params, (err, results) => {
            if (err) {
                console.error("Lỗi lấy danh sách thiết bị:", err);
                return res.status(500).json({ status_code: 500, message: "Lỗi truy vấn cơ sở dữ liệu" });
            }

            const formattedResults = (results || []).map(formatEquipment);
            const totalCount = formattedResults.length;
           return res.status(200).json({
            status_code: 200,
            status: 200,
            success: true,
            total: totalCount,
            data: {
                total: totalCount,
                current_page: 1,
                per_page: totalCount || 15,
                data: formattedResults, // <-- Mảng thiết bị nằm bên trong 1 lớp data nữa
                from: 1,
                to: totalCount
            }
        });
        });
    } catch (e) {
        console.error("Lỗi danh sách thiết bị:", e);
        return res.status(500).json({ status_code: 500, message: e.message });
    }
});

// ==========================================
// CÁC ROUTE TIẾP NHẬN BÁO HỎNG / BÁO SỬA CHỮA
// ==========================================

const handleRepairSuccess = (req, res) => {
    try {
        const body = req.body || {};
        const rawId = req.params.id || body.id || body.equipment_id;
        const id = Number(rawId);
        const now = new Date();
        const isoTime = now.toISOString().replace('Z', '000Z');
        const formatDate = (d) => d.toISOString().split('T')[0];
        const formatDateTime = (d) => d.toISOString().replace('T', ' ').substring(0, 19);

        const criticalLevel = body.critical_level || "Cần sửa";
        const reason = body.reason || "Báo hỏng từ ứng dụng";

        console.log(`[Báo hỏng] Đang xử lý cho thiết bị ID: ${id}`);

        if (id) {
           // 1. Cập nhật dứt điểm trạng thái và thời gian cập nhật mới nhất
            db.query(
                "UPDATE medical_equipments SET status = 'was_broken', updated_at = NOW() WHERE id = ?",
                [id],
                (err, updateRes) => {
                    if (err) {
                        console.error("Lỗi cập nhật trạng thái thiết bị:", err.message);
                    } else {
                        console.log(`[Báo hỏng] Đã đổi status = 'was_broken' cho thiết bị ${id}`);
                    }
                }
            );

            // 2. Thêm thông báo vào bảng notifications
            db.query("SELECT title, code FROM medical_equipments WHERE id = ?", [id], (err, eqResults) => {
                const eqTitle = (eqResults && eqResults.length > 0) ? (eqResults[0].title || "Thiết bị") : "Thiết bị";
                const notifId = 'notif_' + Math.random().toString(36).substring(2, 11) + '_' + Date.now();
                const content = `Thiết bị ${eqTitle} đã được báo hỏng. Mức độ quan trọng: ${criticalLevel}`;

                const sqlInsertNotif = `
                    INSERT INTO notifications 
                    (id, type, notifiable_id, notifiable_type, read_at, created_at, updated_at, data_id, data_user_id, data_content)
                    VALUES (?, 'App\\\\Notifications\\\\ReportFailureNotifications', 267, 'App\\\\Models\\\\User', NULL, ?, ?, ?, 267, ?)
                `;

                db.query(sqlInsertNotif, [notifId, isoTime, isoTime, id, content], (notifErr) => {
                    if (notifErr) console.error("Lỗi thêm thông báo:", notifErr);
                });
            });
        }

        return res.status(200).json({
            status_code: 200,
            status: "200",
            success: true,
            message: "Báo hỏng thành công",
            data: {
                id: id,
                status: "was_broken",
                date_failure: formatDateTime(now),
                reason: reason,
                critical_level: criticalLevel,
                update_day: formatDate(now)
            }
        });
    } catch (e) {
        console.error("Lỗi xử lý báo hỏng:", e);
        return res.status(500).json({ status_code: 500, message: e.message });
    }
};

// Đăng ký cả dạng số ít (/equipment/:id) và số nhiều (/equipments/:id)
app.post([
    '/api/v1/equipment/:id',        // <-- ĐÂY CHÍNH LÀ ĐƯỜNG DẪN FLUTTER ĐANG GỌI!
    '/api/v2/equipment/:id',
    '/api/v1/equipments/:id',
    '/api/v2/equipments/:id',
    '/api/v1/equipments/:id/repair',
    '/api/v2/equipments/:id/repair',
    '/api/v1/equipment/:id/repair',
    '/api/v2/equipment/:id/repair',
    '/api/v1/equipments/:id/failure',
    '/api/v2/equipments/:id/failure',
    '/api/v1/equipment/:id/failure',
    '/api/v2/equipment/:id/failure',
    '/api/v1/equipments/repair',
    '/api/v2/equipments/repair',
    '/api/v1/repairs',
    '/api/v2/repairs'
], handleRepairSuccess);

app.put([
    '/api/v1/equipment/:id',
    '/api/v2/equipment/:id',
    '/api/v1/equipments/:id',
    '/api/v2/equipments/:id'
], handleRepairSuccess);

// ========================================================
// API TỐI THƯỢNG: LÀM ĐẸP TOÀN BỘ DỮ LIỆU ĐỂ NỘP BÀI
// ========================================================
// ========================================================
// API SIÊU CẤP: TẠO GỐC -> NHÂN BẢN -> XÓA CHỮ CLONE
// ========================================================
// ========================================================
// API SIÊU CẤP: TẠO GỐC -> NHÂN BẢN (PHIÊN BẢN CHỐNG LỖI 100%)
// ========================================================
app.get('/api/v1/auto-seed', (req, res) => {
    
    const sampleDevices = [
        "Máy X-Quang kỹ thuật số VIKOMED", "Máy siêu âm 4D", 
        "Máy đo điện tim 3 kênh", "Monitor theo dõi bệnh nhân", "Máy thở chức năng cao"
    ];

    const randomDate = (yearsBack) => {
        const date = new Date();
        date.setDate(date.getDate() - Math.floor(Math.random() * (yearsBack * 365)));
        return date.toISOString().slice(0, 19).replace('T', ' '); 
    };

    // 1. Xóa sạch DB trước
    db.query("TRUNCATE TABLE medical_equipments", (err) => {
        if (err) return res.status(500).send("Lỗi dọn rác DB: " + err.message);

        let insertedCount = 0;
        let hasError = false;

        sampleDevices.forEach((title, index) => {
            // Đã bổ sung cột serial, status để chống lỗi thiếu field bắt buộc MySQL
            const sql = `INSERT INTO medical_equipments (title, serial, status, last_inspection, next_inspection, last_maintenance, next_maintenance) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            const vals = [
                title, 
                'SN-GOC-' + index, // Sinh serial mẫu
                'active',          // Sinh trạng thái mẫu
                randomDate(2), randomDate(-1), randomDate(1), randomDate(-0.5)
            ];
            
            db.query(sql, vals, (err) => {
                if (err) {
                    console.error("Lỗi chèn máy gốc:", err);
                    hasError = true;
                }
                insertedCount++;
                if (insertedCount === sampleDevices.length) {
                    if (hasError) return res.status(500).send("Thêm máy gốc thất bại! Hãy xem log trên Terminal Node.js để biết bảng DB đang thiếu cột gì.");
                    cloneEquipments();
                }
            });
        });
    });

    function cloneEquipments() {
        db.query("SELECT * FROM medical_equipments", (err, results) => {
            if (err) return res.status(500).send("Lỗi đọc dữ liệu: " + err.message);
            // Fix triệt để lỗi Cannot convert undefined to object
            if (!results || results.length === 0) return res.status(500).send("Không có thiết bị gốc nào để nhân bản!");

            const totalClones = 450; 
            const keys = Object.keys(results[0]).filter(k => k !== 'id');
            const values = [];

            for (let i = 0; i < totalClones; i++) {
                const sample = results[Math.floor(Math.random() * results.length)];
                const clone = { ...sample };
                delete clone.id; 

                clone.title = sample.title;
                clone.serial = `SN-${Date.now().toString().slice(-4)}-${i}`;

                const randStatus = Math.random();
                if (randStatus < 0.08) clone.status = 'was_broken';
                else if (randStatus < 0.20) clone.status = 'corrected';
                else clone.status = 'active';

                clone.last_inspection = randomDate(2);       
                clone.next_inspection = randomDate(-1);      
                clone.last_maintenance = randomDate(1);      
                clone.next_maintenance = randomDate(-0.5);   

                // Chỉ điền created_at nếu bảng của bạn thực sự có cột đó
                if (keys.includes('created_at')) clone.created_at = randomDate(3);            
                if (keys.includes('updated_at')) clone.updated_at = new Date().toISOString().slice(0, 19).replace('T', ' '); 

                const row = keys.map(k => clone[k] !== undefined ? clone[k] : null);
                values.push(row);
            }

            const insertSql = `INSERT INTO medical_equipments (${keys.join(', ')}) VALUES ?`;
            db.query(insertSql, [values], (err, insertResult) => {
                if (err) {
                    console.error("Lỗi nhân bản:", err);
                    return res.status(500).json({ message: "Lỗi nhân bản", error: err.message });
                }
                
                res.send(`
                    <h1 style="color: green;">🎉 THÀNH CÔNG RỰC RỠ!</h1>
                    <p>Đã dọn dẹp sạch sẽ và tạo mới <b>${insertResult.affectedRows + sampleDevices.length}</b> thiết bị.</p>
                    <h3>👉 Bây giờ hãy mở ứng dụng Flutter và tận hưởng thành quả!</h3>
                `);
            });
        });
    }
});

// MOCK API: Trả về dữ liệu Khoa/Phòng để Flutter không bị lỗi 404
app.get(['/api/v1/departments/:id', '/api/v2/departments/:id'], (req, res) => {
    const id = req.params.id;
    return res.status(200).json({
        status_code: 200,
        success: true,
        data: {
            id: Number(id),
            title: `Khoa phòng số ${id}`,
            name: `Khoa phòng số ${id}`,
            display_name: `Khoa phòng số ${id}`
        }
    });
});

// 3. KHỞI ĐỘNG MÁY CHỦ
app.listen(port, () => {
    console.log(`Server đang chạy tại http://localhost:${port}`);
});

// 4. API ĐĂNG NHẬP (LOGIN)
// Lưu ý: Đường dẫn này có thể là '/api/login' hoặc tương tự tùy thuộc vào biến loginUrl của Flutter
app.post('/api/login', (req, res) => {
    // Nhận email và password từ Flutter gửi lên
    const { email, password } = req.body;

    // Tạo một tài khoản Admin cứng để bạn dễ dàng test ứng dụng
    if (email === 'admin@gmail.com' && password === '123456') {
        // Trả về đúng cấu trúc JSON mà Flutter đang cần
        // Đổi lại cấu trúc JSON trả về để khớp hoàn toàn với AuthResponse của Flutter
res.status(200).json({
    status_code: 200,                                     // Bổ sung số nguyên bị thiếu
    access_token: "chuoi_token_bi_mat_cua_admin_123456",  // Đổi tên biến cho khớp
    token_type: "Bearer",                                 // Bổ sung biến loại token
    data: {
        id: 1,                     
        displayName: "Quản trị viên Hệ thống",
        email: "admin@gmail.com",
        phone: "0987654321",
        birthday: "1990-01-01",
        gender: "1",               
        profilePhotoUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png"
    }
});
    } else {
        // Trả về lỗi nếu nhập sai
        res.status(401).json({ message: "Sai tài khoản hoặc mật khẩu" });
    }
});

// 8. API ĐĂNG XUẤT
app.post('/api/v1/logout', (req, res) => {
    res.status(200).json({
        status_code: 200,
        message: "Đăng xuất thành công"
    });
});