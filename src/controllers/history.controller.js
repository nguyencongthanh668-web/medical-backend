const demoStaff = require('../data/demo-staff');
const { toDateString } = require('../utils/date');

function createHistoryItem({ id, equipmentId, time, lastInspection, nextInspection, status, staff }) {
    return {
        id, equipment_id: equipmentId,
        title: 'Kiểm tra định kỳ', type: 'inspection',
        time, date: time, created_at: time,
        last_inspection: lastInspection, next_inspection: nextInspection,
        status, person: staff.name, user_name: staff.name, user_id: staff.id,
        user: {
            id: staff.id, name: staff.name, code: staff.code,
            display_name: `${staff.name} (${staff.code})`,
            email: staff.email, phone: staff.phone
        }
    };
}

// Lịch sử mẫu của bản gốc, dùng chung cho inspections và maintenances.
// Chưa có bảng lịch sử thật trong repository này.
function list(req, res) {
    try {
        const now = new Date();
        const pastDate = new Date(now);
        pastDate.setMonth(now.getMonth() - 2);
        const futureDate = new Date(now);
        futureDate.setMonth(now.getMonth() + 4);

        const lastInspection = toDateString(pastDate);
        const nextInspection = toDateString(futureDate);
        const staff1 = demoStaff[Math.floor(Math.random() * demoStaff.length)];
        const staff2 = demoStaff[Math.floor(Math.random() * demoStaff.length)];
        const common = { equipmentId: Number(req.params.id), lastInspection, nextInspection };

        const data = [
            createHistoryItem({ ...common, id: 1, time: lastInspection, status: 1, staff: staff1 }),
            createHistoryItem({ ...common, id: 2, time: nextInspection, status: 0, staff: staff2 })
        ];
        res.status(200).json({ status: '200', status_code: 200, message: 'Thành công', data });
    } catch (err) {
        console.error('Lỗi lấy lịch sử kiểm định:', err);
        res.status(500).json({ status_code: 500, message: err.message });
    }
}

module.exports = { list };
