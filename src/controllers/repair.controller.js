const crypto = require('node:crypto');
const HttpError = require('../utils/http-error');
const { withTransaction } = require('../utils/db');
const { toDateString, toSqlDateTime } = require('../utils/date');
const { parseId, requiredText, optionalText } = require('../utils/validate');
const { assertDepartmentAccess, loadEquipment } = require('../services/access');

// Báo hỏng (FR-02, UC-02). Đổi trạng thái và tạo thông báo trong cùng một giao dịch;
// mã request_id do ứng dụng sinh giúp gửi lại khi mất mạng không tạo bản ghi trùng (NFR-03).
function createRepairController({ db, equipmentRepository, notificationRepository }) {
    async function reportFailure(req, res) {
        const body = req.body || {};
        const id = parseId(req.params.id || body.id || body.equipment_id);
        const symptom = requiredText(body.symptom ?? body.reason, 'Vui lòng nhập hiện tượng hỏng hóc', 500);
        const criticalLevel = optionalText(body.critical_level, 50) || 'Cần sửa';
        const requestId = optionalText(body.request_id, 40); // notifications.id là VARCHAR(50)
        if (requestId && !/^[A-Za-z0-9_-]+$/.test(requestId)) throw new HttpError(400, 'request_id không hợp lệ');
        const notificationId = `fault_${requestId || crypto.randomUUID()}`;

        if (requestId) {
            const existing = await notificationRepository.findById(notificationId);
            if (existing && Number(existing.data_id) === id) {
                return res.status(200).json({
                    status_code: 200, success: true, duplicate: true,
                    message: 'Yêu cầu báo hỏng này đã được ghi nhận trước đó',
                    data: { id, status: 'was_broken', notification_id: notificationId }
                });
            }
        }

        const equipment = await loadEquipment(equipmentRepository, id);
        assertDepartmentAccess(req.user, equipment);
        if (['was_broken', 'corrected'].includes(equipment.status)) {
            throw new HttpError(409, 'Thiết bị đang được báo hỏng hoặc đang sửa chữa');
        }

        const title = equipment.title || equipment.code || `#${id}`;
        await withTransaction(db, async (conn) => {
            const changed = await equipmentRepository.markBroken(conn, id, { reason: symptom, criticalLevel });
            if (changed === 0) throw new HttpError(409, 'Thiết bị đang được báo hỏng hoặc đang sửa chữa');
            await notificationRepository.create(conn, {
                id: notificationId,
                type: notificationRepository.TYPES.FAULT,
                userId: req.user.id,
                equipmentId: id,
                content: `Thiết bị ${title} được báo hỏng: ${symptom}. Mức độ: ${criticalLevel}`
            });
        });

        const now = new Date();
        res.status(201).json({
            status_code: 201, status: '201', success: true,
            message: 'Báo hỏng thành công',
            data: {
                id, status: 'was_broken', notification_id: notificationId,
                date_failure: toSqlDateTime(now), reason: symptom,
                critical_level: criticalLevel, update_day: toDateString(now)
            }
        });
    }

    return { reportFailure };
}

module.exports = createRepairController;
