const formatNotification = require('../formatters/notification.formatter');

function createNotificationController(notificationRepository) {
    return {
        list(req, res) {
            notificationRepository.findAll((err, results) => {
                if (err) {
                    console.error('Lỗi truy vấn thông báo:', err);
                    return res.status(500).json({ status_code: 500, message: 'Lỗi Server' });
                }

                const data = results.map(formatNotification);
                res.status(200).json({ status: 1, total: data.length, data });
            });
        }
    };
}

module.exports = createNotificationController;
