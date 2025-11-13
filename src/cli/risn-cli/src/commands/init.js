// RISN Command: init
// Initialize a new RISN store project with scaffolding
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('init', { action: 'initialize', dryRun: argv['dry-run'] });
  
  console.log(chalk.bold.cyan('\n🚀 Initializing RISN Store Project...\n'));
  
  const projectRoot = process.cwd();
  const dirs = ['products', 'assets', 'content', 'config'];
  
  dirs.forEach(dir => {
    const dirPath = path.join(projectRoot, dir);
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
      console.log(chalk.green(`  ✓ Created: ${dir}/`));
    } else {
      console.log(chalk.gray(`  - Exists: ${dir}/`));
    }
  });
  
  // Create default store config
  const configPath = path.join(projectRoot, 'config', 'store.json');
  if (!fs.existsSync(configPath)) {
    const defaultConfig = {
      store_name: "RISN Fashion Store",
      brand: "RISN",
      currency: "USD",
      timezone: "UTC",
      created_at: new Date().toISOString()
    };
    fs.writeFileSync(configPath, JSON.stringify(defaultConfig, null, 2));
    console.log(chalk.green(`  ✓ Created: config/store.json`));
  }
  
  console.log(chalk.bold.green('\n✅ RISN store initialized successfully!\n'));
  console.log('Next steps:');
  console.log('  1. Configure .env file with API keys');
  console.log('  2. Run: risn store setup');
  console.log('  3. Run: risn product create --name "Your Product"\n');
};
