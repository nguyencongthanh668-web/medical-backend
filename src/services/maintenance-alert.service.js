const { toLocalDate } = require('../utils/date');

const MILESTONES = [30, 15, 7];

// Mốc cảnh báo nhỏ nhất mà số ngày còn lại đã chạm tới (đã quá hạn thì tính mốc 7).
function milestoneFor(daysLeft) {
    if (daysLeft <= 7) return 7;
    if (daysLeft <= 15) return 15;
    return 30;
}

function formatVi(dateStr) {
    const [y, m, d] = dateStr.split('-');
    return `${d}/${m}/${y}`;
}

// Quét toàn bộ thiết bị sắp đến hạn bảo dưỡng (FR-04). Mỗi mốc chỉ tạo một thông báo nhờ ràng buộc
// duy nhất của maintenance_alerts; nếu một lượt quét bị lỡ, lượt sau vẫn phát hiện mốc còn thiếu (NFR-03).
async function scanMaintenanceDue({ alertRepository, notificationRepository, db }) {
    const rows = await alertRepository.findDueEquipments(MILESTONES[0]);
    let created = 0;
    for (const row of rows) {
        const daysLeft = Number(row.days_left);
        const milestone = milestoneFor(daysLeft);
        const dueDate = toLocalDate(row.next_maintenance);
        const isNew = await alertRepository.recordAlert(row.id, dueDate, milestone);
        if (!isNew) continue;

        const status = daysLeft < 0 ? `đã quá hạn ${-daysLeft} ngày` : `còn ${daysLeft} ngày`;
        await notificationRepository.create(db, {
            id: `due_${row.id}_${dueDate}_${milestone}`,
            type: notificationRepository.TYPES.MAINTENANCE_DUE,
            userId: 0,
            equipmentId: row.id,
            content: `Thiết bị ${row.title || row.code || row.id} đến hạn bảo dưỡng ngày ${formatVi(dueDate)} (${status}).`
        });
        created++;
    }
    return { scanned: rows.length, created };
}

module.exports = { scanMaintenanceDue, milestoneFor, MILESTONES };
