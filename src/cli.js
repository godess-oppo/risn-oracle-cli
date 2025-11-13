#!/usr/bin/env node
/* RISN CLI v2 - Main Entry Point */
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const path = require('path');
const fs = require('fs');

// Load commands dynamically
const commands = {
  init: require('./commands/init.js'),
  store: require('./commands/store.js'),
  design: require('./commands/design.js'),
  product: require('./commands/product.js'),
  marketing: require('./commands/marketing.js'),
  deploy: require('./commands/deploy.js'),
  analytics: require('./commands/analytics.js'),
  ops: require('./commands/ops.js'),
  aicm: require('./commands/aicm.js'),
  agent: require('./commands/agent.js'),
  plugin: require('./commands/plugin.js'),
  audit: require('./commands/audit.js')
};

async function main() {
  const command = process.argv[2] || '--help';
  const args = process.argv.slice(3);

  if (!commands[command]) {
    console.log(`Usage: risn <command> [options]
Commands:
  init       Scaffold new RISN store
  store      Manage store configuration
  design     Generate design assets
  product    Manage products
  marketing  Generate marketing content
  deploy     Deploy changes
  analytics  View analytics
  ops        System operations
  aicm       AI commit message generator
  agent      Run autonomous agent
  plugin     Manage plugins
  audit      View audit logs`);
    process.exit(1);
  }

  const dryRun = !args.includes('--policy-accept') && 
    !(process.env.RISN_POLICY_ACCEPT === 'true');

  if (dryRun) {
    console.log('🌱 Dry-run mode (use --policy-accept to execute live)');
  }

  try {
    await commands[command]({ dryRun, args });
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

main();
