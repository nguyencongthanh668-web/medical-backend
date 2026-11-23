const { Router } = require('express');
const createNotificationRepository = require('../repositories/notification.repository');
const createNotificationController = require('../controllers/notification.controller');

function createNotificationRouter(db) {
    const router = Router();
    const controller = createNotificationController(createNotificationRepository(db));
    router.get('/v1/notification', controller.list);
    return router;
}

module.exports = createNotificationRouter;
