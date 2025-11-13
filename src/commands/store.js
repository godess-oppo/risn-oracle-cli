// RISN Command: store
// Manage store configuration and setup
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('store', { action: 'configure', dryRun: argv['dry-run'] });
  console.log('[store] Configuring store backend...');
  // TODO: connect to Medusa, set policies
  console.log('[store] Done.');
};
