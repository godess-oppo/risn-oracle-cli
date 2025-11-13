#!/bin/bash
echo "🔄 Simple RISN Upgrade - Enhancing Current System"

# Create Node.js structure alongside existing
mkdir -p src/commands src/lib
mkdir -p risn/actions  # For reversible plans

# Create main CLI bridge
cat > bin/risn-enhanced << 'BRIDGE_EOF'
#!/usr/bin/env node
// RISN Enhanced CLI Bridge
console.log("🎭 RISN Enhanced CLI");
console.log("Poetic AI Fashion System + Structured Commands\n");

const command = process.argv[2];
const poeticCommands = ['dye', 'weave', 'manifest', 'baptize', 'audit'];

if (poeticCommands.includes(command)) {
  console.log(`🎨 Using poetic command: ${command}`);
  const { execSync } = require('child_process');
  execSync(`./risn_oracle.sh ${process.argv.slice(2).join(' ')}`, { stdio: 'inherit' });
} else {
  console.log("🔧 Using structured commands");
  console.log("Available: init, product, design, deploy, audit");
  console.log("\nExamples:");
  console.log("  ./bin/risn-enhanced init");
  console.log("  ./bin/risn-enhanced product create --name 'Cyber Gown'");
}
BRIDGE_EOF

chmod +x bin/risn-enhanced

# Create package.json for dependencies
cat > package.json << 'PKG_EOF'
{
  "name": "risn-cli",
  "version": "2.0.0",
  "description": "RISN Enhanced CLI",
  "dependencies": {
    "yargs": "^17.7.2"
  }
}
PKG_EOF

echo "✅ Enhanced RISN CLI ready!"
echo "🎯 Use: ./bin/risn-enhanced --help"
echo "🎨 Your poetic commands still work: ./risn_oracle.sh weave --pattern=digital_baroque"
