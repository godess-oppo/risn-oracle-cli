#!/usr/bin/env node
// RISN CLI Router - Store-Builder Engine v2
// Global flags: --dry-run (default true), --policy-accept (toggle live mode)

const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
const chalk = require('chalk');

const commands = [
  'init', 'store', 'design', 'product', 'marketing',
  'deploy', 'analytics', 'ops', 'aicm', 'agent',
  'plugin', 'audit'
];

const argv = yargs(hideBin(process.argv))
  .option('dry-run', {
    type: 'boolean',
    default: true,
    description: 'Run in dry-run mode (default: true, safe preview)'
  })
  .option('policy-accept', {
    type: 'boolean',
    default: false,
    description: 'Accept policy and execute live actions (use with caution)'
  })
  .option('verbose', {
    alias: 'v',
    type: 'boolean',
    default: false,
    description: 'Verbose output'
  })
  .command('$0', 'RISN Store-Builder Engine v2 - Fashion Brand Automation')
  .help()
  .alias('h', 'help')
  .version('2.0.0')
  .alias('V', 'version')
  .argv;

// Route to command modules
const cmd = argv._[0];
if (commands.includes(cmd)) {
  try {
    const handler = require(`./commands/${cmd}.js`);
    handler(argv);
  } catch (err) {
    console.error(chalk.red(`[ERROR] Failed to execute command '${cmd}': ${err.message}`));
    if (argv.verbose) console.error(err.stack);
    process.exit(1);
  }
} else if (!cmd || cmd === 'risn') {
  console.log(chalk.bold.cyan('\n🛍️  RISN Store-Builder Engine v2.0.0'));
  console.log(chalk.gray('   Production-ready fashion e-commerce automation\n'));
  console.log('Usage: risn <command> [options]\n');
  console.log('Commands:');
  console.log('  init          Initialize new RISN store project');
  console.log('  store         Configure store backend (Medusa)');
  console.log('  design        Generate design assets via AI');
  console.log('  product       Manage products (create, update, sync)');
  console.log('  marketing     Generate marketing content');
  console.log('  deploy        Deploy store (reversible, requires --policy-accept)');
  console.log('  analytics     View store analytics');
  console.log('  ops           Operations: heal, monitor, backup');
  console.log('  aicm          AI Commit Messages (install git hook)');
  console.log('  agent         Spawn and manage AI agents');
  console.log('  plugin        Plugin management (list, register)');
  console.log('  audit         Content safety audit\n');
  console.log('Flags:');
  console.log('  --dry-run         Preview actions without executing (default: true)');
  console.log('  --policy-accept   Execute live actions (use with caution)');
  console.log('  --verbose, -v     Verbose output\n');
  console.log('Examples:');
  console.log('  risn init');
  console.log('  risn product create --name "Leather Jacket" --dry-run');
  console.log('  risn deploy --policy-accept\n');
  console.log('Learn more: https://github.com/risn/store-builder\n');
} else {
  console.error(chalk.red(`[ERROR] Unknown command: ${cmd}`));
  console.log('Run ' + chalk.cyan('risn --help') + ' for usage');
  process.exit(1);
}
