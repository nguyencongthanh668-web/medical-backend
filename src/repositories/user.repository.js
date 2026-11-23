const { query } = require('../utils/db');

// Không bao giờ trả mật khẩu (password của CSDL gốc, password_hash mới) hay token ra ngoài.
const SECRET_FIELDS = ['password', 'password_hash', 'remember_token', 'two_factor_secret', 'two_factor_recovery_codes'];
function stripSecrets(rows) {
    return (rows || []).map((row) => {
        const copy = { ...row };
        for (const f of SECRET_FIELDS) delete copy[f];
        return copy;
    });
}

function createUserRepository(db) {
    return {
        findById(id, callback) {
            db.query('SELECT * FROM users WHERE id = ?', [id], (err, rows) => callback(err, err ? rows : stripSecrets(rows)));
        },

        findAll(departmentId, callback) {
            const where = departmentId ? ' WHERE department_id = ?' : '';
            const params = departmentId ? [departmentId] : [];
            db.query(`SELECT * FROM users${where}`, params, (err, rows) => callback(err, err ? rows : stripSecrets(rows)));
        },

        async findByEmail(email) {
            const rows = await query(db, 'SELECT * FROM users WHERE email = ? LIMIT 1', [email]);
            return rows[0] || null;
        },

        async create({ name, email, passwordHash, role, departmentId }) {
            const result = await query(db,
                'INSERT INTO users (name, displayname, email, password_hash, role, department_id) VALUES (?, ?, ?, ?, ?, ?)',
                [name, name, email, passwordHash, role, departmentId]);
            return result.insertId;
        },

        async update(id, fields) {
            const allowed = { role: 'role', department_id: 'department_id', is_disabled: 'is_disabled', password_hash: 'password_hash', name: 'name' };
            const sets = [];
            const params = [];
            for (const [key, column] of Object.entries(allowed)) {
                if (fields[key] !== undefined) {
                    sets.push(`${column} = ?`);
                    params.push(fields[key]);
                }
            }
            if (sets.length === 0) return 0;
            const result = await query(db, `UPDATE users SET ${sets.join(', ')} WHERE id = ?`, [...params, id]);
            return result.affectedRows;
        }
    };
}

module.exports = createUserRepository;
