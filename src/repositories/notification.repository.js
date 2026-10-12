function createNotificationRepository(db) {
    return {
        findAll(callback) {
            db.query('SELECT * FROM notifications ORDER BY created_at DESC', callback);
        },

        createFailureNotification({ id, timestamp, equipmentId, content }, callback) {
            const sql = `
                INSERT INTO notifications
                (id, type, notifiable_id, notifiable_type, read_at, created_at, updated_at, data_id, data_user_id, data_content)
                VALUES (?, 'App\\\\Notifications\\\\ReportFailureNotifications', 267, 'App\\\\Models\\\\User', NULL, ?, ?, ?, 267, ?)
            `;
            db.query(sql, [id, timestamp, timestamp, equipmentId, content], callback);
        }
    };
}

module.exports = createNotificationRepository;
