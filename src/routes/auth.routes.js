const { Router } = require('express');
const createUserRepository = require('../repositories/user.repository');
const createAuthController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth');

function createAuthRouter(db) {
    const router = Router();
    const controller = createAuthController(createUserRepository(db));
    router.post('/login', controller.login);
    router.post('/v1/logout', controller.logout);
    router.get('/v1/me', authenticate, controller.me);
    return router;
}

module.exports = createAuthRouter;
