const { Router } = require('express');
const createEquipmentRepository = require('../repositories/equipment.repository');
const createSeedController = require('../controllers/seed.controller');

function createSeedRouter(db) {
    const router = Router();
    const controller = createSeedController(createEquipmentRepository(db));
    // API cũ có tác dụng xóa và tạo lại dữ liệu mẫu; không gọi để kiểm tra server.
    router.get('/v1/auto-seed', controller.seed);
    return router;
}

module.exports = createSeedRouter;
