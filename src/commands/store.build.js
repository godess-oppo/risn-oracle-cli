const { buildStore } = require('../orchestrator');
exports.command = 'store.build';
exports.handler = async () => { await buildStore(); };
