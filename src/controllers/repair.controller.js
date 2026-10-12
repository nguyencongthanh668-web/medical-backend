const { toDateString, toSqlDateTime } = require('../utils/date');

function createRepairController(equipmentRepository, notificationRepository) {
    function reportFailure(req, res) {
        try {
            const body = req.body || {};
            const id = Number(req.params.id || body.id || body.equipment_id);
            const now = new Date();
            const timestamp = now.toISOString().replace('Z', '000Z');
            const criticalLevel = body.critical_level || 'Cần sửa';
            const reason = body.reason || 'Báo hỏng từ ứng dụng';

            console.log(`[Báo hỏng] Đang xử lý cho thiết bị ID: ${id}`);

            if (id) {
                // Giữ hành vi bất đồng bộ của bản gốc: phản hồi trước khi MySQL hoàn tất.
                equipmentRepository.markBroken(id, (err) => {
                    if (err) console.error('Lỗi cập nhật trạng thái thiết bị:', err.message);
                    else console.log(`[Báo hỏng] Đã đổi status = 'was_broken' cho thiết bị ${id}`);
                });

                equipmentRepository.findTitleById(id, (err, results) => {
                    const title = results && results.length > 0 ? (results[0].title || 'Thiết bị') : 'Thiết bị';
                    const notificationId = 'notif_' + Math.random().toString(36).substring(2, 11) + '_' + Date.now();
                    const content = `Thiết bị ${title} đã được báo hỏng. Mức độ quan trọng: ${criticalLevel}`;

                    notificationRepository.createFailureNotification({
                        id: notificationId, timestamp, equipmentId: id, content
                    }, (notificationError) => {
                        if (notificationError) console.error('Lỗi thêm thông báo:', notificationError);
                    });
                });
            }

            res.status(200).json({
                status_code: 200, status: '200', success: true,
                message: 'Báo hỏng thành công',
                data: {
                    id, status: 'was_broken', date_failure: toSqlDateTime(now),
                    reason, critical_level: criticalLevel, update_day: toDateString(now)
                }
            });
        } catch (err) {
            console.error('Lỗi xử lý báo hỏng:', err);
            res.status(500).json({ status_code: 500, message: err.message });
        }
    }

    return { reportFailure };
}

module.exports = createRepairController;
