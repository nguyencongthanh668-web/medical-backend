const { Router } = require('express');
const config = require('../config/env');
const createEquipmentRepository = require('../repositories/equipment.repository');
const createSeedController = require('../controllers/seed.controller');
const { requireRole } = require('../middleware/auth');
const { ROLES } = require('../config/roles');

function createSeedRouter(db) {
    const router = Router();
    const controller = createSeedController(createEquipmentRepository(db));
    // API này XÓA toàn bộ thiết bị rồi tạo dữ liệu mẫu: chỉ U4, và chỉ khi ALLOW_SEED=true.
    router.get('/v1/auto-seed', requireRole(ROLES.ADMIN), (req, res, next) => {
        if (!config.allowSeed) {
            return res.status(403).json({ status_code: 403, message: 'API tạo dữ liệu mẫu đang tắt (ALLOW_SEED=false)' });
        }
        next();
    }, controller.seed);
    return router;
}

module.exports = createSeedRouter;
