#!/bin/bash
echo "🔍 Searching for CLI executables..."
find . -type f -executable -name "*risn*" -o -name "*cli*" | grep -v node_modules
echo ""
echo "📦 Checking package.json scripts..."
cat package.json | grep -A 20 "scripts" 2>/dev/null || echo "No package.json found"
