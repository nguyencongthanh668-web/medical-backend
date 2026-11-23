const assert = require('node:assert/strict');
const { once } = require('node:events');
process.env.NODE_ENV = 'test';
const { createApp } = require('../src/app');
const config = require('../src/config/env');
const { sign } = require('../src/utils/jwt');

// Người dùng mẫu cho từng nhóm quyền (Bảng 2.4).
const USERS = {
    department: { sub: 11, role: 'department', department_id: 3, name: 'Điều dưỡng khoa 3' },
    technician: { sub: 12, role: 'technician', department_id: null, name: 'Kỹ thuật viên' },
    manager: { sub: 13, role: 'manager', department_id: null, name: 'Cán bộ Phòng Vật tư' },
    admin: { sub: 14, role: 'admin', department_id: null, name: 'Quản trị hệ thống' }
};

function tokenFor(role) {
    return sign(USERS[role], config.jwt.secret, 3600);
}

// Mỗi bước mô tả một truy vấn dự kiến. Không tạo pool hoặc kết nối MySQL thật.
function createDatabaseStub(steps = []) {
    const calls = [];
    const tx = [];
    const stub = {
        calls,
        tx,
        // Giả lập pool.getConnection cho giao dịch; ghi lại BEGIN/COMMIT/ROLLBACK/RELEASE vào tx.
        getConnection(callback) {
            const conn = {
                query: (...args) => stub.query(...args),
                beginTransaction: (cb) => { tx.push('BEGIN'); setImmediate(() => cb(null)); },
                commit: (cb) => { tx.push('COMMIT'); setImmediate(() => cb(null)); },
                rollback: (cb) => { tx.push('ROLLBACK'); setImmediate(() => cb()); },
                release: () => { tx.push('RELEASE'); }
            };
            setImmediate(() => callback(null, conn));
        },
        query(sql, params, callback) {
            if (typeof params === 'function') {
                callback = params;
                params = [];
            }
            const call = { sql: sql.replace(/\s+/g, ' ').trim(), params };
            calls.push(call);
            const step = steps[calls.length - 1];
            assert.ok(step, `Truy vấn ngoài dự kiến: ${call.sql}`);
            if (step.sql) assert.match(call.sql, step.sql);
            if (step.params) assert.deepEqual(params, step.params);
            if (step.inspect) step.inspect(call);
            setImmediate(() => callback(step.error || null, step.result ?? []));
        },
        assertComplete() {
            assert.equal(calls.length, steps.length, 'Số lượng truy vấn phải khớp');
        }
    };
    return stub;
}

async function startTestApp(t, db = createDatabaseStub()) {
    // Các ca lỗi chủ động và báo hỏng có log; chỉ hiển thị kết quả kiểm thử.
    t.mock.method(console, 'log', () => {});
    t.mock.method(console, 'error', () => {});
    const server = createApp({ db }).listen(0, '127.0.0.1');
    await once(server, 'listening');
    t.after(async () => {
        await new Promise((resolve, reject) => {
            server.close(err => err ? reject(err) : resolve());
            server.closeAllConnections();
        });
        db.assertComplete();
    });
    const baseUrl = `http://127.0.0.1:${server.address().port}`;

    // as: vai trò gửi request (mặc định manager); as: null để gửi không kèm token.
    return async (pathname, { method = 'GET', body, as = 'manager' } = {}) => {
        const headers = body === undefined ? {} : { 'Content-Type': 'application/json' };
        if (as) headers.Authorization = `Bearer ${tokenFor(as)}`;
        const response = await fetch(baseUrl + pathname, {
            method,
            signal: AbortSignal.timeout(5000),
            headers,
            body: body === undefined ? undefined : JSON.stringify(body)
        });
        const text = await response.text();
        const contentType = response.headers.get('content-type') || '';
        return {
            status: response.status,
            headers: response.headers,
            body: contentType.includes('application/json') ? JSON.parse(text) : text,
            baseUrl
        };
    };
}

module.exports = { createDatabaseStub, startTestApp, tokenFor, USERS };
