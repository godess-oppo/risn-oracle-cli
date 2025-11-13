// RISN Plugin Registry
// Auto-scan and register plugins from plugins/*/manifest.json
const fs = require('fs');
const path = require('path');

let pluginCache = null;

function listPlugins() {
  if (pluginCache) return pluginCache;
  
  const pluginsDir = path.join(process.cwd(), 'plugins');
  if (!fs.existsSync(pluginsDir)) {
    return [];
  }
  
  const dirs = fs.readdirSync(pluginsDir, { withFileTypes: true })
    .filter(d => d.isDirectory());
  
  const plugins = [];
  
  dirs.forEach(dir => {
    const manifestPath = path.join(pluginsDir, dir.name, 'manifest.json');
    if (fs.existsSync(manifestPath)) {
      try {
        const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
        plugins.push({
          name: dir.name,
          path: path.join(pluginsDir, dir.name),
          manifest
        });
      } catch (err) {
        console.error(`[plugin-registry] Failed to load ${dir.name}: ${err.message}`);
      }
    }
  });
  
  pluginCache = plugins;
  return plugins;
}

function registerAll() {
  pluginCache = null; // Clear cache
  const plugins = listPlugins();
  console.log(`[plugin-registry] Registered ${plugins.length} plugin(s)`);
  plugins.forEach(p => {
    console.log(`  - ${p.name} v${p.manifest.version || '1.0.0'}`);
  });
  return plugins;
}

function getPlugin(name) {
  const plugins = listPlugins();
  return plugins.find(p => p.name === name);
}

module.exports = { listPlugins, registerAll, getPlugin };
