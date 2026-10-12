const { toSqlDateTime } = require('../utils/date');

const SAMPLE_DEVICES = [
    'Máy X-Quang kỹ thuật số VIKOMED', 'Máy siêu âm 4D',
    'Máy đo điện tim 3 kênh', 'Monitor theo dõi bệnh nhân', 'Máy thở chức năng cao'
];

function randomDate(yearsBack) {
    const date = new Date();
    date.setDate(date.getDate() - Math.floor(Math.random() * (yearsBack * 365)));
    return toSqlDateTime(date);
}

function createSeedController(equipmentRepository) {
    // API tương thích với bản gốc: XÓA TOÀN BỘ medical_equipments rồi tạo 455 thiết bị mẫu.
    // Chỉ sử dụng trên database thử nghiệm có thể xóa bỏ.
    function seed(req, res) {
        equipmentRepository.truncateAll((err) => {
            if (err) return res.status(500).send('Lỗi dọn rác DB: ' + err.message);

            let insertedCount = 0;
            let hasError = false;

            SAMPLE_DEVICES.forEach((title, index) => {
                const values = [
                    title, 'SN-GOC-' + index, 'active',
                    randomDate(2), randomDate(-1), randomDate(1), randomDate(-0.5)
                ];
                equipmentRepository.createSeedDevice(values, (insertError) => {
                    if (insertError) {
                        console.error('Lỗi chèn máy gốc:', insertError);
                        hasError = true;
                    }
                    insertedCount++;
                    if (insertedCount === SAMPLE_DEVICES.length) {
                        if (hasError) {
                            return res.status(500).send('Thêm máy gốc thất bại! Hãy xem log trên Terminal Node.js để biết bảng DB đang thiếu cột gì.');
                        }
                        cloneEquipments();
                    }
                });
            });
        });

        function cloneEquipments() {
            equipmentRepository.findAllForCloning((err, results) => {
                if (err) return res.status(500).send('Lỗi đọc dữ liệu: ' + err.message);
                if (!results || results.length === 0) {
                    return res.status(500).send('Không có thiết bị gốc nào để nhân bản!');
                }

                const keys = Object.keys(results[0]).filter(key => key !== 'id');
                const values = [];
                for (let i = 0; i < 450; i++) {
                    const sample = results[Math.floor(Math.random() * results.length)];
                    const clone = { ...sample };
                    delete clone.id;
                    clone.title = sample.title;
                    clone.serial = `SN-${Date.now().toString().slice(-4)}-${i}`;

                    const randomStatus = Math.random();
                    clone.status = randomStatus < 0.08 ? 'was_broken' : (randomStatus < 0.20 ? 'corrected' : 'active');
                    clone.last_inspection = randomDate(2);
                    clone.next_inspection = randomDate(-1);
                    clone.last_maintenance = randomDate(1);
                    clone.next_maintenance = randomDate(-0.5);
                    if (keys.includes('created_at')) clone.created_at = randomDate(3);
                    if (keys.includes('updated_at')) clone.updated_at = toSqlDateTime(new Date());

                    values.push(keys.map(key => clone[key] !== undefined ? clone[key] : null));
                }

                equipmentRepository.insertClones(keys, values, (insertError, result) => {
                    if (insertError) {
                        console.error('Lỗi nhân bản:', insertError);
                        return res.status(500).json({ message: 'Lỗi nhân bản', error: insertError.message });
                    }
                    res.send(`
                    <h1 style="color: green;">🎉 THÀNH CÔNG RỰC RỠ!</h1>
                    <p>Đã dọn dẹp sạch sẽ và tạo mới <b>${result.affectedRows + SAMPLE_DEVICES.length}</b> thiết bị.</p>
                    <h3>👉 Bây giờ hãy mở ứng dụng Flutter và tận hưởng thành quả!</h3>
                `);
                });
            });
        }
    }

    return { seed };
}

module.exports = createSeedController;
