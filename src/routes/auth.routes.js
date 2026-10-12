const { Router } = require('express');
const authController = require('../controllers/auth.controller');

function createAuthRouter() {
    const router = Router();
    router.post('/login', authController.login);
    router.post('/v1/logout', authController.logout);
    return router;
}

module.exports = createAuthRouter;
