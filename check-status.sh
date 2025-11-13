#!/bin/bash
echo "🔄 RISN CLI STATUS DASHBOARD"
echo "=============================="

# API Status
echo "🔑 API STATUS:"
if curl -s -H "Authorization: Bearer $HUGGINGFACE_TOKEN" "https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5" > /dev/null; then
  echo "  🤗 Hugging Face: ✅ Connected"
else
  echo "  🤗 Hugging Face: ❌ Failed"
fi

if curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=$GOOGLE_AI_KEY" > /dev/null; then
  echo "  🔷 Google AI: ✅ Connected" 
else
  echo "  🔷 Google AI: ❌ Failed"
fi

# System Status
echo ""
echo "⚙️ SYSTEM STATUS:"
echo "  Designs: $(find designs/ -name "*.png" 2>/dev/null | wc -l)"
echo "  Products: $(find data/products/ -name "*.json" 2>/dev/null | wc -l)"
echo "  AI Generations: $(find actions/ -name "ai-design-*.json" 2>/dev/null | wc -l)"

# Recent Activity
echo ""
echo "📈 RECENT ACTIVITY:"
find actions/ -name "*.json" -type f -exec stat -c "%Y %n" {} \; 2>/dev/null | sort -nr | head -3 | while read time file; do
  echo "  - $(date -d @$time '+%H:%M:%S') : $(basename $file)"
done

# Last AI Result
echo ""
echo "🤖 LAST AI ATTEMPT:"
latest_ai=$(find actions/ -name "ai-design-*.json" -type f -exec stat -c "%Y %n" {} \; 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
if [ -n "$latest_ai" ]; then
  cat "$latest_ai" | jq -r '.design_generation | "  Product: \(.product)\n  Provider: \(.ai_provider)\n  Status: \(.result.status)\n  Time: \(.timestamp)"'
else
  echo "  No AI attempts recorded"
fi
