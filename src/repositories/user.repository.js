function createUserRepository(db) {
    return {
        findById(id, callback) {
            db.query('SELECT * FROM users WHERE id = ?', [id], callback);
        },

        findAll(departmentId, callback) {
            const where = departmentId ? ' WHERE department_id = ?' : '';
            const params = departmentId ? [departmentId] : [];
            db.query(`SELECT * FROM users${where}`, params, callback);
        }
    };
}

module.exports = createUserRepository;
