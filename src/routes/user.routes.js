const { Router } = require('express');
const createUserRepository = require('../repositories/user.repository');
const createUserController = require('../controllers/user.controller');
const { requireRole } = require('../middleware/auth');
const { ROLES } = require('../config/roles');

function createUserRouter(db) {
    const router = Router();
    const controller = createUserController(createUserRepository(db));
    router.get('/v1/users', controller.list);
    router.get('/v1/users/:id', controller.detail);
    router.post('/v1/users', requireRole(ROLES.ADMIN), controller.create);
    router.patch('/v1/users/:id', requireRole(ROLES.ADMIN), controller.update);
    return router;
}

module.exports = createUserRouter;
