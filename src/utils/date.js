function toDateString(date) {
    return date.toISOString().split('T')[0];
}

// Giữ múi giờ UTC như các hàm format ngày của API cũ.
function toSqlDateTime(date) {
    return date.toISOString().slice(0, 19).replace('T', ' ');
}

module.exports = { toDateString, toSqlDateTime };

// Ngày theo giờ địa phương (YYYY-MM-DD); dùng cho cột DATE mà mysql2 trả về lúc 00:00 giờ máy.
function toLocalDate(value) {
    if (!value) return null;
    const d = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(d.getTime())) return null;
    const pad = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

module.exports.toLocalDate = toLocalDate;
