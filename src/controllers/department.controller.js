const formatDepartment = require('../formatters/department.formatter');

function createDepartmentController(departmentRepository) {
    return {
        list(req, res) {
            departmentRepository.findAll((err, results) => {
                if (err) {
                    console.error('Lỗi lấy danh sách khoa phòng:', err);
                    return res.status(500).json({ status_code: 500, message: 'Lỗi Server' });
                }
                res.status(200).json({ status_code: 200, data: results.map(formatDepartment) });
            });
        },

        // Dữ liệu mẫu của API cũ; chưa truy vấn chi tiết khoa/phòng từ MySQL.
        detail(req, res) {
            const id = req.params.id;
            res.status(200).json({
                status_code: 200,
                success: true,
                data: {
                    id: Number(id),
                    title: `Khoa phòng số ${id}`,
                    name: `Khoa phòng số ${id}`,
                    display_name: `Khoa phòng số ${id}`
                }
            });
        }
    };
}

module.exports = createDepartmentController;
