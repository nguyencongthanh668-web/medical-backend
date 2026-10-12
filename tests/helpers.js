const assert = require('node:assert/strict');
const { once } = require('node:events');
const { createApp } = require('../src/app');

// Mỗi bước mô tả một truy vấn dự kiến. Không tạo pool hoặc kết nối MySQL thật.
function createDatabaseStub(steps = []) {
    const calls = [];
    return {
        calls,
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

    return async (pathname, { method = 'GET', body } = {}) => {
        const response = await fetch(baseUrl + pathname, {
            method,
            signal: AbortSignal.timeout(5000),
            headers: body === undefined ? {} : { 'Content-Type': 'application/json' },
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

module.exports = { createDatabaseStub, startTestApp };
