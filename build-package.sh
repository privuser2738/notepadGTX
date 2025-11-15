#!/bin/bash

# Build script for notepadGTX binaries and installer package

set -e  # Exit on error

echo "======================================"
echo "  notepadGTX Build & Package Script"
echo "======================================"
echo ""

# Clean previous builds
echo "[1/6] Cleaning previous builds..."
rm -rf dist
mkdir -p dist

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "[2/6] Installing dependencies..."
    npm install
else
    echo "[2/6] Dependencies already installed"
fi

# Build CLI binary
echo "[3/6] Building CLI binary..."
npm run build:cli

# Build GUI binaries (AppImage, deb, rpm)
echo "[4/6] Building GUI binaries..."
npm run build:gui

# Create unified installer package
echo "[5/6] Creating installer package..."

# Create package directory
PKG_DIR="dist/notepadGTX-installer"
mkdir -p "$PKG_DIR"

# Copy binaries
echo "  - Copying CLI binary..."
cp dist/notepadGTX-cli "$PKG_DIR/"

echo "  - Copying GUI binaries..."
cp dist/*.AppImage "$PKG_DIR/" 2>/dev/null || echo "    (No AppImage found)"
cp dist/*.deb "$PKG_DIR/" 2>/dev/null || echo "    (No .deb found)"
cp dist/*.rpm "$PKG_DIR/" 2>/dev/null || echo "    (No .rpm found)"

# Create installer script
cat > "$PKG_DIR/install.sh" << 'EOF'
#!/bin/bash

# notepadGTX Installer

echo "======================================"
echo "     notepadGTX Installer v1.0"
echo "======================================"
echo ""

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "This installer needs sudo privileges to install globally."
    echo "Please run with sudo or choose local installation."
    echo ""
fi

# Installation directory
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/icons/hicolor/256x256/apps"
else
    INSTALL_DIR="$HOME/.local/bin"
    DESKTOP_DIR="$HOME/.local/share/applications"
    ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
fi

echo "Installation directory: $INSTALL_DIR"
echo ""

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Install CLI binary
echo "[1/4] Installing CLI binary..."
if [ -f "notepadGTX-cli" ]; then
    cp notepadGTX-cli "$INSTALL_DIR/notepadgtx-cli"
    chmod +x "$INSTALL_DIR/notepadgtx-cli"
    echo "  ✓ CLI binary installed to $INSTALL_DIR/notepadgtx-cli"
else
    echo "  ✗ CLI binary not found"
    exit 1
fi

# Install GUI binary (AppImage)
echo "[2/4] Installing GUI binary..."
APPIMAGE=$(ls *.AppImage 2>/dev/null | head -n1)
if [ -n "$APPIMAGE" ]; then
    cp "$APPIMAGE" "$INSTALL_DIR/notepadgtx-gui"
    chmod +x "$INSTALL_DIR/notepadgtx-gui"
    echo "  ✓ GUI binary installed to $INSTALL_DIR/notepadgtx-gui"
else
    echo "  ✗ GUI binary (AppImage) not found"
fi

# Create unified launcher script
echo "[3/4] Creating launcher..."
cat > "$INSTALL_DIR/notepadgtx" << 'LAUNCHER'
#!/bin/bash

# notepadGTX Unified Launcher

if [[ "$1" == "--cli" ]] || [[ "$1" == "-c" ]]; then
    # Launch CLI mode
    shift
    exec notepadgtx-cli "$@"
elif [[ "$1" == "--gui" ]] || [[ "$1" == "-g" ]]; then
    # Launch GUI mode
    shift
    exec notepadgtx-gui "$@"
elif [ -z "$DISPLAY" ] || [ ! -t 0 ]; then
    # No display available, use CLI
    exec notepadgtx-cli "$@"
else
    # Default to GUI
    exec notepadgtx-gui "$@"
fi
LAUNCHER

chmod +x "$INSTALL_DIR/notepadgtx"
echo "  ✓ Launcher installed to $INSTALL_DIR/notepadgtx"

# Create desktop entry
echo "[4/4] Creating desktop entry..."
cat > "$DESKTOP_DIR/notepadgtx.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=notepadGTX
Comment=Advanced notepad with CLI and GUI modes
Exec=notepadgtx %F
Icon=notepadgtx
Terminal=false
Categories=Utility;TextEditor;
MimeType=text/plain;
DESKTOP

echo "  ✓ Desktop entry created"

echo ""
echo "======================================"
echo "  Installation Complete!"
echo "======================================"
echo ""
echo "Usage:"
echo "  notepadgtx           - Auto-detect mode (GUI if available)"
echo "  notepadgtx --cli     - Force CLI mode"
echo "  notepadgtx --gui     - Force GUI mode"
echo "  notepadgtx -f FILE   - Open file"
echo ""
echo "CLI Keyboard Shortcuts:"
echo "  Ctrl+U - Save"
echo "  Ctrl+N - Save As"
echo "  Ctrl+V - Open"
echo "  Ctrl+K - Exit"
echo ""

# Add to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Note: Add $INSTALL_DIR to your PATH if not already done:"
    echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
    echo ""
fi
EOF

chmod +x "$PKG_DIR/install.sh"

# Copy documentation
echo "  - Copying documentation..."
cp README.md "$PKG_DIR/" 2>/dev/null || true
cp SHORTCUTS.md "$PKG_DIR/" 2>/dev/null || true
cp QUICKSTART.md "$PKG_DIR/" 2>/dev/null || true

# Create README for package
cat > "$PKG_DIR/README.txt" << 'EOF'
notepadGTX Installation Package
================================

Contents:
---------
- notepadGTX-cli          : CLI binary (standalone, no dependencies)
- notepadGTX-*.AppImage   : GUI binary (standalone)
- *.deb                   : Debian/Ubuntu package (optional)
- *.rpm                   : RedHat/Fedora package (optional)
- install.sh              : Installation script

Quick Install:
--------------
sudo ./install.sh

Or for local installation (no sudo):
./install.sh

Manual Installation:
--------------------
1. Copy notepadGTX-cli to /usr/local/bin/ (or ~/.local/bin/)
2. Copy notepadGTX-*.AppImage to /usr/local/bin/ (or ~/.local/bin/)
3. Make them executable: chmod +x /usr/local/bin/notepadGTX-*

Package Installation (Debian/Ubuntu):
--------------------------------------
sudo dpkg -i notepadgtx_*.deb

Package Installation (RedHat/Fedora):
--------------------------------------
sudo rpm -i notepadgtx-*.rpm

Usage:
------
notepadgtx --cli     # CLI mode
notepadgtx --gui     # GUI mode
notepadgtx -f file   # Open file

Keyboard Shortcuts:
-------------------
Ctrl+U - Save
Ctrl+N - Save As
Ctrl+V - Open
Ctrl+K - Exit

For more information, see README.md and SHORTCUTS.md
EOF

# Create tarball
echo "[6/6] Creating tarball..."
cd dist
tar -czf notepadGTX-installer.tar.gz notepadGTX-installer/
cd ..

echo ""
echo "======================================"
echo "  Build Complete!"
echo "======================================"
echo ""
echo "Output files:"
echo "  - dist/notepadGTX-cli (CLI binary)"
echo "  - dist/*.AppImage (GUI binary)"
echo "  - dist/*.deb (Debian package)"
echo "  - dist/*.rpm (RPM package)"
echo "  - dist/notepadGTX-installer/ (Complete installer package)"
echo "  - dist/notepadGTX-installer.tar.gz (Compressed installer)"
echo ""
echo "To distribute:"
echo "  tar -xzf notepadGTX-installer.tar.gz"
echo "  cd notepadGTX-installer"
echo "  sudo ./install.sh"
echo ""
