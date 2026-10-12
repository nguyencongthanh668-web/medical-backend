const formatEquipment = require('../formatters/equipment.formatter');
const { toDateString } = require('../utils/date');

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
                });
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

                equipmentRepository.countV2(status, (countError, countResults) => {
                    if (countError) return res.status(500).json({ status: '500', message: countError.message });

                    const total = countResults[0].total;
                    equipmentRepository.findPageV2({ status, limit, offset }, (listError, results) => {
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
                });
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
                });
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

                    // Bắt lỗi ngay trong callback vì truy vấn MySQL là bất đồng bộ.
                    try {
                        const data = formatEquipment(results[0]);
                        const dateFields = [
                            'last_inspection', 'next_inspection', 'last_maintenance',
                            'next_maintenance', 'created_at', 'updated_at', 'warranty_date'
                        ];
                        for (const field of dateFields) {
                            if (data[field]) data[field] = toDateString(new Date(data[field]));
                        }
                        res.status(200).json({ status: '200', message: 'Thành công', data });
                    } catch (error) {
                        res.status(500).json({ status_code: 500, message: error.message });
                    }
                });
            } catch (err) {
                res.status(500).json({ status_code: 500, message: err.message });
            }
        }
    };
}

module.exports = createEquipmentController;
