// RISN Plugin Registry
// Scan plugins/*/manifest.json and auto-register
const fs = require('fs');
const path = require('path');

function listPlugins() {
  const pluginsDir = path.join(process.cwd(), 'plugins');
  if (!fs.existsSync(pluginsDir)) return [];
  
  const dirs = fs.readdirSync(pluginsDir, { withFileTypes: true })
    .filter(d => d.isDirectory());
  
  const plugins = [];
  dirs.forEach(dir => {
    const manifestPath = path.join(pluginsDir, dir.name, 'manifest.json');
    if (fs.existsSync(manifestPath)) {
      const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
      plugins.push({ name: dir.name, manifest });
    }
  });
  
  return plugins;
}

function registerAll() {
  const plugins = listPlugins();
  console.log(`[plugin-registry] Found ${plugins.length} plugins`);
  plugins.forEach(p => {
    console.log(`  - ${p.name}: ${p.manifest.description || 'No description'}`);
  });
  return plugins;
}

module.exports = { listPlugins, registerAll };
