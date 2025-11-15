const readline = require('readline');
const fs = require('fs');
const path = require('path');

class SimpleCliNotepad {
  constructor(filePath) {
    this.currentFile = filePath || null;
    this.lines = [''];
    this.modified = false;
    this.cursorY = 0;
    this.cursorX = 0;
    this.offsetY = 0;
    this.running = true;
  }

  start() {
    // Load file if specified
    if (this.currentFile && fs.existsSync(this.currentFile)) {
      const content = fs.readFileSync(this.currentFile, 'utf8');
      this.lines = content.split('\n');
      if (this.lines.length === 0) this.lines = [''];
    }

    // Setup readline for raw mode
    readline.emitKeypressEvents(process.stdin);
    if (process.stdin.isTTY) {
      process.stdin.setRawMode(true);
    }

    // Handle keypresses
    process.stdin.on('keypress', (str, key) => {
      this.handleKey(str, key);
    });

    // Handle cleanup
    process.on('SIGINT', () => this.exit());
    process.on('SIGTERM', () => this.exit());

    // Initial render
    this.render();
  }

  handleKey(str, key) {
    if (!key) return;

    // Ctrl+K - Exit
    if (key.ctrl && key.name === 'k') {
      this.exit();
      return;
    }

    // Ctrl+U - Save
    if (key.ctrl && key.name === 'u') {
      this.save();
      return;
    }

    // Ctrl+N - Save As
    if (key.ctrl && key.name === 'n') {
      this.saveAs();
      return;
    }

    // Ctrl+V - Open
    if (key.ctrl && key.name === 'v') {
      this.open();
      return;
    }

    // Ctrl+C - Exit
    if (key.ctrl && key.name === 'c') {
      this.exit();
      return;
    }

    // Navigation
    if (key.name === 'up' && this.cursorY > 0) {
      this.cursorY--;
      this.cursorX = Math.min(this.cursorX, this.lines[this.cursorY].length);
    } else if (key.name === 'down' && this.cursorY < this.lines.length - 1) {
      this.cursorY++;
      this.cursorX = Math.min(this.cursorX, this.lines[this.cursorY].length);
    } else if (key.name === 'left' && this.cursorX > 0) {
      this.cursorX--;
    } else if (key.name === 'right' && this.cursorX < this.lines[this.cursorY].length) {
      this.cursorX++;
    } else if (key.name === 'home') {
      this.cursorX = 0;
    } else if (key.name === 'end') {
      this.cursorX = this.lines[this.cursorY].length;
    }

    // Editing
    else if (key.name === 'return' || key.name === 'enter') {
      const currentLine = this.lines[this.cursorY];
      const before = currentLine.substring(0, this.cursorX);
      const after = currentLine.substring(this.cursorX);
      this.lines[this.cursorY] = before;
      this.lines.splice(this.cursorY + 1, 0, after);
      this.cursorY++;
      this.cursorX = 0;
      this.modified = true;
    } else if (key.name === 'backspace') {
      if (this.cursorX > 0) {
        const line = this.lines[this.cursorY];
        this.lines[this.cursorY] = line.substring(0, this.cursorX - 1) + line.substring(this.cursorX);
        this.cursorX--;
        this.modified = true;
      } else if (this.cursorY > 0) {
        const currentLine = this.lines[this.cursorY];
        this.cursorY--;
        this.cursorX = this.lines[this.cursorY].length;
        this.lines[this.cursorY] += currentLine;
        this.lines.splice(this.cursorY + 1, 1);
        this.modified = true;
      }
    } else if (key.name === 'delete') {
      const line = this.lines[this.cursorY];
      if (this.cursorX < line.length) {
        this.lines[this.cursorY] = line.substring(0, this.cursorX) + line.substring(this.cursorX + 1);
        this.modified = true;
      } else if (this.cursorY < this.lines.length - 1) {
        this.lines[this.cursorY] += this.lines[this.cursorY + 1];
        this.lines.splice(this.cursorY + 1, 1);
        this.modified = true;
      }
    }

    // Regular character input
    else if (str && !key.ctrl && !key.meta) {
      const line = this.lines[this.cursorY];
      this.lines[this.cursorY] = line.substring(0, this.cursorX) + str + line.substring(this.cursorX);
      this.cursorX++;
      this.modified = true;
    }

    this.render();
  }

