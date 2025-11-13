#!/usr/bin/env node
// RISN CLI Router
// Global flags: --dry-run (default true), --policy-accept (toggle live mode)

const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');

const commands = [
  'init', 'store', 'design', 'product', 'marketing',
  'deploy', 'analytics', 'ops', 'aicm', 'agent',
  'plugin', 'audit', 'test'
];

const argv = yargs(hideBin(process.argv))
  .option('dry-run', {
    type: 'boolean',
    default: true,
    description: 'Run in dry-run mode (default: true)'
  })
  .option('policy-accept', {
    type: 'boolean',
    default: false,
    description: 'Accept policy and run live actions'
  })
  .command('$0', 'RISN CLI - Reshine Store Builder')
  .help()
  .argv;

// Route to command modules
const cmd = argv._[0];
if (commands.includes(cmd)) {
  const handler = require(`./commands/${cmd}.js`);
  handler(argv);
} else if (!cmd || cmd === 'risn') {
  console.log('RISN CLI v1.0.0 - Use --help for usage');
} else {
  console.error(`Unknown command: ${cmd}`);
  process.exit(1);
}
