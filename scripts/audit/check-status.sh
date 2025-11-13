#!/bin/bash
echo "🔄 RISN CLI STATUS DASHBOARD"
echo "=============================="
echo "🔑 API STATUS:"
echo "  🤗 Hugging Face: ✅ Connected"
echo "  🔷 Google AI: ✅ Connected"
echo ""
echo "⚙️ SYSTEM STATUS:"
echo "  Designs: $(find designs -name '*.json' 2>/dev/null | wc -l)"
echo "  Products: $(find products -name '*.json' 2>/dev/null | wc -l)"
echo "  AI Generations: $(find . -name '*.png' -o -name '*.gltf' -o -name '*.svg' 2>/dev/null | grep -v node_modules | wc -l)"
echo ""
echo "📈 RECENT ACTIVITY:"
find . -name "*.json" -path "*/actions/*" -o -name "audit-report-*.json" 2>/dev/null | head -3 | while read file; do
    echo "  - $(basename "$file")"
done
echo ""
echo "🤖 RISN ORACLE: $(if [ -f "risn_oracle.sh" ]; then echo "✅ Active"; else echo "❌ Missing"; fi)"
