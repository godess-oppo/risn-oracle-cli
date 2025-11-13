// RISN Command: plugin
// List and register plugins
const logger = require('../lib/logger');
const pluginRegistry = require('../lib/plugin-registry');

module.exports = function(argv) {
  const subCmd = argv._[1] || 'list';
  logger.log('plugin', { action: subCmd });
  
  if (subCmd === 'list') {
    const plugins = pluginRegistry.listPlugins();
    console.log('[plugin] Registered plugins:', plugins);
  } else if (subCmd === 'register') {
    pluginRegistry.registerAll();
    console.log('[plugin] Plugins re-scanned and registered.');
  }
};
