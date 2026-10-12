function createDeviceController(deviceRepository) {
    return {
        list(req, res) {
            deviceRepository.findAll((err, results) => {
                if (err) return res.status(500).json({ error: 'Lỗi truy vấn dữ liệu' });
                res.json(results);
            });
        }
    };
}

module.exports = createDeviceController;
