const { parseId } = require('../utils/validate');
const { assertDepartmentAccess, loadEquipment } = require('../services/access');

const DECISION_LABELS = { self_fix: 'Tự khắc phục', in_house: 'Sửa nội bộ', outsourced: 'Thuê ngoài' };

const iso = (v) => (v ? new Date(v).toISOString() : null);

// Lịch sử thiết bị trên dòng thời gian (FR-05, UC-05): gom báo hỏng, kết quả kiểm tra và nghiệm thu.
function createHistoryController({ equipmentRepository, notificationRepository, inspectionRepository, recordRepository }) {
    async function list(req, res) {
        const id = parseId(req.params.id);
        const equipment = await loadEquipment(equipmentRepository, id);
        assertDepartmentAccess(req.user, equipment);

        const [faults, inspections, records] = await Promise.all([
            notificationRepository.findFaultsByEquipment(id),
            inspectionRepository.findByEquipment(id),
            recordRepository.findByEquipment(id)
        ]);

        const events = [
            ...faults.map(f => ({
                kind: 'fault', id: f.id, time: iso(f.created_at), title: 'Báo hỏng',
                detail: f.data_content || '', person: f.user_name || null
            })),
            ...inspections.map(i => ({
                kind: 'inspection', id: i.id, time: iso(i.inspected_at), title: 'Kiểm tra sơ bộ',
                detail: `${i.cause} – Hướng xử lý: ${DECISION_LABELS[i.decision] || i.decision}`,
                person: i.user_name || null
            })),
            ...records.map(r => ({
                kind: r.type === 'maintenance' ? 'maintenance' : 'repair', id: r.id, time: iso(r.completed_at),
                title: r.type === 'maintenance' ? 'Bảo dưỡng' : 'Sửa chữa, nghiệm thu',
                detail: `Nghiệm thu ${r.result === 'pass' ? 'đạt' : 'không đạt'}${r.performed_by ? ` – Thực hiện: ${r.performed_by}` : ''}`,
                person: r.user_name || null, result: r.result, cost: Number(r.cost) || 0,
                document_url: r.document_url || null
            }))
        ].sort((a, b) => String(b.time).localeCompare(String(a.time)));

        const summary = {
            failure_count: faults.length,
            repair_count: records.filter(r => r.type === 'repair').length,
            maintenance_count: records.filter(r => r.type === 'maintenance').length,
            total_cost: records.reduce((sum, r) => sum + (Number(r.cost) || 0), 0)
        };

        res.status(200).json({
            status_code: 200,
            data: { equipment: { id, title: equipment.title, code: equipment.code, status: equipment.status }, summary, events }
        });
    }

    return { list };
}

module.exports = createHistoryController;
