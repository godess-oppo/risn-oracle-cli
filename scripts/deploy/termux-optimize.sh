#!/bin/bash
echo "🔧 Applying Termux ARM64 optimizations..."

# Optimize for mobile performance
export RISN_MOBILE_MODE=true
export RISN_MEMORY_LIMIT="512MB"
export RISN_CACHE_SIZE="256MB"

# Configure for Termux storage
export RISN_DATA_DIR="/data/data/com.termux/files/home/risn-cli/data"

echo "✅ Termux optimizations applied"
