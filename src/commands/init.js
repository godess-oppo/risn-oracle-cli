// RISN Command: init
// Initialize a new RISN store project
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('init', { action: 'initialize', dryRun: argv['dry-run'] });
  console.log('[init] Initializing RISN store...');
  // TODO: scaffold store config, .env, directories
  console.log('[init] Done (dry-run mode).');
};
