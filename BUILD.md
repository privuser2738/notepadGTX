# Building notepadGTX

This guide explains how to build notepadGTX binaries and create an installer package.

## Prerequisites

- Node.js v14 or higher
- npm
- For building GUI: X11 development libraries

## Quick Build

```bash
# Install dependencies
npm install

# Build everything (CLI + GUI + installer package)
npm run build:package
```

This will create:
- `dist/notepadGTX-cli` - Standalone CLI binary
- `dist/notepadGTX-*.AppImage` - Standalone GUI binary
- `dist/*.deb` - Debian/Ubuntu package
- `dist/*.rpm` - RedHat/Fedora package
- `dist/notepadGTX-installer/` - Complete installer directory
- `dist/notepadGTX-installer.tar.gz` - Compressed installer package

## Individual Builds

### CLI Binary Only

```bash
npm run build:cli
```

Output: `dist/notepadGTX-cli`

### GUI Binaries Only

```bash
npm run build:gui
```

Output:
- `dist/notepadGTX-*.AppImage`
- `dist/*.deb`
- `dist/*.rpm`

### Both CLI and GUI

```bash
npm run build
```

## Build Configuration

### CLI (pkg)

Configuration in `package.json`:

```json
{
  "pkg": {
    "assets": ["src/**/*", "node_modules/blessed/**/*"],
    "scripts": ["src/**/*.js"],
    "targets": ["node18-linux-x64"]
  }
}
```

Entry point: `src/cli-entry.js`

### GUI (electron-builder)

Configuration in `package.json`:

```json
{
  "build": {
    "appId": "com.notepadgtx.app",
    "productName": "notepadGTX",
    "linux": {
      "target": ["AppImage", "deb", "rpm"],
      "category": "Utility"
    }
  }
}
```

Entry point: `src/gui-entry.js`

## Distribution

### Create Distributable Package

```bash
./build-package.sh
```

This creates `dist/notepadGTX-installer.tar.gz` containing:
- CLI binary (no dependencies required)
- GUI AppImage (no dependencies required)
- .deb package (for apt-based systems)
- .rpm package (for yum/dnf-based systems)
- install.sh script
- Documentation

### Share the Package

```bash
# Compress and share
scp dist/notepadGTX-installer.tar.gz user@server:~/

# Or upload to GitHub releases
# Or distribute via package managers
```

## Installation from Built Package

Users can install with:

```bash
# Extract
tar -xzf notepadGTX-installer.tar.gz
cd notepadGTX-installer

# Install globally (requires sudo)
sudo ./install.sh

# Or install locally (no sudo)
./install.sh
```

Alternatively, use package managers:

```bash
# Debian/Ubuntu
sudo dpkg -i notepadgtx_*.deb

# RedHat/Fedora
sudo rpm -i notepadgtx-*.rpm

# Or directly run the AppImage
chmod +x notepadGTX-*.AppImage
./notepadGTX-*.AppImage
```

## Troubleshooting

### Build Fails

```bash
# Clean and rebuild
rm -rf dist node_modules
npm install
npm run build:package
```

### Missing Dependencies

```bash
# Install build tools
npm install --save-dev pkg electron-builder
```

### pkg Errors

If pkg fails, ensure you're using Node 18:

```bash
node --version  # Should be v18.x or compatible
```

### Electron Build Errors

Install required system libraries:

```bash
# Debian/Ubuntu
sudo apt-get install build-essential libx11-dev libxkbfile-dev

# Fedora
sudo dnf install @development-tools libX11-devel libxkbfile-devel
```

## Advanced Configuration

### Customize Build Targets

Edit `package.json`:

```json
{
  "pkg": {
    "targets": [
      "node18-linux-x64",
      "node18-linux-arm64"
    ]
  }
}
```

### Add More Package Formats

Edit `package.json`:

```json
{
  "build": {
    "linux": {
      "target": [
        "AppImage",
        "deb",
        "rpm",
        "snap",
        "pacman"
      ]
    }
  }
}
```

## File Sizes

Approximate sizes:
- CLI binary: ~50-60MB (includes Node.js runtime)
- GUI AppImage: ~150-200MB (includes Electron)
- .deb package: ~150-200MB
- Complete installer: ~300-350MB compressed

The binaries are large because they include the entire runtime (Node.js/Electron), but this means **no dependencies are required** on the target system.
