const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createDatabaseStub, startTestApp } = require('./helpers');
const { milestoneFor } = require('../src/services/maintenance-alert.service');

const base = { id: 7, title: 'Máy thở', code: 'TB-007', department_id: 3, regular_maintenance: 6 };
const findEquipment = (status) => ({ sql: /^SELECT id, title, code, status, department_id/, params: [7], result: [{ ...base, status }] });

test('TC-01: tạo hồ sơ thiết bị; trùng mã trả 409; thiếu trường bắt buộc trả 400; chỉ U3', async t => {
    const db = createDatabaseStub([
        { sql: /^SELECT id FROM medical_equipments WHERE code = \? LIMIT 1$/, params: ['TB-100'], result: [] },
        { sql: /^INSERT INTO medical_equipments \(title, code, department_id, regular_maintenance, next_maintenance, status, created_at/,
            params: ['Monitor', 'TB-100', 3, 6, '2027-01-15', 'active'], result: { insertId: 100 } },
        { sql: /WHERE code = \?/, result: [{ id: 5 }] }
    ]);
    const request = await startTestApp(t, db);
    const body = { title: 'Monitor', code: 'TB-100', department_id: 3, regular_maintenance: 6, next_maintenance: '2027-01-15' };
    const created = await request('/api/v1/equipments', { method: 'POST', body });
    assert.equal(created.status, 201);
    assert.equal(created.body.data.id, 100);
    assert.equal(created.body.data.qr_content, 'medical-equipment:100');
    assert.equal((await request('/api/v1/equipments', { method: 'POST', body })).status, 409);
    assert.equal((await request('/api/v1/equipments', { method: 'POST', body: { title: 'Thiếu mã' } })).status, 400);
    assert.equal((await request('/api/v1/equipments', { method: 'POST', body, as: 'department' })).status, 403);
});

test('TC-03: kỹ thuật viên ghi kết quả kiểm tra, thiết bị chuyển sang đang sửa chữa', async t => {
    const db = createDatabaseStub([
        findEquipment('was_broken'),
        { sql: /^SELECT id FROM notifications WHERE data_id = \? AND type = \?/, result: [{ id: 'fault_x' }] },
        { sql: /^INSERT INTO inspection_results/, inspect({ params }) {
            assert.deepEqual(params, [7, 'fault_x', 12, 'Hỏng van thở ra', 'outsourced', null]);
        }, result: { insertId: 41 } },
        { sql: /^UPDATE medical_equipments SET status = \?/, params: ['corrected', 7], result: { affectedRows: 1 } }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/inspection-results', {
        method: 'POST', as: 'technician', body: { cause: 'Hỏng van thở ra', decision: 'outsourced' }
    });
    assert.equal(response.status, 201);
    assert.equal(response.body.data.id, 41);
    assert.equal(response.body.data.status, 'corrected');
    assert.deepEqual(db.tx, ['BEGIN', 'COMMIT', 'RELEASE']);
});

test('TC-03: sai hướng xử lý 400, máy không hỏng 409, U1 không được ghi kết quả', async t => {
    const db = createDatabaseStub([findEquipment('active')]);
    const request = await startTestApp(t, db);
    const send = (body, as = 'technician') => request('/api/v1/equipments/7/inspection-results', { method: 'POST', as, body });
    assert.equal((await send({ cause: 'X', decision: 'khac' })).status, 400);
    assert.equal((await send({ cause: 'X', decision: 'in_house' })).status, 409);
    assert.equal((await send({ cause: 'X', decision: 'in_house' }, 'department')).status, 403);
});

test('TC-06: nghiệm thu sửa chữa đạt đưa thiết bị về đang sử dụng', async t => {
    const db = createDatabaseStub([
        findEquipment('corrected'),
        { sql: /^SELECT id FROM inspection_results WHERE equipment_id = \?/, result: [{ id: 41 }] },
        { sql: /^INSERT INTO maintenance_records/, inspect({ params }) {
            assert.deepEqual(params.slice(0, 5), [7, 41, 'repair', 'pass', 2500000]);
            assert.equal(params[9], 13);
        }, result: { insertId: 9 } },
        { sql: /^UPDATE medical_equipments SET status = \?/, params: ['active', 7], result: { affectedRows: 1 } },
        findEquipment('active')
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/acceptance', {
        method: 'PUT', body: { type: 'repair', result: 'pass', cost: 2500000, completed_at: '2026-11-01', performed_by: 'Công ty ABC' }
    });
    assert.equal(response.status, 201);
    assert.equal(response.body.data.equipment_status, 'active');
});

test('TC-06: nghiệm thu không đạt giữ nguyên trạng thái hỏng', async t => {
    const db = createDatabaseStub([
        findEquipment('corrected'),
        { sql: /FROM inspection_results/, result: [] },
        { sql: /^INSERT INTO maintenance_records/, result: { insertId: 10 } },
        findEquipment('corrected')
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/acceptance', {
        method: 'PUT', body: { type: 'repair', result: 'fail', document_url: 'https://luu-tru/bien-ban-10.pdf' }
    });
    assert.equal(response.status, 201);
    assert.equal(response.body.data.equipment_status, 'corrected');
});

test('FR-06: bảo dưỡng đạt cập nhật last_maintenance và tính next_maintenance theo chu kỳ', async t => {
    const db = createDatabaseStub([
        findEquipment('active'),
        { sql: /^INSERT INTO maintenance_records/, result: { insertId: 11 } },
        { sql: /^UPDATE medical_equipments SET last_maintenance = \?, next_maintenance = CASE WHEN \? IS NOT NULL THEN \? WHEN regular_maintenance > 0 THEN DATE_ADD/,
            params: ['2026-11-01', null, null, '2026-11-01', '2026-11-01', 6, 7], result: { affectedRows: 1 } },
        { sql: /^SELECT id, title/, result: [{ ...base, status: 'active', next_maintenance: new Date(2027, 4, 1) }] }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/acceptance', {
        method: 'PUT', body: { type: 'maintenance', result: 'pass', completed_at: '2026-11-01' }
    });
    assert.equal(response.status, 201);
    assert.equal(response.body.data.next_maintenance, '2027-05-01');
});

test('Nghiệm thu: ngày ở tương lai 400, chi phí âm 400, chỉ U3', async t => {
    const request = await startTestApp(t);
    const send = (body, as = 'manager') => request('/api/v1/equipments/7/acceptance', { method: 'PUT', as, body });
    assert.equal((await send({ type: 'repair', result: 'pass', completed_at: '2999-01-01' })).status, 400);
    assert.equal((await send({ type: 'repair', result: 'pass', cost: -1 })).status, 400);
    assert.equal((await send({ type: 'repair', result: 'pass' }, 'technician')).status, 403);
});

test('TC-04: bộ quét tạo một cảnh báo cho mỗi mốc, mốc đã báo không báo lại', async t => {
    const db = createDatabaseStub([
        { sql: /FROM medical_equipments WHERE next_maintenance IS NOT NULL AND next_maintenance <= DATE_ADD\(CURDATE\(\), INTERVAL \? DAY\)/,
            params: [30], result: [
                { id: 7, title: 'Máy thở', next_maintenance: new Date(2026, 11, 1), days_left: 5 },
                { id: 8, title: 'Monitor', next_maintenance: new Date(2026, 11, 20), days_left: 20 }
            ] },
        { sql: /^INSERT IGNORE INTO maintenance_alerts/, params: [7, '2026-12-01', 7], result: { affectedRows: 1 } },
        { sql: /^INSERT INTO notifications/, inspect({ params }) {
            assert.equal(params[0], 'due_7_2026-12-01_7');
            assert.equal(params[1], 'App\\Notifications\\MaintenanceDueNotifications');
            assert.match(params[6], /01\/12\/2026 \(còn 5 ngày\)/);
        }, result: { affectedRows: 1 } },
        { sql: /^INSERT IGNORE INTO maintenance_alerts/, params: [8, '2026-12-20', 30], result: { affectedRows: 0 } }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/maintenance-alerts/scan', { method: 'POST' });
    assert.deepEqual(response.body.data, { scanned: 2, created: 1 });
});

test('Mốc cảnh báo: còn 30 → 30, 15 → 15, 7 hoặc quá hạn → 7', () => {
    assert.equal(milestoneFor(30), 30);
    assert.equal(milestoneFor(16), 30);
    assert.equal(milestoneFor(15), 15);
    assert.equal(milestoneFor(7), 7);
    assert.equal(milestoneFor(-3), 7);
});

test('Dashboard cảnh báo: chỉ U3, lọc theo 7/15/30 ngày', async t => {
    const db = createDatabaseStub([
        { sql: /AS alerted_milestone FROM medical_equipments e/, params: [15], result: [
            { id: 7, title: 'Máy thở', code: 'TB-007', department_id: 3, status: 'active', next_maintenance: new Date(2026, 11, 1), days_left: 5, alerted_milestone: 7 }
        ] }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/maintenance-alerts?days=15');
    assert.equal(response.body.total, 1);
    assert.equal(response.body.data[0].next_maintenance, '2026-12-01');
    assert.equal(response.body.data[0].alerted_milestone, 7);
    assert.equal((await request('/api/v1/maintenance-alerts', { as: 'department' })).status, 403);
});

test('TC-05: lịch sử gom báo hỏng, kiểm tra, nghiệm thu và tổng chi phí', async t => {
    const db = createDatabaseStub([
        findEquipment('active'),
        { sql: /FROM notifications n LEFT JOIN users u/, result: [
            { id: 'f1', created_at: new Date('2026-10-01T08:00:00Z'), data_content: 'Không bơm khí', user_name: 'Điều dưỡng A' },
            { id: 'f2', created_at: new Date('2026-06-01T08:00:00Z'), data_content: 'Báo lỗi áp lực', user_name: 'Điều dưỡng B' }
        ] },
        { sql: /FROM inspection_results i LEFT JOIN users u/, result: [
            { id: 41, inspected_at: new Date('2026-10-01T10:00:00Z'), cause: 'Hỏng van', decision: 'outsourced', user_name: 'KTV' }
        ] },
        { sql: /FROM maintenance_records r LEFT JOIN users u/, result: [
            { id: 9, type: 'repair', result: 'pass', cost: '2500000', completed_at: new Date('2026-10-05'), performed_by: 'Công ty ABC', user_name: 'Cán bộ' },
            { id: 8, type: 'maintenance', result: 'pass', cost: '500000', completed_at: new Date('2026-05-01'), user_name: 'Cán bộ' }
        ] }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7/history', { as: 'department' });
    assert.equal(response.status, 200);
    assert.deepEqual(response.body.data.summary, { failure_count: 2, repair_count: 1, maintenance_count: 1, total_cost: 3000000 });
    assert.deepEqual(response.body.data.events.map(e => e.kind), ['repair', 'inspection', 'fault', 'fault', 'maintenance']);
});

test('U4 tạo tài khoản và đổi vai trò; vai trò khác không được', async t => {
    const db = createDatabaseStub([
        { sql: /^SELECT \* FROM users WHERE email = \?/, params: ['ktv2@benhvien.vn'], result: [] },
        { sql: /^INSERT INTO users/, inspect({ params }) {
            assert.equal(params[2], 'ktv2@benhvien.vn');
            assert.match(params[3], /^scrypt\$/);
            assert.equal(params[4], 'technician');
        }, result: { insertId: 30 } },
        { sql: /^UPDATE users SET role = \? WHERE id = \?/, params: ['manager', 30], result: { affectedRows: 1 } }
    ]);
    const request = await startTestApp(t, db);
    const created = await request('/api/v1/users', { method: 'POST', as: 'admin',
        body: { name: 'KTV 2', email: 'KTV2@benhvien.vn', password: '123456', role: 'technician' } });
    assert.equal(created.status, 201);
    const patched = await request('/api/v1/users/30', { method: 'PATCH', as: 'admin', body: { role: 'manager' } });
    assert.equal(patched.status, 200);
    assert.equal((await request('/api/v1/users', { method: 'POST', as: 'manager', body: {} })).status, 403);
});
