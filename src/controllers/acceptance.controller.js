const HttpError = require('../utils/http-error');
const config = require('../config/env');
const { withTransaction } = require('../utils/db');
const { toLocalDate } = require('../utils/date');
const { parseId, optionalText, oneOf, optionalDate } = require('../utils/validate');
const { loadEquipment } = require('../services/access');

// Cập nhật kết quả nghiệm thu, chi phí sau sửa chữa hoặc bảo dưỡng (FR-06, UC-06).
function createAcceptanceController({ db, equipmentRepository, inspectionRepository, recordRepository }) {
    async function accept(req, res) {
        const id = parseId(req.params.id);
        const body = req.body || {};
        const type = oneOf(body.type, ['repair', 'maintenance'], 'Loại phải là repair hoặc maintenance');
        const result = oneOf(body.result, ['pass', 'fail'], 'Kết quả phải là pass hoặc fail');
        const cost = body.cost === undefined || body.cost === '' ? 0 : Number(body.cost);
        if (!Number.isFinite(cost) || cost < 0) throw new HttpError(400, 'Chi phí phải là số không âm');
        const completedAt = optionalDate(body.completed_at, 'Ngày hoàn thành') || toLocalDate(new Date());
        if (completedAt > toLocalDate(new Date())) throw new HttpError(400, 'Ngày hoàn thành không được ở tương lai');
        const nextDate = optionalDate(body.next_maintenance, 'Ngày bảo dưỡng tiếp theo');
        if (nextDate && nextDate <= completedAt) throw new HttpError(400, 'Ngày bảo dưỡng tiếp theo phải sau ngày hoàn thành');

        const equipment = await loadEquipment(equipmentRepository, id);
        if (type === 'repair' && !['was_broken', 'corrected'].includes(equipment.status)) {
            throw new HttpError(409, 'Thiết bị không có sự cố đang chờ nghiệm thu');
        }

        let inspectionId = body.inspection_id ? parseId(body.inspection_id, 'mã kết quả kiểm tra') : null;
        if (!inspectionId && type === 'repair') {
            const latest = await inspectionRepository.findLatest(id);
            inspectionId = latest ? latest.id : null;
        }

        const recordId = await withTransaction(db, async (conn) => {
            const newId = await recordRepository.create(conn, {
                equipmentId: id, inspectionId, type, result, cost,
                performedBy: optionalText(body.performed_by, 255),
                documentUrl: optionalText(body.document_url, 500),
                note: optionalText(body.note, 1000),
                completedAt, acceptedBy: req.user.id
            });
            if (result === 'pass') {
                if (type === 'repair') await equipmentRepository.setStatus(conn, id, 'active');
                else await equipmentRepository.applyMaintenance(conn, id, completedAt, { nextDate, defaultMonths: config.defaultMaintenanceMonths });
            }
            return newId;
        });

        const updated = await equipmentRepository.findBasic(id);
        res.status(201).json({
            status_code: 201,
            message: result === 'pass' ? 'Đã lưu kết quả nghiệm thu đạt' : 'Đã lưu kết quả nghiệm thu không đạt; thiết bị giữ trạng thái cũ',
            data: {
                id: recordId, equipment_id: id, type, result, cost, completed_at: completedAt,
                equipment_status: updated ? updated.status : equipment.status,
                next_maintenance: updated ? toLocalDate(updated.next_maintenance) : null
            }
        });
    }

    return { accept };
}

module.exports = createAcceptanceController;
