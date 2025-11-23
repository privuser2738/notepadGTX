#!/bin/bash

# Build script for notepadGTX binaries and installer package

set -e  # Exit on error

echo "======================================"
echo "  notepadGTX Build & Package Script"
echo "======================================"
echo ""

# Clean previous builds
echo "[1/5] Cleaning previous builds..."
rm -rf dist
mkdir -p dist

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "[2/5] Installing dependencies..."
    npm install
else
    echo "[2/5] Dependencies already installed"
fi

# Build GUI binary (includes CLI support via --cli flag)
echo "[3/5] Building notepadGTX binary..."
npm run build:gui

# Create unified installer package
echo "[4/5] Creating installer package..."

# Create package directory
PKG_DIR="dist/notepadGTX-installer"
mkdir -p "$PKG_DIR"

# Copy binaries
echo "  - Copying binaries..."
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

# Install binary (AppImage)
echo "[1/2] Installing notepadGTX binary..."
APPIMAGE=$(ls *.AppImage 2>/dev/null | head -n1)
if [ -n "$APPIMAGE" ]; then
    cp "$APPIMAGE" "$INSTALL_DIR/notepadGTX"
    chmod +x "$INSTALL_DIR/notepadGTX"
    echo "  ✓ Binary installed to $INSTALL_DIR/notepadGTX"
else
    echo "  ✗ Binary (AppImage) not found"
    exit 1
fi

# Create desktop entry
echo "[2/2] Creating desktop entry..."
cat > "$DESKTOP_DIR/notepadgtx.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=notepadGTX
Comment=Advanced notepad with CLI and GUI modes
Exec=notepadGTX %F
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
echo "  notepadGTX            - Launch GUI (default)"
echo "  notepadGTX --cli      - Launch in CLI mode"
echo "  notepadGTX -c         - Launch in CLI mode (short)"
echo "  notepadGTX -f FILE    - Open file"
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
- notepadGTX-*.AppImage   : Unified binary (GUI + CLI)
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
1. Copy notepadGTX-*.AppImage to /usr/local/bin/notepadGTX
2. Make it executable: chmod +x /usr/local/bin/notepadGTX

Package Installation (Debian/Ubuntu):
--------------------------------------
sudo dpkg -i notepadgtx_*.deb

Package Installation (RedHat/Fedora):
--------------------------------------
sudo rpm -i notepadgtx-*.rpm

Usage:
------
notepadGTX            # GUI mode (default)
notepadGTX --cli      # CLI mode
notepadGTX -c         # CLI mode (short)
notepadGTX -f file    # Open file

Keyboard Shortcuts (CLI mode):
------------------------------
Ctrl+U - Save
Ctrl+N - Save As
Ctrl+V - Open
Ctrl+K - Exit

For more information, see README.md and SHORTCUTS.md
EOF

# Create tarball
echo "[5/5] Creating tarball..."
cd dist
tar -czf notepadGTX-installer.tar.gz notepadGTX-installer/
cd ..

echo ""
echo "======================================"
echo "  Build Complete!"
echo "======================================"
echo ""
echo "Output files:"
echo "  - dist/*.AppImage (notepadGTX binary)"
echo "  - dist/*.deb (Debian package)"
echo "  - dist/*.rpm (RPM package)"
echo "  - dist/notepadGTX-installer/ (Complete installer package)"
echo "  - dist/notepadGTX-installer.tar.gz (Compressed installer)"
echo ""
echo "Usage after install:"
echo "  notepadGTX            # GUI mode (default)"
echo "  notepadGTX --cli      # CLI mode"
echo ""
echo "To distribute:"
echo "  tar -xzf notepadGTX-installer.tar.gz"
echo "  cd notepadGTX-installer"
echo "  sudo ./install.sh"
echo ""
