#!/bin/bash
echo "🔮 RISN Automated System Fix"

cd ~/risn-cli
source venv/bin/activate

echo "=== Phase 1: System Diagnosis ==="
./risn_oracle.sh audit "full system scan"

echo "=== Phase 2: Git Recovery ==="
./risn_oracle.sh stitch --pattern="repository_healing"

echo "=== Phase 3: Storefront Fix ==="
./risn_oracle.sh weave --pattern="build_restoration" --context="hydrogen vite"

echo "=== Phase 4: Dependency Repair ==="
./risn_oracle.sh baptize

echo "✅ RISN healing complete"
echo "🎯 Running verification checks..."

# Verify fixes
./check-status.sh
git status --short
