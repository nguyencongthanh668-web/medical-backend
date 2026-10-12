const { Router } = require('express');
const createEquipmentRepository = require('../repositories/equipment.repository');
const createNotificationRepository = require('../repositories/notification.repository');
const createEquipmentController = require('../controllers/equipment.controller');
const createRepairController = require('../controllers/repair.controller');
const historyController = require('../controllers/history.controller');

function createEquipmentRouter(db) {
    const router = Router();
    const repository = createEquipmentRepository(db);
    const controller = createEquipmentController(repository);
    const repairController = createRepairController(repository, createNotificationRepository(db));

    router.get('/v1/equipments', controller.listV1);
    router.get('/v2/equipments', controller.listV2);
    router.get('/v1/equipment', controller.listLegacy);

    router.get([
        '/v1/equipments/:id/inspections', '/v2/equipments/:id/inspections',
        '/v1/equipments/:id/maintenances', '/v2/equipments/:id/maintenances'
    ], historyController.list);

    const detailPaths = [
        '/v1/equipments/:id', '/v2/equipments/:id',
        '/v1/equipment/:id', '/v2/equipment/:id'
    ];
    router.get(detailPaths, controller.detail);

    // Đăng ký đường dẫn cố định trước :id để "repair" không bị hiểu là ID thiết bị.
    router.post([
        '/v1/equipments/repair', '/v2/equipments/repair',
        '/v1/repairs', '/v2/repairs'
    ], repairController.reportFailure);

    router.post([
        ...detailPaths,
        '/v1/equipments/:id/repair', '/v2/equipments/:id/repair',
        '/v1/equipment/:id/repair', '/v2/equipment/:id/repair',
        '/v1/equipments/:id/failure', '/v2/equipments/:id/failure',
        '/v1/equipment/:id/failure', '/v2/equipment/:id/failure'
    ], repairController.reportFailure);

    router.put(detailPaths, repairController.reportFailure);
    return router;
}

module.exports = createEquipmentRouter;
