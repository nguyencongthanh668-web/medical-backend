const formatUser = require('../formatters/user.formatter');

function createUserController(userRepository) {
    return {
        list(req, res) {
            userRepository.findAll(req.query.department_id, (err, results) => {
                if (err) return res.status(500).json({ error: 'Lỗi Server' });

                const data = results.map(formatUser);
                res.status(200).json({ data, dataLength: data.length });
            });
        },

        detail(req, res) {
            userRepository.findById(req.params.id, (err, results) => {
                if (err) {
                    console.error('Lỗi truy vấn:', err);
                    return res.status(500).json({ status_code: 500, message: 'Lỗi Server' });
                }
                if (results.length === 0) {
                    return res.status(404).json({ status_code: 404, message: 'Không tìm thấy người dùng' });
                }
                res.status(200).json({ status_code: 200, data: results[0] });
            });
        }
    };
}

module.exports = createUserController;
