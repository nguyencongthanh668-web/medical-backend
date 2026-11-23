const mysql = require('mysql2');
const config = require('./env');

// Tạo pool khi khởi động server, không mở kết nối khi chỉ import module.
function createDatabasePool() {
    return mysql.createPool(config.database);
}

module.exports = { createDatabasePool };
