// V1 gộp cả corrected và was_broken; V2 chỉ gộp khi lọc corrected.
// Giữ quy tắc này để các màn hình Flutter tiếp tục nhận dữ liệu như trước.
function buildStatusFilter(status, version) {
    if (!status || status === 'all') return { where: '', params: [] };

    if (status === 'corrected' || (version === 1 && status === 'was_broken')) {
        return { where: " WHERE (status = 'corrected' OR status = 'was_broken')", params: [] };
    }
    if (version === 1 && status === 'active') {
        return { where: " WHERE status = 'active'", params: [] };
    }
    return { where: ' WHERE status = ?', params: [status] };
}

function createEquipmentRepository(db) {
    return {
        findAllV1(status, callback) {
            const { where, params } = buildStatusFilter(status, 1);
            db.query(`SELECT * FROM medical_equipments ${where} ORDER BY updated_at DESC, id DESC`, params, callback);
        },

        countV2(status, callback) {
            const { where, params } = buildStatusFilter(status, 2);
            db.query(`SELECT COUNT(*) AS total FROM medical_equipments ${where}`, params, callback);
        },

        findPageV2({ status, limit, offset }, callback) {
            const { where, params } = buildStatusFilter(status, 2);
            const sql = `SELECT * FROM medical_equipments ${where} ORDER BY updated_at DESC, id DESC LIMIT ? OFFSET ?`;
            db.query(sql, [...params, limit, offset], callback);
        },

        findLegacyList(status, callback) {
            const where = status ? ' AND status = ?' : '';
            const params = status ? [status] : [];
            const sql = `SELECT * FROM medical_equipments WHERE 1=1${where} ORDER BY updated_at DESC, id DESC`;
            db.query(sql, params, callback);
        },

        findById(id, callback) {
            db.query('SELECT * FROM medical_equipments WHERE id = ?', [id], callback);
        },

        findTitleById(id, callback) {
            db.query('SELECT title, code FROM medical_equipments WHERE id = ?', [id], callback);
        },

        markBroken(id, callback) {
            db.query("UPDATE medical_equipments SET status = 'was_broken', updated_at = NOW() WHERE id = ?", [id], callback);
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
