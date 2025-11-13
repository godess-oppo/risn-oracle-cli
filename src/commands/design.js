// RISN Command: design
// Generate design assets via AI agent
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');

module.exports = function(argv) {
  logger.log('design', { action: 'generate', dryRun: argv['dry-run'] });
  console.log('[design] Generating design via AI agent...');
  orchestrator.runChain(['design'], argv);
  console.log('[design] Reversible plan written to risn/actions/design_*.json');
};
