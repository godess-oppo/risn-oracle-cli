#!/usr/bin/env bash
set -euo pipefail

echo "Installing FashionForge CLI..."

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install package
pip install -e .

# Install dev dependencies if flag passed
if [[ "${1:-}" == "--dev" ]]; then
    pip install -e '.[dev]'
fi

# Install GPU dependencies if flag passed
if [[ "${1:-}" == "--gpu" ]]; then
    pip install -e '.[gpu]'
fi

echo "✅ Installation complete!"
echo "Run: source .venv/bin/activate && fashionforge --help"
