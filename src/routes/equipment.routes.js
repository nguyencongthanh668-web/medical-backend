const { Router } = require('express');
const createEquipmentRepository = require('../repositories/equipment.repository');
const createNotificationRepository = require('../repositories/notification.repository');
const createInspectionRepository = require('../repositories/inspection.repository');
const createMaintenanceRecordRepository = require('../repositories/maintenance-record.repository');
const createEquipmentController = require('../controllers/equipment.controller');
const createRepairController = require('../controllers/repair.controller');
const createInspectionController = require('../controllers/inspection.controller');
const createAcceptanceController = require('../controllers/acceptance.controller');
const createHistoryController = require('../controllers/history.controller');
const { requireRole } = require('../middleware/auth');
const { ROLES } = require('../config/roles');

function createEquipmentRouter(db) {
    const router = Router();
    const equipmentRepository = createEquipmentRepository(db);
    const notificationRepository = createNotificationRepository(db);
    const inspectionRepository = createInspectionRepository(db);
    const recordRepository = createMaintenanceRecordRepository(db);
    const deps = { db, equipmentRepository, notificationRepository, inspectionRepository, recordRepository };

    const controller = createEquipmentController(equipmentRepository);
    const repair = createRepairController(deps);
    const inspection = createInspectionController(deps);
    const acceptance = createAcceptanceController(deps);
    const history = createHistoryController(deps);
    const v = (path) => [`/v1${path}`, `/v2${path}`];

    // FR-01, FR-05: danh sách và chi tiết (U1 chỉ thấy thiết bị của khoa mình).
    router.get('/v1/equipments', controller.listV1);
    router.get('/v2/equipments', controller.listV2);
    router.get('/v1/equipment', controller.listLegacy);

    // FR-05: lịch sử thật; hai đường dẫn cũ /inspections, /maintenances trả cùng dữ liệu.
    router.get([...v('/equipments/:id/history'), ...v('/equipments/:id/inspections'), ...v('/equipments/:id/maintenances')], history.list);

    // FR-03: kết quả kiểm tra sơ bộ.
    router.get(v('/equipments/:id/inspection-results'), inspection.list);
    router.post(v('/equipments/:id/inspection-results'), requireRole(ROLES.TECHNICIAN), inspection.create);

    // FR-06: nghiệm thu, chi phí.
    router.put(v('/equipments/:id/acceptance'), requireRole(ROLES.MANAGER), acceptance.accept);

    // FR-02: báo hỏng. Đăng ký đường dẫn cố định trước :id để "repair" không bị hiểu là ID.
    const reportPaths = [...v('/equipments/repair'), ...v('/repairs')];
    for (const resource of ['equipment', 'equipments']) {
        reportPaths.push(...v(`/${resource}/:id/repair`), ...v(`/${resource}/:id/failure`));
    }
    router.post(reportPaths, requireRole(ROLES.DEPARTMENT), repair.reportFailure);

    const detailPaths = [...v('/equipments/:id'), ...v('/equipment/:id')];
    router.get(detailPaths, controller.detail);

    // FR-01: tạo và sửa hồ sơ (U3).
    router.post('/v1/equipments', requireRole(ROLES.MANAGER), controller.create);
    router.put(v('/equipments/:id'), requireRole(ROLES.MANAGER), controller.update);
    return router;
}

module.exports = createEquipmentRouter;
