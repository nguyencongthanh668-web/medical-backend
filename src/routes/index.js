const { Router } = require('express');
const createAuthRouter = require('./auth.routes');
const createDeviceRouter = require('./device.routes');
const createUserRouter = require('./user.routes');
const createNotificationRouter = require('./notification.routes');
const createDepartmentRouter = require('./department.routes');
const createEquipmentRouter = require('./equipment.routes');
const createSeedRouter = require('./seed.routes');

function createApiRouter(db) {
    const router = Router();
    router.use(createAuthRouter());
    router.use(createDeviceRouter(db));
    router.use(createUserRouter(db));
    router.use(createNotificationRouter(db));
    router.use(createDepartmentRouter(db));
    router.use(createEquipmentRouter(db));
    router.use(createSeedRouter(db));
    return router;
}

module.exports = createApiRouter;
