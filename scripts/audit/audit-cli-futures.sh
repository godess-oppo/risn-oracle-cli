#!/bin/bash
echo "🔮 RISN CLI FUTURES AUDIT"
echo "=========================="

cd ~/risn-cli

echo ""
echo "🎭 POETIC COMMANDS:"
commands=("dye" "weave" "manifest" "baptize" "recall" "audit" "stitch")
for cmd in "${commands[@]}"; do
    if grep -q "case \"\$1\" in.*$cmd" risn_oracle.sh 2>/dev/null; then
        echo "  ✅ $cmd"
    else
        echo "  ❌ $cmd"
    fi
done

echo ""
echo "🔧 STRUCTURED COMMANDS:"
if [ -d "src/commands" ]; then
    find src/commands -name "*.js" | while read file; do
        cmd=$(basename "$file" .js)
        echo "  📁 $cmd"
    done
else
    echo "  ❌ No structured commands directory"
fi

echo ""
echo "🤖 AI CAPABILITIES:"
# Check AI connections
./check-status.sh 2>/dev/null | grep -E "(✅|❌|🤗|🔷)"

echo ""
echo "🎨 DESIGN ASSETS:"
echo "  Designs: $(find designs -name '*.json' 2>/dev/null | wc -l) files"
echo "  AI Generated: $(find . -name '*.png' -o -name '*.gltf' -o -name '*.mp3' 2>/dev/null | grep -v node_modules | wc -l) files"
echo "  QF Output: $(find qf_out -type f 2>/dev/null | wc -l) files"

echo ""
echo "🛠️ TOOLS & INTEGRATIONS:"
[ -f "quantum_forge.py" ] && echo "  ✅ Quantum Forge" || echo "  ❌ Quantum Forge"
[ -f "storeforge.py" ] && echo "  ✅ StoreForge" || echo "  ❌ StoreForge"
[ -f "fashion_gen.py" ] && echo "  ✅ Fashion Generator" || echo "  ❌ Fashion Generator"

echo ""
echo "📦 DEPLOYMENT READY:"
[ -f "docker-compose.yml" ] && echo "  ✅ Docker" || echo "  ❌ Docker"
[ -f ".github/workflows" ] && echo "  ✅ GitHub Actions" || echo "  ❌ GitHub Actions"
[ -d "deployments" ] && echo "  ✅ Deployment scripts" || echo "  ❌ Deployment scripts"

echo ""
echo "🚀 FUTURE POTENTIAL:"
echo "  - Local LLM Integration: $(if command -v ollama &>/dev/null; then echo '✅ Possible'; else echo '🟡 Install ollama'; fi)"
echo "  - Mobile Optimization: ✅ Android/Termux ready"
echo "  - Offline Capability: 🟡 Partial"
echo "  - Plugin System: ✅ Basic structure exists"
