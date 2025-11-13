// RISN Command: agent
// Spawn and manage AI agents
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');

module.exports = function(argv) {
  const agentType = argv._[1] || 'generic';
  logger.log('agent', { action: 'spawn', type: agentType, dryRun: argv['dry-run'] });
  console.log(`[agent] Spawning agent: ${agentType}`);
  orchestrator.runChain([agentType], argv);
  console.log('[agent] Agent task completed (dry-run).');
};
