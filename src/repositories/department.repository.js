function createDepartmentRepository(db) {
    return {
        findAll(callback) {
            db.query('SELECT * FROM departments', callback);
        }
    };
}

module.exports = createDepartmentRepository;
