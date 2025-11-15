const fs = require('fs');
const { execSync } = require('child_process');

console.log('Building RISN Eco-CLI...');

// Copy non-Rust files to dist
if (!fs.existsSync('dist')) {
  fs.mkdirSync('dist', { recursive: true });
}

// Just copy the main entry point for now
if (fs.existsSync('src/index.js')) {
  fs.copyFileSync('src/index.js', 'dist/index.js');
  console.log('Copied index.js to dist/');
}

console.log('Build completed (minimal)');
