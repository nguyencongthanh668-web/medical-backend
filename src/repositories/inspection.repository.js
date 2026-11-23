const { query } = require('../utils/db');

// Bảng inspection_results: kết quả kiểm tra sơ bộ của kỹ thuật viên (FR-03).
function createInspectionRepository(db) {
    return {
        async create(conn, { equipmentId, notificationId, inspectorId, cause, decision, note }) {
            const result = await query(conn,
                'INSERT INTO inspection_results (equipment_id, notification_id, inspector_id, cause, decision, note, inspected_at) VALUES (?, ?, ?, ?, ?, ?, NOW())',
                [equipmentId, notificationId, inspectorId, cause, decision, note]);
            return result.insertId;
        },

        async findByEquipment(equipmentId) {
            return query(db,
                'SELECT i.*, u.name AS user_name FROM inspection_results i LEFT JOIN users u ON u.id = i.inspector_id WHERE i.equipment_id = ? ORDER BY i.inspected_at DESC',
                [equipmentId]);
        },

        async findLatest(equipmentId) {
            const rows = await query(db,
                'SELECT id FROM inspection_results WHERE equipment_id = ? ORDER BY inspected_at DESC LIMIT 1',
                [equipmentId]);
            return rows[0] || null;
        }
    };
}

module.exports = createInspectionRepository;
