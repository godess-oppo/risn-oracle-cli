#!/bin/bash
echo "🧪 RISN PROJECT COMPLETENESS CHECK"

echo "1. Core Files:"
files=("src/core/unified-cli.js" "src/core/ai-bridge.js" ".env" "package.json" "risn-eco.js")
for file in "${files[@]}"; do
  if [ -f "$file" ] && [ -s "$file" ]; then
    echo "   ✅ $file"
  else
    echo "   ❌ $file"
  fi
done

echo "2. Empty Files Check:"
empty_count=$(find . -maxdepth 4 -type f -empty | grep -v "venv/" | wc -l)
if [ $empty_count -eq 0 ]; then
  echo "   ✅ No empty files found"
else
  echo "   ❌ Found $empty_count empty files:"
  find . -maxdepth 4 -type f -empty | grep -v "venv/"
fi

echo "3. CLI Functionality:"
if command -v risn-eco &> /dev/null; then
  echo "   ✅ risn-eco: INSTALLED"
else
  echo "   ❌ risn-eco: NOT INSTALLED"
fi

echo "🎯 CHECK COMPLETE"
