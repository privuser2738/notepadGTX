#!/bin/bash

# Build script for notepadGTX Windows GUI Release

set -e  # Exit on error

echo "=============================================="
echo "  notepadGTX Windows GUI Release Builder"
echo "=============================================="
echo ""

# Check for wine (required for building Windows apps on Linux)
if ! command -v wine &> /dev/null; then
    echo "ERROR: Wine is required to build Windows GUI applications on Linux"
    echo ""
    echo "To install wine:"
    echo "  Ubuntu/Debian: sudo apt install wine wine64"
    echo "  Arch/Manjaro:  sudo pacman -S wine"
    echo "  Fedora:        sudo dnf install wine"
    echo ""
    echo "Alternatively, build on a Windows machine using:"
    echo "  npm run build:gui:windows"
    echo ""
    exit 1
fi

echo "✓ Wine detected - proceeding with Windows build"
echo ""

# Clean previous builds
echo "[1/4] Cleaning previous Windows GUI builds..."
rm -rf dist/win-unpacked dist/*.exe dist/*.nsis* 2>/dev/null || true
mkdir -p dist/notepadGTX-windows-release

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "[2/4] Installing dependencies..."
    npm install
else
    echo "[2/4] Dependencies already installed"
fi

# Build Windows GUI (creates installer and portable exe)
echo "[3/4] Building Windows GUI application..."
echo "  This may take several minutes on first build..."
echo ""

npm run build:gui:windows

# Organize the release files
echo "[4/4] Organizing release files..."

# Copy installer files
if [ -f dist/notepadGTX*.exe ]; then
    cp dist/notepadGTX*.exe dist/notepadGTX-windows-release/ 2>/dev/null || true
    echo "  ✓ Copied Windows installers/portable exe"
fi

# Copy latest directory if it exists (contains the unpacked app)
if [ -d "dist/win-unpacked" ]; then
    cp -r dist/win-unpacked dist/notepadGTX-windows-release/notepadGTX-unpacked 2>/dev/null || true
    echo "  ✓ Copied unpacked application"
fi

# Copy documentation
echo "  - Copying documentation..."
cp README.md dist/notepadGTX-windows-release/ 2>/dev/null || true
cp SHORTCUTS.md dist/notepadGTX-windows-release/ 2>/dev/null || true
cp QUICKSTART.md dist/notepadGTX-windows-release/ 2>/dev/null || true

# Create Windows release README
cat > dist/notepadGTX-windows-release/README-WINDOWS-RELEASE.txt << 'EOF'
notepadGTX for Windows - GUI Release
=====================================

This package contains the full GUI version of notepadGTX for Windows.

Installation Options:
---------------------

Option 1: Installer (Recommended)
  - Run: notepadGTX-1.2.2-x64.exe
  - Follow the installation wizard
  - Creates desktop shortcut and start menu entry
  - Automatically adds to Windows programs list

Option 2: Portable Version
  - Run: notepadGTX-1.2.2-portable.exe
  - No installation required
  - Can run from USB drive or any folder
  - No registry changes

Option 3: Unpacked Application
  - Navigate to: notepadGTX-unpacked/
  - Run: notepadGTX.exe
  - Fully portable, no installation

Usage:
------
- Double-click the application to launch the GUI
- File menu: Open, Save, Save As, Exit
- Edit menu: Cut, Copy, Paste, Undo, Redo
- View menu: Theme options, Font settings

Features:
---------
- Full GUI editor with modern interface
- Syntax highlighting support
- Multiple file support
- Auto-save functionality
- Search and replace
- Line numbers
- Word wrap

For command-line usage, see build-windows.sh for CLI version.

For more information, see README.md and SHORTCUTS.md
EOF

echo ""
echo "=============================================="
echo "  Windows GUI Build Complete!"
echo "=============================================="
echo ""
echo "Output directory: dist/notepadGTX-windows-release/"
echo ""
echo "Release files:"
ls -lh dist/notepadGTX-windows-release/*.exe 2>/dev/null || echo "  (No exe files found - check build output)"
echo ""
echo "Contents:"
echo "  - notepadGTX-*-x64.exe (NSIS Installer)"
echo "  - notepadGTX-*-portable.exe (Portable executable)"
echo "  - notepadGTX-unpacked/ (Unpacked application folder)"
echo "  - README-WINDOWS-RELEASE.txt (Installation guide)"
echo ""
echo "To distribute:"
echo "  1. Share the installer (.exe) for standard installation"
echo "  2. Share the portable exe for USB/portable use"
echo "  3. Or zip the entire folder for all options"
echo ""
echo "Create distribution archive:"
echo "  cd dist && zip -r notepadGTX-windows-release.zip notepadGTX-windows-release/"
echo ""
