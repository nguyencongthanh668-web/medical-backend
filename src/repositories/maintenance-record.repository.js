const { query } = require('../utils/db');

// Bảng maintenance_records: kết quả sửa chữa/bảo dưỡng và nghiệm thu, chi phí (FR-06).
function createMaintenanceRecordRepository(db) {
    return {
        async create(conn, r) {
            const result = await query(conn,
                'INSERT INTO maintenance_records (equipment_id, inspection_id, type, result, cost, performed_by, document_url, note, completed_at, accepted_by, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())',
                [r.equipmentId, r.inspectionId, r.type, r.result, r.cost, r.performedBy, r.documentUrl, r.note, r.completedAt, r.acceptedBy]);
            return result.insertId;
        },

        async findByEquipment(equipmentId) {
            return query(db,
                'SELECT r.*, u.name AS user_name FROM maintenance_records r LEFT JOIN users u ON u.id = r.accepted_by WHERE r.equipment_id = ? ORDER BY r.completed_at DESC, r.id DESC',
                [equipmentId]);
        }
    };
}

module.exports = createMaintenanceRecordRepository;
