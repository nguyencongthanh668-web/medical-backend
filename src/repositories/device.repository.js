function createDeviceRepository(db) {
    return {
        findAll(callback) {
            db.query('SELECT * FROM devices', callback);
        }
    };
}

module.exports = createDeviceRepository;
