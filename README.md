# notepadGTX

Advanced notepad application for Linux with both CLI and GUI modes.

## Features

- **Dual Mode**: Launch in either CLI (terminal) or GUI (Electron) mode
- **Custom Keyboard Shortcuts**:
  - `Ctrl+U` - Save file
  - `Ctrl+N` - Save As
  - `Ctrl+V` - Open file
  - `Ctrl+K` - Exit application
- **Smart Mode Detection**: Automatically launches in CLI mode when no display is available
- **Modern UI**: Dark theme interface for both CLI and GUI modes
- **File Statistics**: Real-time line, word, and character count (GUI mode)

## Installation

### Prerequisites

- Node.js (v14 or higher)
- npm (comes with Node.js)

### Steps

1. Clone or download this repository
2. Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

3. Follow the prompts to install globally or locally

### Manual Installation

```bash
npm install
chmod +x bin/notepadGTX.js
npm link  # For global installation
```

## Usage

### Launch Modes

```bash
# GUI mode (default)
notepadGTX
notepadGTX --gui

# CLI mode
notepadGTX --cli

# Open a specific file
notepadGTX -f myfile.txt
notepadGTX --cli -f myfile.txt
```

### CLI Mode Keyboard Shortcuts

- **Ctrl+U** - Save the current file
- **Ctrl+N** - SaveAs (prompt for new filename)
- **Ctrl+V** - Open a file
- **Ctrl+K** - Exit the application
- **Ctrl+C** - Also exits (standard terminal behavior)

### GUI Mode Keyboard Shortcuts

- **Ctrl+U** - Save the current file
- **Ctrl+N** - Save As dialog
- **Ctrl+V** - Open file dialog
- **Ctrl+K** - Exit the application
- **Ctrl+Shift+N** - New file

Standard editing shortcuts (Ctrl+C, Ctrl+V, Ctrl+X, Ctrl+Z, etc.) also work in GUI mode.

## Running from Source

```bash
# GUI mode
npm start
# or
npm run start:gui

# CLI mode
npm run start:cli
```

## Architecture

- **main.js** - Entry point and mode selector
- **cli-notepad.js** - CLI implementation using blessed library
- **gui-notepad.js** - GUI implementation using Electron
- **gui.html** - HTML template for GUI mode

## Development

### Project Structure

```
notepadGTX/
├── bin/
│   └── notepadGTX.js       # Executable entry point
├── src/
│   ├── main.js             # Main application logic
│   ├── cli-notepad.js      # CLI mode implementation
│   ├── gui-notepad.js      # GUI mode implementation
│   └── gui.html            # GUI interface
├── package.json            # Project dependencies
├── install.sh              # Installation script
└── README.md              # This file
```

### Dependencies

- **blessed** - Terminal UI library for CLI mode
- **commander** - Command-line argument parsing
- **electron** - Framework for GUI mode

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
