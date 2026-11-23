const { toLocalDate } = require('../utils/date');
const { scanMaintenanceDue } = require('../services/maintenance-alert.service');

// Dashboard cảnh báo bảo dưỡng cho U3 (FR-04, UC-04).
function createAlertController({ db, alertRepository, notificationRepository }) {
    async function list(req, res) {
        const days = [7, 15, 30].includes(Number(req.query.days)) ? Number(req.query.days) : 30;
        const rows = await alertRepository.listDue(days);
        const data = rows.map(r => ({
            id: Number(r.id), title: r.title || '', code: r.code || '',
            department_id: Number(r.department_id) || 0, status: r.status,
            next_maintenance: toLocalDate(r.next_maintenance),
            days_left: Number(r.days_left),
            alerted_milestone: r.alerted_milestone == null ? null : Number(r.alerted_milestone)
        }));
        res.status(200).json({ status_code: 200, days, total: data.length, data });
    }

    // Chạy bộ quét ngay, dùng khi kiểm thử TC-04 hoặc khi máy chủ vừa bật lại.
    async function scan(req, res) {
        const result = await scanMaintenanceDue({ alertRepository, notificationRepository, db });
        res.status(200).json({ status_code: 200, message: 'Đã quét hạn bảo dưỡng', data: result });
    }

    return { list, scan };
}

module.exports = createAlertController;
