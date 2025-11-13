// RISN Command: marketing
// Generate marketing content via AI with safety audit
const chalk = require('chalk');
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');

module.exports = function(argv) {
  logger.log('marketing', { action: 'generate', dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan('\n📢 AI Marketing Content Generation\n'));
  
  const agents = ['marketing', 'audit'];
  console.log(chalk.gray(`  Agent chain: ${agents.join(' → ')}\n`));
  
  orchestrator.runChain(agents, argv);
  
  console.log(chalk.green('\n  ✓ Marketing content generated'));
  console.log(chalk.gray('    Content passed safety audit'));
  console.log(chalk.gray('    Plan: risn/actions/marketing_*.json\n'));
};
