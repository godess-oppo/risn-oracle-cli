// RISN Command: plugin
// Plugin management: list, register, info
const chalk = require('chalk');
const logger = require('../lib/logger');
const pluginRegistry = require('../lib/plugin-registry');

module.exports = function(argv) {
  const subCmd = argv._[1] || 'list';
  logger.log('plugin', { action: subCmd });
  
  console.log(chalk.bold.cyan(`\n🔌 Plugins: ${subCmd}\n`));
  
  if (subCmd === 'list') {
    const plugins = pluginRegistry.listPlugins();
    if (plugins.length === 0) {
      console.log(chalk.gray('  No plugins installed\n'));
      console.log(chalk.cyan('  Create plugins in: plugins/<name>/manifest.json\n'));
    } else {
      console.log(chalk.green(`  Found ${plugins.length} plugin(s):\n`));
      plugins.forEach(p => {
        console.log(chalk.bold(`    ${p.name}`));
        console.log(chalk.gray(`      ${p.manifest.description || 'No description'}`));
        console.log(chalk.gray(`      Version: ${p.manifest.version || 'unknown'}\n`));
      });
    }
  } else if (subCmd === 'register') {
    const plugins = pluginRegistry.registerAll();
    console.log(chalk.green(`  ✓ Re-scanned and registered ${plugins.length} plugin(s)\n`));
  }
};
