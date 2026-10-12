const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createDatabaseStub, startTestApp } = require('./helpers');

test('Server, CORS và đăng nhập/đăng xuất giữ phản hồi cũ', async t => {
    const request = await startTestApp(t);
    const health = await request('/');
    assert.equal(health.status, 200);
    assert.deepEqual(health.body, { message: 'Máy chủ đang hoạt động!' });
    assert.equal(health.headers.get('access-control-allow-origin'), '*');

    const login = await request('/api/login', {
        method: 'POST', body: { email: 'admin@gmail.com', password: '123456' }
    });
    assert.equal(login.status, 200);
    assert.deepEqual(login.body, {
        status_code: 200, access_token: 'chuoi_token_bi_mat_cua_admin_123456', token_type: 'Bearer',
        data: {
            id: 1, displayName: 'Quản trị viên Hệ thống', email: 'admin@gmail.com',
            phone: '0987654321', birthday: '1990-01-01', gender: '1',
            profilePhotoUrl: 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
        }
    });
    const rejected = await request('/api/login', { method: 'POST', body: { email: 'unknown', password: 'wrong' } });
    assert.equal(rejected.status, 401);
    assert.deepEqual(rejected.body, { message: 'Sai tài khoản hoặc mật khẩu' });
    const logout = await request('/api/v1/logout', { method: 'POST' });
    assert.deepEqual(logout.body, { status_code: 200, message: 'Đăng xuất thành công' });
    assert.equal((await request('/does-not-exist')).status, 404);
});

test('Danh sách devices trả mảng trực tiếp', async t => {
    const rows = [{ id: 7, title: 'Thiết bị thử nghiệm' }];
    const db = createDatabaseStub([{ sql: /^SELECT \* FROM devices$/, result: rows }]);
    const request = await startTestApp(t, db);
    const response = await request('/api/devices');
    assert.equal(response.status, 200);
    assert.deepEqual(response.body, rows);
});

test('Thông báo chuyển dữ liệu phẳng thành object data lồng nhau', async t => {
    const row = { id: 'n1', type: 'failure', notifiable_id: 1, notifiable_type: 'User', read_at: null,
        created_at: '2026-10-01', updated_at: '2026-10-01', data_id: 7, data_user_id: 1, data_content: 'Mẫu' };
    const db = createDatabaseStub([{ sql: /FROM notifications ORDER BY created_at DESC$/, result: [row] }]);
    const request = await startTestApp(t, db);
    const response = await request('/api/v1/notification');
    assert.deepEqual(response.body, { status: 1, total: 1, data: [{
        id: 'n1', type: 'failure', notifiable_id: 1, notifiable_type: 'User', read_at: null,
        created_at: '2026-10-01', updated_at: '2026-10-01', data: { id: 7, user_id: 1, content: 'Mẫu' }
    }] });
});

for (const department of ['', '?department_id=3']) {
    test(`Danh sách nhân viên ${department || 'không lọc'}`, async t => {
        const db = createDatabaseStub([{
            sql: department ? /WHERE department_id = \?$/ : /^SELECT \* FROM users$/,
            params: department ? ['3'] : [], result: [{ id: '8', name: 'Nguyễn An', department_id: '3' }, { id: '9' }]
        }]);
        const request = await startTestApp(t, db);
        const { body } = await request('/api/v1/users' + department);
        assert.equal(body.dataLength, 2);
        assert.equal(body.data[0].id, 8);
        assert.equal(body.data[0].department_id, 3);
        assert.match(body.data[0].profile_photo_url, /ui-avatars\.com/);
        assert.equal(body.data[1].name, 'User');
        assert.equal(body.data[1].phone, '');
        assert.equal(body.data[1].image, null);
    });
}

test('Chi tiết người dùng giữ dữ liệu và trả 404 khi không tìm thấy', async t => {
    const user = { id: 8, name: 'Nguyễn An', department_id: 3 };
    const db = createDatabaseStub([
        { params: ['8'], result: [user] }, { params: ['999'], result: [] }
    ]);
    const request = await startTestApp(t, db);
    assert.deepEqual((await request('/api/v1/users/8')).body, { status_code: 200, data: user });
    const missing = await request('/api/v1/users/999');
    assert.equal(missing.status, 404);
    assert.deepEqual(missing.body, { status_code: 404, message: 'Không tìm thấy người dùng' });
});

test('Khoa phòng dùng route có hiệu lực trong bản gốc, giữ camelCase và snake_case', async t => {
    const db = createDatabaseStub([{ sql: /^SELECT \* FROM departments$/, result: [{ id: 3, title: 'Khoa A' }] }]);
    const request = await startTestApp(t, db);
    const { body } = await request('/api/v1/departments');
    assert.equal(body.status_code, 200);
    assert.equal(body.data[0].title, 'Khoa A');
    assert.equal(body.data[0].code, 'KHOA_3');
    assert.equal(body.data[0].userId, body.data[0].user_id);
    assert.equal(body.data[0].createdAt, body.data[0].created_at);
    assert.equal(body.dataLength, undefined);

    for (const version of ['v1', 'v2']) {
        const detail = await request(`/api/${version}/departments/3`);
        assert.deepEqual(detail.body, { status_code: 200, success: true, data: {
            id: 3, title: 'Khoa phòng số 3', name: 'Khoa phòng số 3', display_name: 'Khoa phòng số 3'
        } });
    }
});

for (const [path, expected] of [
    ['/api/devices', { error: 'Lỗi truy vấn dữ liệu' }],
    ['/api/v1/users', { error: 'Lỗi Server' }],
    ['/api/v1/users/1', { status_code: 500, message: 'Lỗi Server' }],
    ['/api/v1/departments', { status_code: 500, message: 'Lỗi Server' }],
    ['/api/v1/notification', { status_code: 500, message: 'Lỗi Server' }]
]) {
    test(`Lỗi database: ${path}`, async t => {
        const db = createDatabaseStub([{ error: new Error('Test database error') }]);
        const request = await startTestApp(t, db);
        const response = await request(path);
        assert.equal(response.status, 500);
        assert.deepEqual(response.body, expected);
    });
}
