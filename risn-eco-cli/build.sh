#!/bin/bash
echo "Building RISN Eco-CLI..."

# Build Rust components if they exist
if find src -name "*.rs" | grep -q .; then
    echo "Building Rust components..."
    if command -v cargo >/dev/null 2>&1; then
        cargo build --release
        cp target/release/risn dist/risn 2>/dev/null || true
    else
        echo "Cargo not found. Skipping Rust build."
    fi
fi

# Build TypeScript/JavaScript components
if find src -name "*.ts" | grep -q .; then
    echo "Building TypeScript components..."
    npx tsc --outDir dist --skipLibCheck 2>/dev/null || echo "TypeScript build skipped"
fi

# Copy any JS files directly
if find src -name "*.js" | grep -q .; then
    echo "Copying JavaScript files..."
    find src -name "*.js" -exec cp --parents {} dist/ \; 2>/dev/null || true
fi

echo "Build completed!"
