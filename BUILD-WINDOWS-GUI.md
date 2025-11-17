# Building notepadGTX for Windows - GUI Release

This guide explains how to build the Windows GUI version of notepadGTX.

## Overview

The Windows GUI release creates:
- **NSIS Installer** - Traditional Windows installer with desktop shortcuts
- **Portable EXE** - Standalone executable that runs without installation
- **Unpacked Application** - Fully portable application folder

## Build Methods

### Method 1: Build on Linux (Requires Wine)

Wine is required to build Windows Electron applications on Linux.

#### Install Wine

**Arch/Manjaro:**
```bash
sudo pacman -S wine
```

**Ubuntu/Debian:**
```bash
sudo apt install wine wine64
```

**Fedora:**
```bash
sudo dnf install wine
```

#### Build the Release

```bash
npm run build:windows-release
# or
./build-windows-release.sh
```

### Method 2: Build on Windows (Native)

On a Windows machine, simply run:

```cmd
build-windows-release.bat
```

Or use npm directly:

```cmd
npm run build:gui:windows
```

### Method 3: Build GUI Only

To just build the Windows GUI without the release packaging:

```bash
npm run build:gui:windows
```

## Output Files

After building, you'll find in `dist/notepadGTX-windows-release/`:

```
notepadGTX-windows-release/
├── notepadGTX-1.2.2-x64.exe           # NSIS Installer
├── notepadGTX-1.2.2-portable.exe      # Portable executable
├── notepadGTX-unpacked/               # Unpacked application
│   └── notepadGTX.exe                 # Main executable
├── README-WINDOWS-RELEASE.txt         # Installation guide
├── README.md
├── SHORTCUTS.md
└── QUICKSTART.md
```

## Distribution

### Option 1: Share the Installer
Best for end users who want a traditional installation:
```bash
# Share: notepadGTX-1.2.2-x64.exe
```

### Option 2: Share the Portable Version
Best for users who don't want to install or need USB portability:
```bash
# Share: notepadGTX-1.2.2-portable.exe
```

### Option 3: Create a Complete Package
Package everything together:
```bash
cd dist
zip -r notepadGTX-windows-release.zip notepadGTX-windows-release/
```

## Installation (End Users)

### Using the Installer
1. Double-click `notepadGTX-1.2.2-x64.exe`
2. Follow the installation wizard
3. Choose installation directory
4. Select desktop shortcut option
5. Click Install
6. Launch from desktop or start menu

### Using the Portable Version
1. Copy `notepadGTX-1.2.2-portable.exe` anywhere
2. Double-click to run
3. No installation required
4. Can run from USB drive

### Using the Unpacked Version
1. Extract the `notepadGTX-unpacked` folder
2. Navigate into the folder
3. Run `notepadGTX.exe`
4. Fully portable, no registry changes

## Configuration

The Windows build is configured in `package.json` under the `"build"` section:

```json
{
  "win": {
    "target": ["nsis", "portable"]
  },
  "nsis": {
    "oneClick": false,
    "allowToChangeInstallationDirectory": true,
    "createDesktopShortcut": true,
    "createStartMenuShortcut": true
  }
}
```

## Troubleshooting

### Wine Issues on Linux

If you get wine errors:
1. Make sure wine is properly installed
2. Try updating wine to the latest version
3. Check electron-builder wine requirements: https://electron.build/multi-platform-build#linux

### Build Failures

If the build fails:
1. Delete `node_modules` and run `npm install` again
2. Clear electron-builder cache: `rm -rf ~/.cache/electron-builder`
3. Make sure you have enough disk space (>2GB recommended)

### Missing Dependencies

If you get dependency errors:
```bash
npm install
npm run build:gui:windows
```

## CLI Version

For the Windows CLI version (without GUI), use:
```bash
npm run build:windows
```

This creates a standalone CLI executable at `dist/notepadGTX-windows/notepadGTX-cli.exe`

## Notes

- First build downloads Electron for Windows (~100MB) and may take several minutes
- Subsequent builds are much faster
- The portable exe is a single file but unpacks on first run
- NSIS installer creates proper Windows uninstaller entries
- All versions run without Node.js or dependencies installed
