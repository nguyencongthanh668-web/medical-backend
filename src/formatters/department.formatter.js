// Các giá trị mặc định giữ nguyên hợp đồng JSON với DepartmentModel của Flutter.
function formatDepartment(row) {
    return {
        id: row.id,
        title: row.title,
        code: 'KHOA_' + row.id,
        slug: 'khoa-phong-' + row.id,
        phone: '0243123456',
        contact: 'Trưởng khoa',
        email: 'contact@benhvien.com',
        address: 'Khu A - Bệnh viện',
        userId: 1,
        user_id: 1,
        createdAt: '2026-09-22T00:00:00.000Z',
        created_at: '2026-09-22T00:00:00.000Z',
        updatedAt: '2026-09-22T00:00:00.000Z',
        updated_at: '2026-09-22T00:00:00.000Z'
    };
}

module.exports = formatDepartment;
