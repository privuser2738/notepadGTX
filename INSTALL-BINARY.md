# Installing notepadGTX from Binary

This guide is for end-users installing pre-built binaries.

## Quick Install (Recommended)

If you received `notepadGTX-installer.tar.gz`:

```bash
# Extract
tar -xzf notepadGTX-installer.tar.gz
cd notepadGTX-installer

# Install (with sudo for system-wide)
sudo ./install.sh

# Or install locally (without sudo)
./install.sh
```

That's it! You can now run:
```bash
notepadgtx
```

## Manual Installation

### Option 1: AppImage (GUI - Easiest)

1. Download `notepadGTX-*.AppImage`
2. Make it executable and run:
   ```bash
   chmod +x notepadGTX-*.AppImage
   ./notepadGTX-*.AppImage
   ```

No installation required! Just double-click or run it.

### Option 2: CLI Binary

1. Download `notepadGTX-cli`
2. Make it executable:
   ```bash
   chmod +x notepadGTX-cli
   ```
3. Move to your PATH:
   ```bash
   sudo mv notepadGTX-cli /usr/local/bin/
   # Or for local install:
   mkdir -p ~/.local/bin
   mv notepadGTX-cli ~/.local/bin/
   ```

### Option 3: Package Manager

**Debian/Ubuntu:**
```bash
sudo dpkg -i notepadgtx_*.deb
```

**Fedora/RedHat:**
```bash
sudo rpm -i notepadgtx-*.rpm
```

## Usage

```bash
# Launch (auto-detects CLI or GUI mode)
notepadgtx

# Force CLI mode
notepadgtx --cli

# Force GUI mode
notepadgtx --gui

# Open a file
notepadgtx myfile.txt
notepadgtx --cli -f myfile.txt
```

## Keyboard Shortcuts

- **Ctrl+U** - Save file
- **Ctrl+N** - Save As
- **Ctrl+V** - Open file
- **Ctrl+K** - Exit

## Uninstall

**If installed via installer script:**
```bash
sudo rm /usr/local/bin/notepadgtx*
sudo rm /usr/share/applications/notepadgtx.desktop
# Or for local install:
rm ~/.local/bin/notepadgtx*
rm ~/.local/share/applications/notepadgtx.desktop
```

**If installed via .deb:**
```bash
sudo apt remove notepadgtx
```

**If installed via .rpm:**
```bash
sudo rpm -e notepadgtx
```

**AppImage:**
Just delete the file - no uninstall needed.

## Troubleshooting

### "Command not found"

Add install directory to PATH:
```bash
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### GUI doesn't launch

Make sure you have a display:
```bash
echo $DISPLAY
```

If empty, use CLI mode:
```bash
notepadgtx --cli
```

### Permission denied

Make binary executable:
```bash
chmod +x notepadGTX-cli
# or
chmod +x notepadGTX-*.AppImage
```

### AppImage won't run

You may need FUSE:
```bash
# Debian/Ubuntu
sudo apt install fuse libfuse2

# Fedora
sudo dnf install fuse fuse-libs

# Or extract and run:
./notepadGTX-*.AppImage --appimage-extract
./squashfs-root/AppRun
```

## Requirements

- **CLI:** None (standalone binary)
- **GUI:** X11 or Wayland display server
- **System:** Linux x64 (64-bit)

## File Sizes

- CLI binary: ~46MB
- GUI AppImage: ~150-200MB
- .deb/.rpm packages: ~150-200MB

The binaries are large because they include all dependencies (Node.js/Electron runtime), but this means they work on any Linux distribution without needing to install anything else.

## Support

For help, see:
- `README.md` - Full documentation
- `SHORTCUTS.md` - Keyboard shortcuts
- `QUICKSTART.md` - Quick start guide

## License

MIT License - Free and open source
