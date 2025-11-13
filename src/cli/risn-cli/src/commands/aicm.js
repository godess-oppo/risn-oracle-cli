// RISN Command: aicm
// AI Commit Messages - install git hook for conventional commits
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const logger = require('../lib/logger');

module.exports = function(argv) {
  logger.log('aicm', { action: 'install' });
  
  console.log(chalk.bold.cyan('\n🤖 AI Commit Messages\n'));
  
  const gitDir = path.join(process.cwd(), '.git');
  if (!fs.existsSync(gitDir)) {
    console.log(chalk.red('  ✗ Not a git repository\n'));
    process.exit(1);
  }
  
  const hookSrc = path.join(__dirname, '../../hooks/prepare-commit-msg.example');
  const hookDest = path.join(gitDir, 'hooks', 'prepare-commit-msg');
  
  if (fs.existsSync(hookSrc)) {
    fs.mkdirSync(path.dirname(hookDest), { recursive: true });
    fs.copyFileSync(hookSrc, hookDest);
    fs.chmodSync(hookDest, 0o755);
    console.log(chalk.green('  ✓ Git hook installed'));
    console.log(chalk.gray('    Location: .git/hooks/prepare-commit-msg\n'));
    console.log(chalk.cyan('  AI will now generate commit messages based on your changes\n'));
  } else {
    console.log(chalk.yellow('  Hook template not found, creating inline...\n'));
    const hookContent = `#!/usr/bin/env bash
# RISN AI Commit Message Hook
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

if [ -n "$COMMIT_SOURCE" ]; then exit 0; fi

DIFF=$(git diff --cached --name-only | head -5)
if [ -z "$DIFF" ]; then exit 0; fi

echo "# AI-generated commit (TODO: integrate LLM)" > "$COMMIT_MSG_FILE"
echo "# Files: $DIFF" >> "$COMMIT_MSG_FILE"
`;
    fs.mkdirSync(path.dirname(hookDest), { recursive: true });
    fs.writeFileSync(hookDest, hookContent);
    fs.chmodSync(hookDest, 0o755);
    console.log(chalk.green('  ✓ Basic hook installed\n'));
  }
};
