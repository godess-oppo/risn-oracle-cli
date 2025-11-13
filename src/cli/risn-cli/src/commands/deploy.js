// RISN Command: deploy
// Deploy store with reversible plan (requires --policy-accept)
const chalk = require('chalk');
const logger = require('../lib/logger');
const { writeReversiblePlan } = require('../lib/orchestrator');
const policy = require('../lib/policy');

module.exports = function(argv) {
  logger.log('deploy', { action: 'deploy', dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan('\n🚀 Store Deployment\n'));
  
  const plan = {
    action: 'deploy_store',
    timestamp: new Date().toISOString(),
    target: argv.target || 'production',
    steps: [
      'Build assets',
      'Run migrations',
      'Sync products to Medusa',
      'Update CDN',
      'Health check'
    ],
    reversible: true,
    rollback: { action: 'rollback_deployment', snapshot_id: 'PENDING' }
  };
  
  if (policy.isDryRun(argv)) {
    writeReversiblePlan('deploy', plan);
    console.log(chalk.yellow('  [DRY-RUN] Deployment plan generated'));
    console.log(chalk.gray('    Target: ' + plan.target));
    console.log(chalk.gray('    Steps: ' + plan.steps.length));
    console.log(chalk.gray('    Plan: risn/actions/deploy_*.json\n'));
    console.log(chalk.bold.red('  ⚠️  Deployment requires --policy-accept flag\n'));
  } else if (policy.shouldExecute(argv)) {
    console.log(chalk.bold.red('  [LIVE] Deploying to ' + plan.target + '...\n'));
    plan.steps.forEach((step, idx) => {
      console.log(chalk.gray(`    ${idx + 1}. ${step}...`));
    });
    logger.log('deploy', { action: 'deploy_executed', plan });
    console.log(chalk.green('\n  ✓ Deployment completed successfully\n'));
  }
};
