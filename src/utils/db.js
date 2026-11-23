// Bọc API callback của mysql2 thành Promise cho các luồng nghiệp vụ mới.
function query(db, sql, params = []) {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, results) => (err ? reject(err) : resolve(results)));
    });
}

// Chạy fn(conn) trong một giao dịch: thành công thì COMMIT, có lỗi thì ROLLBACK (NFR-03).
function withTransaction(db, fn) {
    return new Promise((resolve, reject) => {
        db.getConnection((connError, conn) => {
            if (connError) return reject(connError);
            conn.beginTransaction(async (beginError) => {
                if (beginError) {
                    conn.release();
                    return reject(beginError);
                }
                try {
                    const result = await fn(conn);
                    conn.commit((commitError) => {
                        if (commitError) {
                            return conn.rollback(() => {
                                conn.release();
                                reject(commitError);
                            });
                        }
                        conn.release();
                        resolve(result);
                    });
                } catch (err) {
                    conn.rollback(() => {
                        conn.release();
                        reject(err);
                    });
                }
            });
        });
    });
}

module.exports = { query, withTransaction };
