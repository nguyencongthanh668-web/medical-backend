const { Router } = require('express');
const createDeviceRepository = require('../repositories/device.repository');
const createDeviceController = require('../controllers/device.controller');

function createDeviceRouter(db) {
    const router = Router();
    const controller = createDeviceController(createDeviceRepository(db));
    router.get('/devices', controller.list);
    return router;
}

module.exports = createDeviceRouter;
