const { Router } = require('express');
const createMaintenanceAlertRepository = require('../repositories/maintenance-alert.repository');
const createNotificationRepository = require('../repositories/notification.repository');
const createAlertController = require('../controllers/alert.controller');
const { requireRole } = require('../middleware/auth');
const { ROLES } = require('../config/roles');

function createAlertRouter(db) {
    const router = Router();
    const controller = createAlertController({
        db,
        alertRepository: createMaintenanceAlertRepository(db),
        notificationRepository: createNotificationRepository(db)
    });
    router.get('/v1/maintenance-alerts', requireRole(ROLES.MANAGER), controller.list);
    router.post('/v1/maintenance-alerts/scan', requireRole(ROLES.MANAGER, ROLES.ADMIN), controller.scan);
    return router;
}

module.exports = createAlertRouter;
