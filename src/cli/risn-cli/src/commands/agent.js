// RISN Command: agent
// Spawn and manage AI agents (design, marketing, devops, etc.)
const chalk = require('chalk');
const logger = require('../lib/logger');
const orchestrator = require('../lib/orchestrator');
const llm = require('../lib/llm');

module.exports = function(argv) {
  const agentType = argv._[1] || 'generic';
  const task = argv.task || 'default task';
  
  logger.log('agent', { action: 'spawn', type: agentType, task, dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan(`\n🤖 Spawning Agent: ${agentType}\n`));
  console.log(chalk.gray(`  Task: ${task}\n`));
  
  if (agentType === 'design') {
    orchestrator.runChain(['design'], argv);
  } else if (agentType === 'marketing') {
    orchestrator.runChain(['marketing', 'audit'], argv);
  } else {
    console.log(chalk.gray('  Querying LLM...\n'));
    const result = llm.query(`Execute ${agentType} agent task: ${task}`, { dryRun: argv['dry-run'] });
    console.log(chalk.green('  ✓ Agent response:'));
    console.log(chalk.gray('    ' + result.response.substring(0, 100) + '...\n'));
  }
  
  console.log(chalk.green(`  ✓ Agent '${agentType}' task completed\n`));
};
