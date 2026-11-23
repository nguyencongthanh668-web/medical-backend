const HttpError = require('../utils/http-error');
const { withTransaction } = require('../utils/db');
const { parseId, requiredText, optionalText, oneOf } = require('../utils/validate');
const { assertDepartmentAccess, loadEquipment } = require('../services/access');

const DECISIONS = ['self_fix', 'in_house', 'outsourced'];

// Kỹ thuật viên ghi kết quả kiểm tra sơ bộ và hướng xử lý (FR-03, UC-03).
function createInspectionController({ db, equipmentRepository, notificationRepository, inspectionRepository }) {
    async function create(req, res) {
        const id = parseId(req.params.id);
        const body = req.body || {};
        const cause = requiredText(body.cause, 'Vui lòng nhập nguyên nhân', 1000);
        const decision = oneOf(body.decision, DECISIONS, 'Hướng xử lý phải là self_fix, in_house hoặc outsourced');
        const note = optionalText(body.note, 1000);

        const equipment = await loadEquipment(equipmentRepository, id);
        if (!['was_broken', 'corrected'].includes(equipment.status)) {
            throw new HttpError(409, 'Thiết bị không có sự cố đang chờ xử lý');
        }

        let notificationId = optionalText(body.notification_id, 100);
        if (notificationId) {
            const n = await notificationRepository.findById(notificationId);
            if (!n || Number(n.data_id) !== id) throw new HttpError(400, 'Báo hỏng không thuộc thiết bị này');
        } else {
            const latest = await notificationRepository.findLatestFault(id);
            notificationId = latest ? latest.id : null;
        }

        const inspectionId = await withTransaction(db, async (conn) => {
            const newId = await inspectionRepository.create(conn, {
                equipmentId: id, notificationId, inspectorId: req.user.id, cause, decision, note
            });
            await equipmentRepository.setStatus(conn, id, 'corrected');
            return newId;
        });

        res.status(201).json({
            status_code: 201, message: 'Đã ghi kết quả kiểm tra',
            data: { id: inspectionId, equipment_id: id, notification_id: notificationId, cause, decision, note, status: 'corrected' }
        });
    }

    async function list(req, res) {
        const id = parseId(req.params.id);
        const equipment = await loadEquipment(equipmentRepository, id);
        assertDepartmentAccess(req.user, equipment);
        const data = await inspectionRepository.findByEquipment(id);
        res.status(200).json({ status_code: 200, total: data.length, data });
    }

    return { create, list, DECISIONS };
}

module.exports = createInspectionController;
