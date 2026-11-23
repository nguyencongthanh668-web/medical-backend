const formatEquipment = require('../formatters/equipment.formatter');
const { toLocalDate } = require('../utils/date');
const HttpError = require('../utils/http-error');
const { departmentScope, loadEquipment } = require('../services/access');
const { parseId, requiredText, optionalText, optionalDate, optionalNonNegativeInt } = require('../utils/validate');

// Đọc và kiểm tra dữ liệu hồ sơ thiết bị từ form (FR-01). required = true khi tạo mới.
function readEquipmentFields(body, required) {
    const f = {};
    if (required || body.title !== undefined) f.title = requiredText(body.title, 'Vui lòng nhập tên thiết bị', 255);
    if (required || body.code !== undefined) f.code = requiredText(body.code, 'Vui lòng nhập mã thiết bị', 100);
    if (required || body.department_id !== undefined) f.department_id = parseId(body.department_id, 'khoa/phòng');
    for (const key of ['serial', 'model', 'manufacturer']) {
        if (body[key] !== undefined) f[key] = optionalText(body[key], 255);
    }
    if (body.devices_id !== undefined && body.devices_id !== null && body.devices_id !== '') f.devices_id = parseId(body.devices_id, 'danh mục thiết bị');
    const cycle = optionalNonNegativeInt(body.regular_maintenance, 'Chu kỳ bảo dưỡng (tháng)');
    if (cycle !== undefined) f.regular_maintenance = cycle;
    for (const key of ['last_maintenance', 'next_maintenance', 'next_inspection']) {
        if (body[key] !== undefined) f[key] = optionalDate(body[key], key);
    }
    if (required) f.status = 'active';
    return f;
}

function createEquipmentController(equipmentRepository) {
    return {
        listV1(req, res) {
            try {
                equipmentRepository.findAllV1(req.query.status, (err, results) => {
                    if (err) {
                        console.error('Lỗi query equipments v1:', err);
                        return res.status(500).json({ status: '500', message: err.message });
                    }

                    const data = (results || []).map(formatEquipment);
                    res.status(200).json({
                        status: '200', status_code: 200, success: true,
                        data, total: data.length, dataLength: data.length
                    });
                }, departmentScope(req.user));
            } catch (err) {
                res.status(500).json({ status: '500', message: err.message });
            }
        },

        listV2(req, res) {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 15;
                const offset = (page - 1) * limit;
                const status = req.query.status;
                const scope = departmentScope(req.user);

                equipmentRepository.countV2(status, (countError, countResults) => {
                    if (countError) return res.status(500).json({ status: '500', message: countError.message });

                    const total = countResults[0].total;
                    equipmentRepository.findPageV2({ status, limit, offset, departmentId: scope }, (listError, results) => {
                        if (listError) return res.status(500).json({ status: '500', message: listError.message });

                        const data = (results || []).map(formatEquipment);
                        const baseUrl = `${req.protocol}://${req.get('host')}/api/v2/equipments`;

                        // Không có ?page: API cũ trả mảng phẳng cho màn hình tổng quan.
                        if (!req.query.page) {
                            return res.status(200).json({
                                status: '200', data, total: data.length,
                                per_page: data.length || 15, current_page: 1,
                                last_page: 1, from: 1, to: data.length
                            });
                        }

                        res.status(200).json({
                            status: '200', status_code: 200, total,
                            data: {
                                total, current_page: page, data,
                                first_page_url: `${baseUrl}?page=1`,
                                from: total > 0 ? offset + 1 : 0,
                                next_page_url: offset + limit < total ? `${baseUrl}?page=${page + 1}` : null,
                                path: baseUrl, per_page: limit,
                                prev_page_url: page > 1 ? `${baseUrl}?page=${page - 1}` : null,
                                to: Math.min(offset + limit, total)
                            },
                            dataLength: data.length
                        });
                    });
                }, scope);
            } catch (err) {
                res.status(500).json({ status: '500', message: err.message });
            }
        },

        // Alias số ít có cấu trúc phản hồi riêng trong chương trình gốc.
        listLegacy(req, res) {
            try {
                equipmentRepository.findLegacyList(req.query.status, (err, results) => {
                    if (err) {
                        console.error('Lỗi lấy danh sách thiết bị:', err);
                        return res.status(500).json({ status_code: 500, message: 'Lỗi truy vấn cơ sở dữ liệu' });
                    }

                    const data = (results || []).map(formatEquipment);
                    const total = data.length;
                    res.status(200).json({
                        status_code: 200, status: 200, success: true, total,
                        data: { total, current_page: 1, per_page: total || 15, data, from: 1, to: total }
                    });
                }, departmentScope(req.user));
            } catch (err) {
                res.status(500).json({ status_code: 500, message: err.message });
            }
        },

        detail(req, res) {
            try {
                equipmentRepository.findById(req.params.id, (err, results) => {
                    if (err) {
                        console.error('Lỗi lấy chi tiết thiết bị:', err);
                        return res.status(500).json({ status_code: 500, message: err.message });
                    }
                    if (!results || results.length === 0) {
                        return res.status(404).json({ status_code: 404, message: 'Không tìm thấy thiết bị' });
                    }
                    const scope = departmentScope(req.user);
                    if (scope != null && Number(results[0].department_id) !== Number(scope)) {
                        return res.status(403).json({ status_code: 403, message: 'Thiết bị không thuộc khoa của bạn' });
                    }

                    // Bắt lỗi ngay trong callback vì truy vấn MySQL là bất đồng bộ.
                    try {
                        const data = formatEquipment(results[0]);
                        const dateFields = [
                            'last_inspection', 'next_inspection', 'last_maintenance',
                            'next_maintenance', 'created_at', 'updated_at', 'warranty_date'
                        ];
                        // mysql2 trả DATE/DATETIME theo giờ máy chủ, nên lấy ngày theo giờ địa phương
                        // (dùng UTC sẽ lùi một ngày với dữ liệu giờ Việt Nam).
                        for (const field of dateFields) {
                            if (data[field]) data[field] = toLocalDate(data[field]);
                        }
                        res.status(200).json({ status: '200', message: 'Thành công', data });
                    } catch (error) {
                        res.status(500).json({ status_code: 500, message: error.message });
                    }
                });
            } catch (err) {
                res.status(500).json({ status_code: 500, message: err.message });
            }
        },

        // Tạo hồ sơ thiết bị (FR-01, U3). Mã QR ở ứng dụng mã hóa chuỗi qr_content.
        async create(req, res) {
            const fields = readEquipmentFields(req.body || {}, true);
            if (await equipmentRepository.codeExists(fields.code)) throw new HttpError(409, 'Mã thiết bị đã tồn tại');
            const id = await equipmentRepository.create(fields);
            res.status(201).json({
                status_code: 201, message: 'Đã tạo hồ sơ thiết bị',
                data: { id, ...fields, qr_content: `medical-equipment:${id}` }
            });
        },

        async update(req, res) {
            const id = parseId(req.params.id);
            await loadEquipment(equipmentRepository, id);
            const fields = readEquipmentFields(req.body || {}, false);
            if (fields.code && await equipmentRepository.codeExists(fields.code, id)) {
                throw new HttpError(409, 'Mã thiết bị đã tồn tại');
            }
            await equipmentRepository.update(id, fields);
            res.status(200).json({ status_code: 200, message: 'Đã cập nhật hồ sơ thiết bị', data: { id, ...fields } });
        }
    };
}

module.exports = createEquipmentController;
