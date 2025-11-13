#!/usr/bin/env node
/* RISN CLI - Main Entry Point */
const fs = require('fs');
const path = require('path');
const logger = require('./lib/logger');

// Command registry
const COMMANDS = {
  init: require('./commands/init'),
  store: require('./commands/store'),
  design: require('./commands/design'),
  product: require('./commands/product'),
  marketing: require('./commands/marketing'),
  deploy: require('./commands/deploy'),
  analytics: require('./commands/analytics'),
  ops: require('./commands/ops'),
  aicm: require('./commands/aicm'),
  agent: require('./commands/agent'),
  plugin: require('./commands/plugin'),
  audit: require('./commands/audit')
};

// Ensure action directory exists
if (!fs.existsSync('risn/actions')) {
  fs.mkdirSync('risn/actions', { recursive: true });
}

// Parse command
const command = process.argv[2] || '--help';
const args = process.argv.slice(3);
const dryRun = !args.includes('--policy-accept') && 
  !(process.env.RISN_POLICY_ACCEPT === 'true');

if (!COMMANDS[command]) {
  logger.info();
  process.exit(1);
}

if (dryRun) {
  logger.info('🌱 Dry-run mode (add --policy-accept to execute changes)');
}

// Execute command
COMMANDS[command]({ dryRun, args })
  .catch(err => {
    logger.error();
    process.exit(1);
  });
