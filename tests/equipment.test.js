const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createDatabaseStub, startTestApp } = require('./helpers');
const fixture = require('./fixtures/equipment.json');

const groupedStatus = /WHERE \(status = 'corrected' OR status = 'was_broken'\)/;

for (const [status, sql, params] of [
    ['', /^SELECT \* FROM medical_equipments ORDER BY/, []],
    ['all', /^SELECT \* FROM medical_equipments ORDER BY/, []],
    ['corrected', groupedStatus, []],
    ['was_broken', groupedStatus, []],
    ['active', /WHERE status = 'active'/, []],
    ['maintenance', /WHERE status = \?/, ['maintenance']]
]) {
    test(`V1: bộ lọc "${status}" và toàn bộ cấu trúc DeviceModel`, async t => {
        const db = createDatabaseStub([{ sql, params, result: [fixture.row] }]);
        const request = await startTestApp(t, db);
        const response = await request('/api/v1/equipments?status=' + status);
        assert.equal(response.status, 200);
        assert.deepEqual(response.body, {
            status: '200', status_code: 200, success: true,
            data: [fixture.expected], total: 1, dataLength: 1
        });
    });
}

test('V1: không có thiết bị vẫn trả mảng rỗng', async t => {
    const request = await startTestApp(t, createDatabaseStub([{ result: [] }]));
    const { body } = await request('/api/v1/equipments');
    assert.deepEqual(body.data, []);
    assert.equal(body.total, 0);
});

test('V2: phân trang, tổng số lượng và các URL trang', async t => {
    const db = createDatabaseStub([
        { sql: groupedStatus, params: [], result: [{ total: 50 }] },
        { sql: /LIMIT \? OFFSET \?$/, params: [10, 10], result: [fixture.row] }
    ]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v2/equipments?page=2&limit=10&status=corrected');
    const baseUrl = response.baseUrl + '/api/v2/equipments';
    assert.deepEqual(response.body, {
        status: '200', status_code: 200, total: 50,
        data: {
            total: 50, current_page: 2, data: [fixture.expected],
            first_page_url: baseUrl + '?page=1', from: 11,
            next_page_url: baseUrl + '?page=3', path: baseUrl, per_page: 10,
            prev_page_url: baseUrl + '?page=1', to: 20
        }, dataLength: 1
    });
});

test('V2: was_broken được lọc riêng, không có page trả mảng phẳng', async t => {
    const db = createDatabaseStub([
        { sql: /WHERE status = \?$/, params: ['was_broken'], result: [{ total: 20 }] },
        { params: ['was_broken', 15, 0], result: [fixture.row] }
    ]);
    const request = await startTestApp(t, db);
    assert.deepEqual((await request('/api/v2/equipments?status=was_broken')).body, {
        status: '200', data: [fixture.expected], total: 1,
        per_page: 1, current_page: 1, last_page: 1, from: 1, to: 1
    });
});

test('V2: trang rỗng không có URL trang trước/sau', async t => {
    const db = createDatabaseStub([{ result: [{ total: 0 }] }, { params: [15, 0], result: [] }]);
    const request = await startTestApp(t, db);
    const { body } = await request('/api/v2/equipments?page=1');
    assert.equal(body.data.from, 0);
    assert.equal(body.data.to, 0);
    assert.equal(body.data.next_page_url, null);
    assert.equal(body.data.prev_page_url, null);
    assert.deepEqual(body.data.data, []);
});

test('Alias /v1/equipment giữ status dạng số và data lồng nhau', async t => {
    const db = createDatabaseStub([{ sql: /WHERE 1=1 AND status = \?/, params: ['active'], result: [fixture.row] }]);
    const request = await startTestApp(t, db);
    const { body } = await request('/api/v1/equipment?status=active');
    assert.deepEqual(body, {
        status_code: 200, status: 200, success: true, total: 1,
        data: { total: 1, current_page: 1, per_page: 1, data: [fixture.expected], from: 1, to: 1 }
    });
});

for (const version of ['v1', 'v2']) {
    for (const resource of ['equipment', 'equipments']) {
        test(`Chi tiết ${version}/${resource}: định dạng ngày và trường nullable`, async t => {
            const row = { ...fixture.row, last_inspection: '2026-09-01T08:30:00.000Z', warranty_date: '2027-09-01' };
            const db = createDatabaseStub([{ sql: /WHERE id = \?$/, params: ['7'], result: [row] }]);
            const request = await startTestApp(t, db);
            const response = await request(`/api/${version}/${resource}/7`);
            assert.equal(response.status, 200);
            assert.deepEqual(response.body, { status: '200', message: 'Thành công', data: {
                ...fixture.expected, created_at: '2026-09-10', last_inspection: '2026-09-01', warranty_date: '2027-09-01'
            } });
        });
    }
    for (const history of ['inspections', 'maintenances']) {
        test(`Lịch sử mẫu ${version}/${history} vẫn khả dụng`, async t => {
            const request = await startTestApp(t);
            const { body } = await request(`/api/${version}/equipments/7/${history}`);
            assert.equal(body.status_code, 200);
            assert.equal(body.data.length, 2);
            assert.equal(body.data[0].equipment_id, 7);
            assert.equal(body.data[0].user_id, body.data[0].user.id);
            assert.equal(body.data[0].type, 'inspection');
            assert.equal(body.data[0].status, 1);
            assert.equal(body.data[1].status, 0);
            assert.match(body.data[0].date, /^\d{4}-\d{2}-\d{2}$/);
        });
    }
}

test('Chi tiết thiết bị không tồn tại trả 404', async t => {
    const request = await startTestApp(t, createDatabaseStub([{ result: [] }]));
    const response = await request('/api/v1/equipments/999');
    assert.equal(response.status, 404);
    assert.deepEqual(response.body, { status_code: 404, message: 'Không tìm thấy thiết bị' });
});

test('Ngày không hợp lệ được bắt trong callback, không làm sập server', async t => {
    const db = createDatabaseStub([{ result: [{ id: 7, last_inspection: 'invalid-date' }] }]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/equipments/7');
    assert.equal(response.status, 500);
    assert.equal(response.body.status_code, 500);
    assert.equal((await request('/')).status, 200);
});

for (const path of ['/api/v1/equipments', '/api/v2/equipments?page=1', '/api/v1/equipment', '/api/v1/equipments/7']) {
    test(`Lỗi truy vấn thiết bị: ${path}`, async t => {
        const request = await startTestApp(t, createDatabaseStub([{ error: new Error('Test database error') }]));
        const response = await request(path);
        assert.equal(response.status, 500);
        assert.equal(response.body.message, path === '/api/v1/equipment' ? 'Lỗi truy vấn cơ sở dữ liệu' : 'Test database error');
    });
}

test('V2: lỗi truy vấn danh sách sau khi đếm thành công', async t => {
    const db = createDatabaseStub([{ result: [{ total: 10 }] }, { error: new Error('List failed') }]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v2/equipments?page=1');
    assert.equal(response.status, 500);
    assert.deepEqual(response.body, { status: '500', message: 'List failed' });
});
