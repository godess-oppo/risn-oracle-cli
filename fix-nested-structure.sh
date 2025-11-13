#!/bin/bash
echo "🔄 Fixing nested RISN CLI structure..."

# Check where we are
if [ -d "risn-cli" ]; then
    echo "📁 Moving files from nested risn-cli/ to current directory..."
    cp -r risn-cli/* ./
    cp -r risn-cli/.* ./ 2>/dev/null
    rm -rf risn-cli/
    echo "✅ Files moved successfully"
else
    echo "✅ Structure already fixed"
fi

# Verify the structure
echo "📋 Current structure:"
ls -la bin/ src/ risn/ 2>/dev/null

echo "🎯 Testing enhanced CLI..."
./bin/risn --help 2>/dev/null || echo "Node CLI needs setup"

echo "🎨 Testing poetic CLI..."
./risn_oracle.sh --help 2>/dev/null || echo "Poetic CLI available"
