#!/usr/bin/env node

import { Command } from 'commander';
import { initProject } from './commands/init';
import { designProject } from './commands/design';
import { createProduct } from './commands/product';
import { aiFix } from './commands/ai-fix';
import { aiGenerate } from './commands/ai-generate';
import { syncStore } from './commands/store-sync';
import { autoMarketing } from './commands/marketing';
import { runAutomation } from './commands/automation';
import { loadConfig } from '../core/config';

const program = new Command();

program
  .name('risn')
  .description('RISN CLI - AI-Augmented Development Assistant')
  .version('1.0.0');

program
  .command('init')
  .description('Initialize a new RISN project')
  .argument('[name]', 'project name')
  .action(initProject);

program
  .command('design')
  .description('Start an AI-assisted design session')
  .argument('[requirements]', 'design requirements')
  .action(designProject);

program
  .command('product:create')
  .description('Create a new product/service')
  .argument('<name>', 'product name')
  .argument('[type]', 'product type (web-app, api-service, mobile-app)')
  .action(createProduct);

program
  .command('ai:fix')
  .description('Fix code issues with AI assistance')
  .argument('<target>', 'file or directory to fix')
  .argument('[error-log]', 'error log file')
  .action(aiFix);

program
  .command('ai:generate')
  .description('Generate code with AI assistance')
  .argument('<feature>', 'feature description')
  .argument('[target]', 'target directory')
  .action(aiGenerate);

program
  .command('store:sync')
  .description('Sync project with RISN Store')
  .action(syncStore);

program
  .command('marketing:auto')
  .description('Generate automated marketing campaigns')
  .argument('[type]', 'campaign type (social, email, content)')
  .argument('[audience]', 'target audience')
  .action(autoMarketing);

program
  .command('automation:run')
  .description('Run automation workflows')
  .argument('[workflow]', 'workflow name')
  .action(runAutomation);

async function main() {
  try {
    await loadConfig();
    await program.parseAsync(process.argv);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
