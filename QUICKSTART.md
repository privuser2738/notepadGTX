# Quick Start Guide - notepadGTX

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x install.sh
   chmod +x bin/notepadGTX.js
   ```

3. **Optional - Install globally:**
   ```bash
   sudo npm link
   ```

## Usage

### CLI Mode
```bash
# Run CLI mode
./bin/notepadGTX.js --cli

# Or if installed globally
notepadGTX --cli

# Open a file in CLI mode
notepadGTX --cli -f myfile.txt
```

**CLI Keyboard Shortcuts:**
- `Ctrl+U` - Save
- `Ctrl+N` - Save As
- `Ctrl+V` - Open
- `Ctrl+K` - Exit

### GUI Mode
```bash
# Run GUI mode (default)
./bin/notepadGTX.js

# Or if installed globally
notepadGTX

# Open a file in GUI mode
notepadGTX -f myfile.txt
```

**GUI Keyboard Shortcuts:**
- `Ctrl+U` - Save
- `Ctrl+N` - Save As
- `Ctrl+V` - Open
- `Ctrl+K` - Exit

## Testing

Create a test file:
```bash
echo "Hello notepadGTX!" > test.txt
```

Open it:
```bash
# CLI mode
notepadGTX --cli -f test.txt

# GUI mode
notepadGTX -f test.txt
```

## Troubleshooting

### CLI mode not working
- Make sure `blessed` is installed: `npm install blessed`
- Check that your terminal supports the required features

### GUI mode not working
- Make sure Electron is installed: `npm install electron`
- Check that you have a display server running (X11 or Wayland)

### Command not found
- Make sure the binary is executable: `chmod +x bin/notepadGTX.js`
- If installed globally, run: `sudo npm link`

## Development Mode

Run from source:
```bash
# GUI mode
npm start

# CLI mode
npm run start:cli
```
