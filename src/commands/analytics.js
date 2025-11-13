// RISN Command: analytics
// View store analytics
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('analytics', { action: 'view' });
  console.log('[analytics] Fetching analytics...');
  // TODO: query analytics DB, display metrics
  console.log('[analytics] Done.');
};
