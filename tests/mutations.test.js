const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createDatabaseStub, startTestApp } = require('./helpers');
const config = require('../src/config/env');

const equipment = { id: 7, title: 'Máy thở', code: 'TB-007', status: 'active', department_id: 3, regular_maintenance: 6 };
const findEquipment = (row = equipment) => ({ sql: /^SELECT id, title, code, status, department_id/, params: [7], result: row ? [row] : [] });

const reportPaths = [];
for (const version of ['v1', 'v2']) {
    for (const resource of ['equipment', 'equipments']) {
        reportPaths.push(`/api/${version}/${resource}/7/repair`, `/api/${version}/${resource}/7/failure`);
    }
    reportPaths.push(`/api/${version}/equipments/repair`, `/api/${version}/repairs`);
}

for (const path of reportPaths) {
    test(`TC-02 báo hỏng ${path}: đổi trạng thái và tạo thông báo trong một giao dịch`, async t => {
        const db = createDatabaseStub([
            findEquipment(),
            { sql: /^UPDATE medical_equipments SET status = 'was_broken', date_failure = NOW\(\), reason = \?/,
                params: ['Không khởi động', 'Khẩn cấp', 7], result: { affectedRows: 1 } },
            { sql: /^INSERT INTO notifications/, inspect({ params }) {
                assert.match(params[0], /^fault_/);
                assert.equal(params[1], 'App\\Notifications\\ReportFailureNotifications');
                assert.equal(params[4], 7);
                assert.equal(params[5], 11);
                assert.match(params[6], /Máy thở được báo hỏng: Không khởi động/);
            }, result: { affectedRows: 1 } }
        ]);
        const request = await startTestApp(t, db);
        const response = await request(path, {
            method: 'POST', as: 'department',
            body: { equipment_id: 7, symptom: 'Không khởi động', critical_level: 'Khẩn cấp' }
        });
        assert.equal(response.status, 201);
        assert.equal(response.body.data.status, 'was_broken');
        assert.equal(response.body.data.reason, 'Không khởi động');
        assert.deepEqual(db.tx, ['BEGIN', 'COMMIT', 'RELEASE']);
    });
}

test('TC-02: gửi lại cùng request_id sau khi mất mạng không tạo bản ghi trùng', async t => {
    const db = createDatabaseStub([
        { sql: /^SELECT id, data_id, created_at FROM notifications WHERE id = \?/, params: ['fault_abc-1'], result: [{ id: 'fault_abc-1', data_id: 7 }] }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/repair', {
        method: 'POST', as: 'department', body: { symptom: 'Mất nguồn', request_id: 'abc-1' }
    });
    assert.equal(response.status, 200);
    assert.equal(response.body.duplicate, true);
    assert.deepEqual(db.tx, []);
});

test('Báo hỏng: thiếu hiện tượng 400, khác khoa 403, không có máy 404, đang hỏng 409, sai vai trò 403', async t => {
    const db = createDatabaseStub([
        findEquipment({ ...equipment, department_id: 9 }),
        findEquipment(null),
        findEquipment({ ...equipment, status: 'was_broken' })
    ]);
    const request = await startTestApp(t, db);
    const send = (body, as = 'department') => request('/api/v1/equipments/7/repair', { method: 'POST', as, body });
    assert.equal((await send({})).status, 400);
    assert.equal((await send({ symptom: 'Hỏng' })).status, 403);
    assert.equal((await send({ symptom: 'Hỏng' })).status, 404);
    const busy = await send({ symptom: 'Hỏng' });
    assert.equal(busy.status, 409);
    assert.equal((await send({ symptom: 'Hỏng' }, 'technician')).status, 403);
});

test('Báo hỏng: lỗi khi ghi thông báo thì ROLLBACK cả việc đổi trạng thái', async t => {
    const db = createDatabaseStub([
        findEquipment(),
        { sql: /^UPDATE medical_equipments/, result: { affectedRows: 1 } },
        { sql: /^INSERT INTO notifications/, error: new Error('Mất kết nối') }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/repair', { method: 'POST', as: 'department', body: { symptom: 'Hỏng' } });
    assert.equal(response.status, 500);
    assert.deepEqual(db.tx, ['BEGIN', 'ROLLBACK', 'RELEASE']);
});

test('API seed: chỉ U4 và chỉ khi ALLOW_SEED=true', async t => {
    const request = await startTestApp(t);
    assert.equal((await request('/api/v1/auto-seed')).status, 403);
    const before = config.allowSeed;
    config.allowSeed = false;
    const off = await request('/api/v1/auto-seed', { as: 'admin' });
    assert.equal(off.status, 403);
    config.allowSeed = before;
});

test('API seed tạo 5 bản gốc và 450 bản sao khi được bật, chỉ dùng database giả', async t => {
    const seedRows = [
        { id: 1, title: 'Máy mẫu', serial: 'SEED', status: 'active', last_inspection: null,
            next_inspection: null, last_maintenance: null, next_maintenance: null, created_at: null, updated_at: null }
    ];
    const steps = [{ sql: /^TRUNCATE TABLE medical_equipments$/, result: {} }];
    for (let i = 0; i < 5; i++) {
        steps.push({ sql: /^INSERT INTO medical_equipments \(title, serial/, result: { affectedRows: 1 } });
    }
    steps.push({ sql: /^SELECT \* FROM medical_equipments$/, result: seedRows });
    steps.push({ sql: /^INSERT INTO medical_equipments \(title, serial/, inspect({ params }) {
        assert.equal(params[0].length, 450);
    }, result: { affectedRows: 450 } });

    const before = config.allowSeed;
    config.allowSeed = true;
    t.after(() => { config.allowSeed = before; });
    const request = await startTestApp(t, createDatabaseStub(steps));
    const response = await request('/api/v1/auto-seed', { as: 'admin' });
    assert.equal(response.status, 200);
    assert.match(response.body, /455/);
});
