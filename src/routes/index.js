const { Router } = require('express');
const { authenticate } = require('../middleware/auth');
const createAuthRouter = require('./auth.routes');
const createDeviceRouter = require('./device.routes');
const createUserRouter = require('./user.routes');
const createNotificationRouter = require('./notification.routes');
const createDepartmentRouter = require('./department.routes');
const createEquipmentRouter = require('./equipment.routes');
const createAlertRouter = require('./alert.routes');
const createSeedRouter = require('./seed.routes');

function createApiRouter(db) {
    const router = Router();
    // Chỉ đăng nhập là công khai; mọi API phía sau đều cần token hợp lệ (NFR-06).
    router.use(createAuthRouter(db));
    router.use(authenticate);
    router.use(createDeviceRouter(db));
    router.use(createUserRouter(db));
    router.use(createNotificationRouter(db));
    router.use(createDepartmentRouter(db));
    router.use(createEquipmentRouter(db));
    router.use(createAlertRouter(db));
    router.use(createSeedRouter(db));
    return router;
}

module.exports = createApiRouter;
