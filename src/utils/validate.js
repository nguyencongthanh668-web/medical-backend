const HttpError = require('./http-error');

function parseId(value, name = 'mã thiết bị') {
    const id = Number(value);
    if (!Number.isInteger(id) || id <= 0) throw new HttpError(400, `Giá trị ${name} không hợp lệ`);
    return id;
}

function requiredText(value, message, max = 1000) {
    const text = typeof value === 'string' ? value.trim() : '';
    if (!text) throw new HttpError(400, message);
    if (text.length > max) throw new HttpError(400, `Nội dung không được dài quá ${max} ký tự`);
    return text;
}

function optionalText(value, max = 1000) {
    if (value === undefined || value === null || value === '') return null;
    const text = String(value).trim();
    if (text.length > max) throw new HttpError(400, `Nội dung không được dài quá ${max} ký tự`);
    return text || null;
}

function oneOf(value, allowed, message) {
    if (!allowed.includes(value)) throw new HttpError(400, message);
    return value;
}

// Ngày dạng YYYY-MM-DD; trả null nếu không có và không bắt buộc.
function optionalDate(value, name) {
    if (value === undefined || value === null || value === '') return null;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(String(value)) || Number.isNaN(new Date(value).getTime())) {
        throw new HttpError(400, `${name} phải có dạng YYYY-MM-DD`);
    }
    return String(value);
}

function optionalNonNegativeInt(value, name) {
    if (value === undefined || value === null || value === '') return undefined;
    const n = Number(value);
    if (!Number.isInteger(n) || n < 0) throw new HttpError(400, `${name} phải là số nguyên không âm`);
    return n;
}

module.exports = { parseId, requiredText, optionalText, oneOf, optionalDate, optionalNonNegativeInt };
