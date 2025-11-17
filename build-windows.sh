#!/bin/bash

# Build script for notepadGTX Windows binaries

set -e  # Exit on error

echo "======================================"
echo "  notepadGTX Windows Build Script"
echo "======================================"
echo ""

# Clean previous Windows builds
echo "[1/5] Cleaning previous Windows builds..."
rm -rf dist/notepadGTX-windows
mkdir -p dist/notepadGTX-windows

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "[2/5] Installing dependencies..."
    npm install
else
    echo "[2/5] Dependencies already installed"
fi

# Build CLI binary for Windows
echo "[3/5] Building Windows CLI binary (.exe)..."
npx pkg src/cli-entry.js --targets node18-win-x64 --output dist/notepadGTX-windows/notepadGTX-cli.exe

# Build GUI binary for Windows (optional - requires wine on Linux)
echo "[4/5] Building Windows GUI binary..."
if command -v wine &> /dev/null; then
    echo "  - Wine detected, building Windows GUI..."
    npx electron-builder --windows --x64 --dir || echo "  - GUI build failed (this is optional)"

    # Copy GUI build to Windows folder if it exists
    if [ -d "dist/win-unpacked" ]; then
        echo "  - Copying GUI binary to Windows folder..."
        cp -r dist/win-unpacked/* dist/notepadGTX-windows/ 2>/dev/null || true
    fi
else
    echo "  - Skipping GUI build (requires wine for cross-platform Windows builds)"
    echo "  - To build GUI: Install wine and run this script again"
    echo "  - CLI build is sufficient for most use cases"
fi

# Copy documentation
echo "[5/5] Copying documentation..."
cp README.md dist/notepadGTX-windows/ 2>/dev/null || true
cp SHORTCUTS.md dist/notepadGTX-windows/ 2>/dev/null || true
cp QUICKSTART.md dist/notepadGTX-windows/ 2>/dev/null || true

# Create Windows README
cat > dist/notepadGTX-windows/README-WINDOWS.txt << 'EOF'
notepadGTX for Windows
======================

Contents:
---------
- notepadGTX-cli.exe  : CLI binary for Windows (standalone, no dependencies)
- notepadGTX.exe      : GUI binary for Windows (if built)

Installation:
-------------
1. Extract this folder to your desired location (e.g., C:\Program Files\notepadGTX\)
2. Add the folder to your system PATH to run from anywhere

Usage:
------
CLI Mode:
  notepadGTX-cli.exe                    # Open empty file
  notepadGTX-cli.exe -f myfile.txt      # Open specific file

GUI Mode (if available):
  notepadGTX.exe                        # Launch GUI
  notepadGTX.exe myfile.txt             # Open file in GUI

Keyboard Shortcuts (CLI):
-------------------------
Ctrl+U - Save
Ctrl+N - Save As
Ctrl+V - Open
Ctrl+K - Exit

For more information, see README.md and SHORTCUTS.md
EOF

# Create batch file launcher
cat > dist/notepadGTX-windows/notepadGTX.bat << 'EOF'
@echo off
REM notepadGTX Launcher for Windows

if "%1"=="--cli" (
    shift
    notepadGTX-cli.exe %*
) else if "%1"=="-c" (
    shift
    notepadGTX-cli.exe %*
) else (
    if exist notepadGTX.exe (
        notepadGTX.exe %*
    ) else (
        notepadGTX-cli.exe %*
    )
)
EOF

echo ""
echo "======================================"
echo "  Windows Build Complete!"
echo "======================================"
echo ""
echo "Output directory: dist/notepadGTX-windows/"
echo ""
echo "Contents:"
echo "  - notepadGTX-cli.exe (CLI binary)"
echo "  - notepadGTX.bat (Launcher script)"
echo "  - README-WINDOWS.txt (Installation instructions)"
echo ""
echo "To distribute:"
echo "  1. Zip the dist/notepadGTX-windows/ folder"
echo "  2. Share the zip file with Windows users"
echo ""
echo "To create a zip archive:"
echo "  cd dist && zip -r notepadGTX-windows.zip notepadGTX-windows/"
echo ""
