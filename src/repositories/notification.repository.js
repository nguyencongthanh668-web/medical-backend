const { query } = require('../utils/db');

// Bảng notifications giữ cấu trúc kiểu Laravel của CSDL gốc:
// data_id = mã thiết bị, data_user_id = người tạo sự kiện, data_content = nội dung.
const TYPES = Object.freeze({
    FAULT: 'App\\Notifications\\ReportFailureNotifications',
    MAINTENANCE_DUE: 'App\\Notifications\\MaintenanceDueNotifications'
});

function createNotificationRepository(db) {
    return {
        TYPES,

        findAll(callback) {
            db.query('SELECT * FROM notifications ORDER BY created_at DESC', callback);
        },

        async findById(id) {
            const rows = await query(db, 'SELECT id, data_id, created_at FROM notifications WHERE id = ?', [id]);
            return rows[0] || null;
        },

        async findLatestFault(equipmentId) {
            const rows = await query(db,
                'SELECT id FROM notifications WHERE data_id = ? AND type = ? ORDER BY created_at DESC LIMIT 1',
                [equipmentId, TYPES.FAULT]);
            return rows[0] || null;
        },

        async findFaultsByEquipment(equipmentId) {
            return query(db,
                'SELECT n.id, n.created_at, n.data_content, n.data_user_id, u.name AS user_name FROM notifications n LEFT JOIN users u ON u.id = n.data_user_id WHERE n.data_id = ? AND n.type = ? ORDER BY n.created_at DESC',
                [equipmentId, TYPES.FAULT]);
        },

        // executor là pool hoặc connection của giao dịch.
        async create(executor, { id, type, userId, equipmentId, content }) {
            await query(executor,
                'INSERT INTO notifications (id, type, notifiable_id, notifiable_type, read_at, created_at, updated_at, data_id, data_user_id, data_content) VALUES (?, ?, ?, ?, NULL, NOW(), NOW(), ?, ?, ?)',
                [id, type, userId || 0, 'App\\Models\\User', equipmentId, userId || 0, content]);
        }
    };
}

createNotificationRepository.TYPES = TYPES;
module.exports = createNotificationRepository;
