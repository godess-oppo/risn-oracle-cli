// RISN Command: aicm
// Install AI Commit Message hook
const fs = require('fs');
const path = require('path');
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('aicm', { action: 'install' });
  console.log('[aicm] Installing AI commit message hook...');
  
  const hookSrc = path.join(__dirname, '../../hooks/prepare-commit-msg.example');
  const hookDest = path.join(process.cwd(), '.git/hooks/prepare-commit-msg');
  
  if (fs.existsSync('.git') && fs.existsSync(hookSrc)) {
    fs.copyFileSync(hookSrc, hookDest);
    fs.chmodSync(hookDest, 0o755);
    console.log('[aicm] Hook installed at .git/hooks/prepare-commit-msg');
  } else {
    console.log('[aicm] No .git directory or hook example not found.');
  }
};
