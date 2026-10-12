const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createDatabaseStub, startTestApp } = require('./helpers');

const postPaths = [];
const putPaths = [];
for (const version of ['v1', 'v2']) {
    for (const resource of ['equipment', 'equipments']) {
        const path = `/api/${version}/${resource}/7`;
        postPaths.push(path, `${path}/repair`, `${path}/failure`);
        putPaths.push(path);
    }
    postPaths.push(`/api/${version}/equipments/repair`, `/api/${version}/repairs`);
}

for (const [method, paths] of [['POST', postPaths], ['PUT', putPaths]]) {
    for (const path of paths) {
        test(`Báo hỏng ${method} ${path}`, async t => {
            const db = createDatabaseStub([
                { sql: /^UPDATE medical_equipments SET status = 'was_broken'/, params: [7], result: { affectedRows: 1 } },
                { sql: /^SELECT title, code/, params: [7], result: [{ title: 'Máy thử nghiệm', code: 'TEST' }] },
                { sql: /^INSERT INTO notifications/, inspect({ params }) {
                    assert.equal(params[3], 7);
                    assert.equal(params[4], 'Thiết bị Máy thử nghiệm đã được báo hỏng. Mức độ quan trọng: Khẩn cấp');
                }, result: { affectedRows: 1 } }
            ]);
            const request = await startTestApp(t, db);
            const response = await request(path, {
                method, body: { equipment_id: 7, reason: 'Không khởi động', critical_level: 'Khẩn cấp' }
            });
            assert.equal(response.status, 200);
            assert.equal(response.body.data.id, 7);
            assert.equal(response.body.data.status, 'was_broken');
            assert.equal(response.body.data.reason, 'Không khởi động');
            assert.equal(response.body.data.critical_level, 'Khẩn cấp');
            assert.match(response.body.data.date_failure, /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/);
            // Phản hồi API cũ tới trước các callback MySQL; chờ callback giả hoàn tất.
            await new Promise(resolve => setImmediate(resolve));
        });
    }
}

test('API seed tạo 5 bản gốc và 450 bản sao, chỉ dùng database giả', async t => {
    const seedRows = [
        { id: 1, title: 'Máy mẫu', serial: 'SEED', status: 'active', last_inspection: null,
            next_inspection: null, last_maintenance: null, next_maintenance: null, created_at: null, updated_at: null }
    ];
    const steps = [{ sql: /^TRUNCATE TABLE medical_equipments$/, result: {} }];
    for (let i = 0; i < 5; i++) {
        steps.push({ sql: /^INSERT INTO medical_equipments \(title, serial/, inspect({ params }) {
            assert.equal(params[1], 'SN-GOC-' + i);
            assert.equal(params[2], 'active');
        }, result: { affectedRows: 1 } });
    }
    steps.push({ sql: /^SELECT \* FROM medical_equipments$/, result: seedRows });
    steps.push({ sql: /^INSERT INTO medical_equipments \(title, serial/, inspect({ sql, params }) {
        assert.doesNotMatch(sql, /\(id,/);
        assert.equal(params[0].length, 450);
        assert.equal(params[0][0].length, 9);
        assert.equal(new Set(params[0].map(row => row[1])).size, 450);
    }, result: { affectedRows: 450 } });

    const request = await startTestApp(t, createDatabaseStub(steps));
    const response = await request('/api/v1/auto-seed');
    assert.equal(response.status, 200);
    assert.match(response.body, /455/);
});

test('Seed dừng khi không xóa được bảng, không chèn dữ liệu tiếp', async t => {
    const db = createDatabaseStub([{ error: new Error('Truncate failed') }]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/auto-seed');
    assert.equal(response.status, 500);
    assert.equal(response.body, 'Lỗi dọn rác DB: Truncate failed');
});
