function toDateString(date) {
    return date.toISOString().split('T')[0];
}

// Giữ múi giờ UTC như các hàm format ngày của API cũ.
function toSqlDateTime(date) {
    return date.toISOString().slice(0, 19).replace('T', ' ');
}

module.exports = { toDateString, toSqlDateTime };
