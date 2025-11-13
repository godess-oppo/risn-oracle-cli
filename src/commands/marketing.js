// RISN Command: marketing
// Generate marketing content via AI agent
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');

module.exports = function(argv) {
  logger.log('marketing', { action: 'generate', dryRun: argv['dry-run'] });
  console.log('[marketing] Generating marketing content...');
  orchestrator.runChain(['marketing', 'audit'], argv);
  console.log('[marketing] Content generated (subject to audit).');
};