  render() {
    // Clear screen
    process.stdout.write('\x1b[2J\x1b[H');

    const height = process.stdout.rows || 24;
    const width = process.stdout.columns || 80;
    const contentHeight = height - 2; // Reserve 2 lines for status

    // Adjust offset for scrolling
    if (this.cursorY < this.offsetY) {
      this.offsetY = this.cursorY;
    }
    if (this.cursorY >= this.offsetY + contentHeight) {
      this.offsetY = this.cursorY - contentHeight + 1;
    }

    // Render lines
    for (let i = 0; i < contentHeight; i++) {
      const lineIdx = i + this.offsetY;
      if (lineIdx < this.lines.length) {
        const line = this.lines[lineIdx];
        const displayLine = line.length > width ? line.substring(0, width - 1) : line;
        process.stdout.write(displayLine);
      }
      process.stdout.write('\x1b[K\n'); // Clear to end of line
    }

    // Status bar
    const fileName = this.currentFile ? path.basename(this.currentFile) : '[Untitled]';
    const modMarker = this.modified ? ' *' : '';
    const status = `${fileName}${modMarker} | Line ${this.cursorY + 1}/${this.lines.length} Col ${this.cursorX + 1}`;
    process.stdout.write(`\x1b[7m${status}\x1b[K\x1b[0m\n`); // Inverted colors

    // Shortcuts bar
    const shortcuts = 'Ctrl+U:Save | Ctrl+N:Save As | Ctrl+V:Open | Ctrl+K:Exit';
    process.stdout.write(`\x1b[7m${shortcuts}\x1b[K\x1b[0m`);

    // Position cursor
    const displayY = this.cursorY - this.offsetY + 1;
    const displayX = this.cursorX + 1;
    process.stdout.write(`\x1b[${displayY};${displayX}H`);
  }

  save() {
    if (!this.currentFile) {
      this.saveAs();
      return;
    }

    try {
      const content = this.lines.join('\n');
      fs.writeFileSync(this.currentFile, content, 'utf8');
      this.modified = false;
      this.showMessage(`Saved: ${this.currentFile}`);
    } catch (err) {
      this.showMessage(`Error: ${err.message}`);
    }
  }

  saveAs() {
    this.prompt('Save as: ', (filePath) => {
      if (filePath) {
        this.currentFile = path.resolve(filePath);
        this.save();
      }
    });
  }

  open() {
    this.prompt('Open file: ', (filePath) => {
      if (filePath) {
        try {
          const fullPath = path.resolve(filePath);
          if (fs.existsSync(fullPath)) {
            const content = fs.readFileSync(fullPath, 'utf8');
            this.lines = content.split('\n');
            if (this.lines.length === 0) this.lines = [''];
            this.currentFile = fullPath;
            this.cursorY = 0;
            this.cursorX = 0;
            this.offsetY = 0;
            this.modified = false;
            this.showMessage(`Opened: ${fullPath}`);
          } else {
            this.showMessage(`File not found: ${fullPath}`);
          }
        } catch (err) {
          this.showMessage(`Error: ${err.message}`);
        }
      }
    });
  }

  prompt(message, callback) {
    process.stdout.write('\x1b[2J\x1b[H');
    process.stdout.write(message);

    let input = '';
    const handler = (str, key) => {
      if (key.name === 'return' || key.name === 'enter') {
        process.stdin.removeListener('keypress', handler);
        callback(input);
        this.render();
      } else if (key.name === 'escape') {
        process.stdin.removeListener('keypress', handler);
        callback(null);
        this.render();
      } else if (key.name === 'backspace') {
        input = input.slice(0, -1);
        process.stdout.write('\x1b[2J\x1b[H' + message + input);
      } else if (str && !key.ctrl && !key.meta) {
        input += str;
        process.stdout.write(str);
      }
    };

    process.stdin.on('keypress', handler);
  }

  showMessage(msg) {
    const savedCursorY = this.cursorY;
    const savedCursorX = this.cursorX;

    this.render();
    process.stdout.write(`\x1b[1;1H\x1b[7m ${msg} \x1b[0m`);

    setTimeout(() => {
      this.cursorY = savedCursorY;
      this.cursorX = savedCursorX;
      this.render();
    }, 2000);
  }

  exit() {
    if (this.modified) {
      this.prompt('Unsaved changes. Exit anyway? (y/n) ', (answer) => {
        if (answer && answer.toLowerCase() === 'y') {
          this.cleanup();
        }
      });
    } else {
      this.cleanup();
    }
  }

  cleanup() {
    if (process.stdin.isTTY) {
      process.stdin.setRawMode(false);
    }
    process.stdout.write('\x1b[2J\x1b[H'); // Clear screen
    process.stdout.write('\x1b[?25h');     // Show cursor
    process.exit(0);
  }
}

module.exports = SimpleCliNotepad;
