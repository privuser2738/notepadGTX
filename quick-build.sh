#!/bin/bash

# Quick build script - just builds CLI binary (fastest)

echo "Quick Build - CLI Binary Only"
echo "=============================="
echo ""

# Install dependencies if needed
if [ ! -d "node_modules" ] || [ ! -d "node_modules/pkg" ]; then
    echo "Installing dependencies..."
    npm install
    echo ""
fi

# Build CLI binary
echo "Building CLI binary..."
npm run build:cli

echo ""
echo "Build complete!"
echo ""
echo "Output: dist/notepadGTX-cli"
echo ""
echo "Test it:"
echo "  ./dist/notepadGTX-cli --help"
echo "  ./dist/notepadGTX-cli -f example.txt"
echo ""
echo "For full build (CLI + GUI + installer), run:"
echo "  ./build-package.sh"
echo ""
