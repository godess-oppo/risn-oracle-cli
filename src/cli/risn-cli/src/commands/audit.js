// RISN Command: audit
// Content safety audit using ML classifier
const chalk = require('chalk');
const logger = require('../lib/logger');
const auditHook = require('../lib/audit-hook');
const policy = require('../lib/policy');

module.exports = function(argv) {
  const text = argv._[1] || 'Sample fashion product description with safe content.';
  logger.log('audit', { action: 'check', textLength: text.length, dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan('\n🛡️  Content Safety Audit\n'));
  console.log(chalk.gray('  Analyzing content...\n'));
  
  const result = auditHook.checkContent(text, argv);
  
  console.log(chalk.gray('  Content: ') + text.substring(0, 80) + '...');
  console.log(chalk.gray('  Model: ') + result.model + '\n');
  
  if (result.safe) {
    console.log(chalk.green('  ✓ SAFE: Content passed safety checks'));
    console.log(chalk.gray('    No harmful patterns detected\n'));
  } else {
    console.log(chalk.red('  ✗ UNSAFE: Harmful content detected'));
    console.log(chalk.yellow('    Patterns: ' + result.patterns.join(', ')));
    console.log(chalk.gray('    Risk score: ' + result.risk_score.toFixed(2) + '\n'));
    
    if (!policy.shouldExecute(argv)) {
      console.log(chalk.bold.red('  🚫 BLOCKED: Publishing prevented\n'));
      console.log(chalk.cyan('  Use --policy-accept to override (not recommended)\n'));
      process.exit(1);
    } else {
      console.log(chalk.bold.yellow('  ⚠️  OVERRIDE: Policy accepted, content allowed\n'));
      logger.log('audit', { action: 'override', text: text.substring(0, 100) });
    }
  }
};
