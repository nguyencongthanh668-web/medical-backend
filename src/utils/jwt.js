// JWT HS256 viết bằng node:crypto, không cần thư viện ngoài.
const crypto = require('node:crypto');

const base64url = (input) => Buffer.from(input).toString('base64url');

function sign(payload, secret, expiresInSeconds) {
    const header = { alg: 'HS256', typ: 'JWT' };
    const now = Math.floor(Date.now() / 1000);
    const body = { ...payload, iat: now, exp: now + expiresInSeconds };
    const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(body))}`;
    const signature = crypto.createHmac('sha256', secret).update(unsigned).digest('base64url');
    return `${unsigned}.${signature}`;
}

// Trả payload nếu token hợp lệ và còn hạn, ngược lại trả null.
function verify(token, secret) {
    if (typeof token !== 'string') return null;
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const [header, body, signature] = parts;
    const expected = crypto.createHmac('sha256', secret).update(`${header}.${body}`).digest('base64url');
    const a = Buffer.from(signature);
    const b = Buffer.from(expected);
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) return null;

    try {
        const decodedHeader = JSON.parse(Buffer.from(header, 'base64url').toString());
        if (decodedHeader.alg !== 'HS256') return null;
        const payload = JSON.parse(Buffer.from(body, 'base64url').toString());
        if (!payload.exp || payload.exp < Math.floor(Date.now() / 1000)) return null;
        return payload;
    } catch {
        return null;
    }
}

module.exports = { sign, verify };
