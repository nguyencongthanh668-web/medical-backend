const { Router } = require('express');
const createDepartmentRepository = require('../repositories/department.repository');
const createDepartmentController = require('../controllers/department.controller');

function createDepartmentRouter(db) {
    const router = Router();
    const controller = createDepartmentController(createDepartmentRepository(db));
    router.get('/v1/departments', controller.list);
    router.get(['/v1/departments/:id', '/v2/departments/:id'], controller.detail);
    return router;
}

module.exports = createDepartmentRouter;
