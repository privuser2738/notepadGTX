# Distributing notepadGTX

This document explains how to build and distribute notepadGTX binaries.

## Building Binaries

### Full Build (Recommended)

Build everything - CLI binary, GUI binaries (AppImage, .deb, .rpm), and create installer package:

```bash
./build-package.sh
```

Or:

```bash
npm run build:package
```

### Individual Components

**CLI Binary Only:**
```bash
npm run build:cli
```
Output: `dist/notepadGTX-cli` (46MB standalone binary)

**GUI Binaries Only:**
```bash
npm run build:gui
```
Output:
- `dist/notepadGTX-*.AppImage`
- `dist/notepadgtx_*.deb`
- `dist/notepadgtx-*.rpm`

## Distribution Package

After running `./build-package.sh`, you'll get:

```
dist/
├── notepadGTX-cli                    # Standalone CLI binary
├── notepadGTX-*.AppImage             # Standalone GUI binary
├── notepadgtx_*.deb                  # Debian/Ubuntu package
├── notepadgtx-*.rpm                  # RedHat/Fedora package
└── notepadGTX-installer/             # Installer directory
    ├── install.sh                    # Installation script
    ├── notepadGTX-cli                # CLI binary
    ├── notepadGTX-*.AppImage         # GUI binary
    ├── *.deb                         # Debian package
    ├── *.rpm                         # RPM package
    └── README.txt                    # Installation instructions
```

And compressed:
```
dist/notepadGTX-installer.tar.gz      # Everything in one tarball
```

## Distribution Methods

### Method 1: Binary Installer (Recommended)

Share `notepadGTX-installer.tar.gz`:

```bash
# User extracts and installs
tar -xzf notepadGTX-installer.tar.gz
cd notepadGTX-installer
sudo ./install.sh
```

The installer will:
- Copy binaries to `/usr/local/bin/` (or `~/.local/bin/` without sudo)
- Create unified launcher that auto-detects CLI/GUI mode
- Create desktop entry for GUI launcher
- Set up all necessary permissions

### Method 2: Package Managers

**Debian/Ubuntu:**
```bash
sudo dpkg -i notepadgtx_*.deb
```

**RedHat/Fedora/CentOS:**
```bash
sudo rpm -i notepadgtx-*.rpm
```

### Method 3: Standalone Binaries

Users can run binaries directly without installation:

**CLI:**
```bash
chmod +x notepadGTX-cli
./notepadGTX-cli
```

**GUI (AppImage):**
```bash
chmod +x notepadGTX-*.AppImage
./notepadGTX-*.AppImage
```

### Method 4: GitHub Releases

1. Build the package:
   ```bash
   ./build-package.sh
   ```

2. Create a GitHub release

3. Upload these files:
   - `notepadGTX-installer.tar.gz` (complete package)
   - `notepadGTX-cli` (standalone CLI)
   - `notepadGTX-*.AppImage` (standalone GUI)
   - `notepadgtx_*.deb` (Debian package)
   - `notepadgtx-*.rpm` (RPM package)

4. Users can download what they need

## Binary Information

### CLI Binary (`notepadGTX-cli`)

- **Size:** ~46MB
- **Dependencies:** None (standalone)
- **Runtime:** Node.js included
- **Compatible:** Linux x64
- **Features:** Full terminal-based text editor

### GUI Binary (AppImage)

- **Size:** ~150-200MB
- **Dependencies:** None (standalone)
- **Runtime:** Electron included
- **Compatible:** Most Linux distributions
- **Features:** Full GUI text editor

### .deb Package

- **For:** Debian, Ubuntu, Linux Mint, Pop!_OS, etc.
- **Install:** `sudo dpkg -i notepadgtx_*.deb`
- **Uninstall:** `sudo apt remove notepadgtx`

### .rpm Package

- **For:** RedHat, Fedora, CentOS, openSUSE, etc.
- **Install:** `sudo rpm -i notepadgtx-*.rpm`
- **Uninstall:** `sudo rpm -e notepadgtx`

## Usage After Installation

```bash
# Auto-detect mode (GUI if display available, otherwise CLI)
notepadgtx

# Force CLI mode
notepadgtx --cli
notepadgtx -c

# Force GUI mode
notepadgtx --gui
notepadgtx -g

# Open file
notepadgtx myfile.txt
notepadgtx --cli -f myfile.txt
```

## Keyboard Shortcuts

All modes use the same shortcuts:
- **Ctrl+U** - Save
- **Ctrl+N** - Save As
- **Ctrl+V** - Open
- **Ctrl+K** - Exit

## Support & Documentation

Include in distribution:
- `README.md` - Full documentation
- `SHORTCUTS.md` - Keyboard shortcuts reference
- `QUICKSTART.md` - Quick start guide
- `BUILD.md` - Build instructions

## Checksums

After building, generate checksums for verification:

```bash
cd dist
sha256sum notepadGTX-installer.tar.gz > SHA256SUMS
sha256sum notepadGTX-cli >> SHA256SUMS
sha256sum *.AppImage >> SHA256SUMS
sha256sum *.deb >> SHA256SUMS
sha256sum *.rpm >> SHA256SUMS
```

Users can verify:
```bash
sha256sum -c SHA256SUMS
```

## Continuous Integration Example

For automated builds (GitHub Actions):

```yaml
name: Build Binaries

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: ./build-package.sh
      - uses: actions/upload-artifact@v3
        with:
          name: binaries
          path: dist/
```

## License

Make sure to include LICENSE file with binaries.

## Updates

To update:
1. Increment version in `package.json`
2. Rebuild: `./build-package.sh`
3. Distribute new binaries
4. Users reinstall with new package
