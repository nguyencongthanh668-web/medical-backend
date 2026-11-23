const { query } = require('../utils/db');

// V1 gộp cả corrected và was_broken; V2 chỉ gộp khi lọc corrected.
// Giữ quy tắc này để các màn hình Flutter tiếp tục nhận dữ liệu như trước.
function buildStatusClause(status, version) {
    if (!status || status === 'all') return { clause: '', params: [] };

    if (status === 'corrected' || (version === 1 && status === 'was_broken')) {
        return { clause: "(status = 'corrected' OR status = 'was_broken')", params: [] };
    }
    if (version === 1 && status === 'active') {
        return { clause: "status = 'active'", params: [] };
    }
    return { clause: 'status = ?', params: [status] };
}

// departmentId chỉ được truyền khi người dùng là U1: chỉ thấy thiết bị của khoa mình (Bảng 2.4).
function buildStatusFilter(status, version, departmentId) {
    const { clause, params } = buildStatusClause(status, version);
    const clauses = clause ? [clause] : [];
    if (departmentId != null) {
        clauses.push('department_id = ?');
        params.push(departmentId);
    }
    return { where: clauses.length ? ` WHERE ${clauses.join(' AND ')}` : '', params };
}

const EDITABLE_FIELDS = ['title', 'code', 'serial', 'model', 'manufacturer', 'devices_id', 'department_id',
    'regular_maintenance', 'last_maintenance', 'next_maintenance', 'next_inspection', 'status'];

function createEquipmentRepository(db) {
    return {
        findAllV1(status, callback, departmentId = null) {
            const { where, params } = buildStatusFilter(status, 1, departmentId);
            db.query(`SELECT * FROM medical_equipments ${where} ORDER BY updated_at DESC, id DESC`, params, callback);
        },

        countV2(status, callback, departmentId = null) {
            const { where, params } = buildStatusFilter(status, 2, departmentId);
            db.query(`SELECT COUNT(*) AS total FROM medical_equipments ${where}`, params, callback);
        },

        findPageV2({ status, limit, offset, departmentId = null }, callback) {
            const { where, params } = buildStatusFilter(status, 2, departmentId);
            const sql = `SELECT * FROM medical_equipments ${where} ORDER BY updated_at DESC, id DESC LIMIT ? OFFSET ?`;
            db.query(sql, [...params, limit, offset], callback);
        },

        findLegacyList(status, callback, departmentId = null) {
            let where = status ? ' AND status = ?' : '';
            const params = status ? [status] : [];
            if (departmentId != null) {
                where += ' AND department_id = ?';
                params.push(departmentId);
            }
            const sql = `SELECT * FROM medical_equipments WHERE 1=1${where} ORDER BY updated_at DESC, id DESC`;
            db.query(sql, params, callback);
        },

        findById(id, callback) {
            db.query('SELECT * FROM medical_equipments WHERE id = ?', [id], callback);
        },

        findTitleById(id, callback) {
            db.query('SELECT title, code FROM medical_equipments WHERE id = ?', [id], callback);
        },

        // ---- Các hàm Promise cho luồng nghiệp vụ mới ----
        async findBasic(id) {
            const rows = await query(db,
                'SELECT id, title, code, status, department_id, regular_maintenance, last_maintenance, next_maintenance FROM medical_equipments WHERE id = ?',
                [id]);
            return rows[0] || null;
        },

        async codeExists(code, excludeId = null) {
            const sql = excludeId ? 'SELECT id FROM medical_equipments WHERE code = ? AND id <> ? LIMIT 1'
                : 'SELECT id FROM medical_equipments WHERE code = ? LIMIT 1';
            const rows = await query(db, sql, excludeId ? [code, excludeId] : [code]);
            return rows.length > 0;
        },

        async create(fields) {
            const keys = EDITABLE_FIELDS.filter(k => fields[k] !== undefined);
            const sql = `INSERT INTO medical_equipments (${keys.join(', ')}, created_at, updated_at) VALUES (${keys.map(() => '?').join(', ')}, NOW(), NOW())`;
            const result = await query(db, sql, keys.map(k => fields[k]));
            return result.insertId;
        },

        async update(id, fields) {
            const keys = EDITABLE_FIELDS.filter(k => fields[k] !== undefined);
            if (keys.length === 0) return 0;
            const sql = `UPDATE medical_equipments SET ${keys.map(k => `${k} = ?`).join(', ')}, updated_at = NOW() WHERE id = ?`;
            const result = await query(db, sql, [...keys.map(k => fields[k]), id]);
            return result.affectedRows;
        },

        // Gọi bên trong giao dịch (conn). Chỉ đổi trạng thái khi máy chưa ở trạng thái hỏng/đang sửa.
        async markBroken(conn, id, { reason, criticalLevel }) {
            const result = await query(conn,
                "UPDATE medical_equipments SET status = 'was_broken', date_failure = NOW(), reason = ?, critical_level = ?, updated_at = NOW() WHERE id = ? AND status NOT IN ('was_broken', 'corrected')",
                [reason, criticalLevel, id]);
            return result.affectedRows;
        },

        async setStatus(conn, id, status) {
            await query(conn, 'UPDATE medical_equipments SET status = ?, updated_at = NOW() WHERE id = ?', [status, id]);
        },

        // Bảo dưỡng đạt: ghi ngày thực hiện và tính ngày tiếp theo theo chu kỳ regular_maintenance (tháng).
        // Hạn kế tiếp: ngày U3 nhập (nếu có) > chu kỳ regular_maintenance (tháng) > chu kỳ mặc định.
        async applyMaintenance(conn, id, completedAt, { nextDate = null, defaultMonths = 6 } = {}) {
            await query(conn,
                'UPDATE medical_equipments SET last_maintenance = ?, next_maintenance = CASE WHEN ? IS NOT NULL THEN ? WHEN regular_maintenance > 0 THEN DATE_ADD(?, INTERVAL regular_maintenance MONTH) ELSE DATE_ADD(?, INTERVAL ? MONTH) END, updated_at = NOW() WHERE id = ?',
                [completedAt, nextDate, nextDate, completedAt, completedAt, defaultMonths, id]);
        },

        // Chỉ được gọi bởi API tạo dữ liệu mẫu. Lệnh này xóa toàn bộ thiết bị.
        truncateAll(callback) {
            db.query('TRUNCATE TABLE medical_equipments', callback);
        },

        createSeedDevice(values, callback) {
            const sql = 'INSERT INTO medical_equipments (title, serial, status, last_inspection, next_inspection, last_maintenance, next_maintenance) VALUES (?, ?, ?, ?, ?, ?, ?)';
            db.query(sql, values, callback);
        },

        findAllForCloning(callback) {
            db.query('SELECT * FROM medical_equipments', callback);
        },

        insertClones(keys, values, callback) {
            // keys lấy từ tên cột của kết quả MySQL, không lấy từ request.
            const sql = `INSERT INTO medical_equipments (${keys.join(', ')}) VALUES ?`;
            db.query(sql, [values], callback);
        }
    };
}

module.exports = createEquipmentRepository;
