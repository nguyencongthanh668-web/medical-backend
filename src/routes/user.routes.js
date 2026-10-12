const { Router } = require('express');
const createUserRepository = require('../repositories/user.repository');
const createUserController = require('../controllers/user.controller');

function createUserRouter(db) {
    const router = Router();
    const controller = createUserController(createUserRepository(db));
    router.get('/v1/users', controller.list);
    router.get('/v1/users/:id', controller.detail);
    return router;
}

module.exports = createUserRouter;
