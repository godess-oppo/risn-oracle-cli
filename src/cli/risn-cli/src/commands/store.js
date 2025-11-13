// RISN Command: store
// Manage store configuration and Medusa backend connection
const chalk = require('chalk');
const logger = require('../lib/logger');
const medusa = require('../lib/medusa-connector');

module.exports = async function(argv) {
  const subCmd = argv._[1] || 'status';
  logger.log('store', { action: subCmd, dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan(`\n🏪 Store: ${subCmd}\n`));
  
  if (subCmd === 'status') {
    try {
      const status = await medusa.getStatus();
      console.log(chalk.green('  ✓ Medusa backend: ') + chalk.bold(status.connected ? 'CONNECTED' : 'DISCONNECTED'));
      console.log(chalk.gray(`    Endpoint: ${status.url}`));
    } catch (err) {
      console.log(chalk.red('  ✗ Medusa backend: DISCONNECTED'));
      console.log(chalk.yellow('    Configure MEDUSA_URL in .env'));
    }
  } else if (subCmd === 'setup') {
    console.log(chalk.yellow('  Setting up store backend...'));
    console.log(chalk.gray('  TODO: Run Medusa migrations and seed data'));
  }
  
  console.log('');
};
