const express = require('express');
const cors = require('cors');
const createApiRouter = require('./routes');

function createApp({ db }) {
    const app = express();
    app.use(cors());
    app.use(express.json());

    app.get('/', (req, res) => {
        res.json({ message: 'Máy chủ đang hoạt động!' });
    });
    app.use('/api', createApiRouter(db));
    return app;
}

module.exports = { createApp };
