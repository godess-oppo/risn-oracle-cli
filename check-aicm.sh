#!/bin/bash
echo "🔍 AICM Status Check"

echo "1. Git hooks directory:"
ls -la .git/hooks/ 2>/dev/null || echo "   Not a git repo"

echo ""
echo "2. AICM hook:"
if [ -f ".git/hooks/prepare-commit-msg" ]; then
    echo "   ✅ AICM hook installed"
    echo "   Permissions: $(ls -la .git/hooks/prepare-commit-msg | cut -d' ' -f1)"
else
    echo "   ❌ AICM hook missing"
fi

echo ""
echo "3. Test with:"
echo "   touch test-file && git add test-file && git commit"
