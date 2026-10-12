function formatNotification(row) {
    return {
        id: row.id,
        type: row.type,
        notifiable_id: row.notifiable_id,
        notifiable_type: row.notifiable_type,
        read_at: row.read_at,
        created_at: row.created_at,
        updated_at: row.updated_at,
        data: {
            id: row.data_id,
            user_id: row.data_user_id,
            content: row.data_content
        }
    };
}

module.exports = formatNotification;
