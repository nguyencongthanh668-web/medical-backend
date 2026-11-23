const { query } = require('../utils/db');

const ACTIVE_FILTER = "status NOT IN ('liquidated', 'inactive')";

// Bảng maintenance_alerts: mỗi (thiết bị, ngày đến hạn, mốc) chỉ có một dòng (FR-04, NFR-03).
function createMaintenanceAlertRepository(db) {
    return {
        async findDueEquipments(withinDays) {
            return query(db,
                `SELECT id, title, code, department_id, status, next_maintenance, DATEDIFF(next_maintenance, CURDATE()) AS days_left FROM medical_equipments WHERE next_maintenance IS NOT NULL AND next_maintenance <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND ${ACTIVE_FILTER} ORDER BY next_maintenance ASC`,
                [withinDays]);
        },

        // Trả true nếu mốc này chưa từng được cảnh báo (vừa thêm dòng mới).
        async recordAlert(equipmentId, dueDate, milestone) {
            const result = await query(db,
                'INSERT IGNORE INTO maintenance_alerts (equipment_id, due_date, milestone, alerted_at) VALUES (?, ?, ?, NOW())',
                [equipmentId, dueDate, milestone]);
            return result.affectedRows === 1;
        },

        async listDue(withinDays) {
            return query(db,
                `SELECT e.id, e.title, e.code, e.department_id, e.status, e.next_maintenance, DATEDIFF(e.next_maintenance, CURDATE()) AS days_left, (SELECT MIN(a.milestone) FROM maintenance_alerts a WHERE a.equipment_id = e.id AND a.due_date = e.next_maintenance) AS alerted_milestone FROM medical_equipments e WHERE e.next_maintenance IS NOT NULL AND e.next_maintenance <= DATE_ADD(CURDATE(), INTERVAL ? DAY) AND e.${ACTIVE_FILTER} ORDER BY e.next_maintenance ASC`,
                [withinDays]);
        }
    };
}

module.exports = createMaintenanceAlertRepository;
