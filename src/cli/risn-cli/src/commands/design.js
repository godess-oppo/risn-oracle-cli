// RISN Command: design
// Generate design assets via AI agent chain
const chalk = require('chalk');
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');

module.exports = function(argv) {
  logger.log('design', { action: 'generate', dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan('\n🎨 AI Design Generation\n'));
  
  const agents = ['design', 'audit'];
  console.log(chalk.gray(`  Running agent chain: ${agents.join(' → ')}\n`));
  
  orchestrator.runChain(agents, argv);
  
  console.log(chalk.green('\n  ✓ Design assets generated'));
  console.log(chalk.gray('    Plan: risn/actions/design_*.json'));
  console.log(chalk.gray('    Audit: risn/audit.log\n'));
};
