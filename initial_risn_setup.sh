#!/bin/bash
echo "🎯 Initial RISN Git Setup & Upgrade"

# 1. Initial commit
echo "📝 Making initial commit..."
git add .
git commit -m "feat: initial RISN oracle CLI implementation

- Complete fashion automation system  
- AI-powered design generation
- Fluid identity consciousness engine
- Quantum forge integration
- StoreForge product pipeline
- Multi-modal CLI interface"

# 2. Push to origin
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main

# 3. Set up upstream
echo "🔄 Setting up upstream..."
git remote add upstream https://github.com/risn-cli/oracle-core.git

# 4. Fetch updates
echo "⬇️ Fetching latest updates..."
git fetch upstream

# 5. Create upgrade branch
echo "🌱 Creating upgrade branch..."
git checkout -b upgrade-from-upstream
git merge upstream/main || echo "No updates to merge or merge conflicts"

# 6. Run setup scripts
echo "⚙️ Running RISN setup..."
[ -f "./setup-risn.sh" ] && ./setup-risn.sh
[ -f "./install_risn.sh" ] && ./install_risn.sh

echo "✅ Initial setup complete!"
echo "🎨 Test with: python simple_fashion.py 'git_test' 'upgrade'"
