const blessed = require('blessed');
const fs = require('fs');
const path = require('path');

class CliNotepad {
  constructor(filePath) {
    this.currentFile = filePath || null;
    this.modified = false;
    this.screen = null;
    this.textbox = null;
    this.statusBar = null;
  }

  start() {
    // Set terminal type to avoid loading external terminfo files in packaged binary
    if (!process.env.TERM || process.env.TERM === '') {
      process.env.TERM = 'xterm-256color';
    }

    // Force blessed to use built-in terminal database
    process.env.TERMINFO = '';

    // Create screen with error handling for packaged binary
    try {
      this.screen = blessed.screen({
        smartCSR: true,
        title: 'notepadGTX - CLI Mode',
        warnings: false,
        dump: false,
        ignoreLocked: ['C-c'],
        terminal: 'xterm-256color',
        fullUnicode: true
      });
    } catch (err) {
      console.error('Error initializing screen:', err.message);
      process.exit(1);
    }

    // Handle process signals gracefully
    const cleanup = () => this.cleanup();
    process.on('SIGINT', cleanup);
    process.on('SIGTERM', cleanup);
    process.on('exit', () => {
      try {
        if (this.screen && this.screen.program) {
          this.screen.program.showCursor();
          this.screen.program.normalBuffer();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    // Create text editor box
    this.textbox = blessed.textarea({
      parent: this.screen,
      top: 0,
      left: 0,
      width: '100%',
      height: '100%-1',
      keys: true,
      mouse: true,
      inputOnFocus: true,
      scrollable: true,
      alwaysScroll: true,
      scrollbar: {
        ch: ' ',
        bg: 'blue'
      },
      style: {
        fg: 'white',
        bg: 'black',
        focus: {
          fg: 'white',
          bg: 'black'
        }
      }
    });

    // Create status bar
    this.statusBar = blessed.box({
      parent: this.screen,
      bottom: 0,
      left: 0,
      width: '100%',
      height: 1,
      tags: true,
      style: {
        fg: 'black',
        bg: 'white'
      }
    });

    this.updateStatusBar();

    // Load file if specified
    if (this.currentFile) {
      this.openFile(this.currentFile);
    }

    // Set up keyboard shortcuts
    this.setupKeyBindings();

    // Focus on textbox
    this.textbox.focus();

    // Track modifications
    this.textbox.on('keypress', () => {
      if (!this.modified) {
        this.modified = true;
        this.updateStatusBar();
      }
    });

    // Render screen
    this.screen.render();
  }

  setupKeyBindings() {
    // Ctrl+U - Save
    this.screen.key(['C-u'], () => {
      this.save();
    });

    // Ctrl+N - Save As
    this.screen.key(['C-n'], () => {
      this.saveAs();
    });

    // Ctrl+K - Exit
    this.screen.key(['C-k'], () => {
      this.exit();
    });

    // Ctrl+V - Open
    this.screen.key(['C-v'], () => {
      this.open();
    });

    // Ctrl+C - Also allow exit (standard terminal behavior)
    this.screen.key(['C-c'], () => {
      this.cleanup();
    });
  }

  updateStatusBar() {
    const fileName = this.currentFile ? path.basename(this.currentFile) : '[Untitled]';
    const modifiedMarker = this.modified ? '*' : '';
    const shortcuts = 'Ctrl+U:Save | Ctrl+N:Save As | Ctrl+V:Open | Ctrl+K:Exit';
    this.statusBar.setContent(`{bold}${fileName}${modifiedMarker}{/bold} | ${shortcuts}`);
    this.screen.render();
  }

  save() {
    if (!this.currentFile) {
      this.saveAs();
      return;
    }

    try {
      const content = this.textbox.getValue();
      fs.writeFileSync(this.currentFile, content, 'utf8');
      this.modified = false;
      this.showMessage(`Saved: ${this.currentFile}`, 'green');
      this.updateStatusBar();
    } catch (err) {
      this.showMessage(`Error saving file: ${err.message}`, 'red');
    }
  }

  saveAs() {
    this.promptInput('Save as (path): ', (filePath) => {
      if (filePath) {
        this.currentFile = path.resolve(filePath);
        this.save();
      }
    });
  }

  open() {
    this.promptInput('Open file (path): ', (filePath) => {
      if (filePath) {
        this.openFile(path.resolve(filePath));
      }
    });
  }

  openFile(filePath) {
    try {
      if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath, 'utf8');
        this.textbox.setValue(content);
        this.currentFile = filePath;
        this.modified = false;
        this.showMessage(`Opened: ${filePath}`, 'green');
      } else {
        this.showMessage(`File not found: ${filePath}`, 'yellow');
        this.currentFile = filePath;
        this.textbox.setValue('');
        this.modified = false;
      }
      this.updateStatusBar();
      this.screen.render();
    } catch (err) {
      this.showMessage(`Error opening file: ${err.message}`, 'red');
    }
  }

  exit() {
    if (this.modified) {
      this.promptConfirm('Unsaved changes. Exit anyway? (y/n): ', (confirmed) => {
        if (confirmed) {
          this.cleanup();
        }
      });
    } else {
      this.cleanup();
    }
  }

  cleanup() {
    try {
      // Properly cleanup screen to avoid blessed cleanup errors
      if (this.screen) {
        if (this.screen.program) {
          this.screen.program.clear();
          this.screen.program.disableMouse();
          this.screen.program.showCursor();
          this.screen.program.normalBuffer();
        }
        // Remove all listeners before destroying
        this.screen.removeAllListeners();
        this.screen.destroy();
      }
    } catch (err) {
      // Ignore cleanup errors in packaged binary
    }

    // Reset terminal
    try {
      process.stdout.write('\x1b[?1049l'); // Exit alternate screen
      process.stdout.write('\x1b[?25h');   // Show cursor
    } catch (e) {
      // Ignore
    }

    process.exit(0);
  }

  promptInput(message, callback) {
    const prompt = blessed.prompt({
      parent: this.screen,
      top: 'center',
      left: 'center',
      width: '50%',
      height: 'shrink',
      border: 'line',
      label: ' Input ',
      tags: true,
      keys: true,
      vi: false
    });

    prompt.input(message, '', (err, value) => {
      callback(value);
    });

    this.screen.render();
  }

  promptConfirm(message, callback) {
    const confirm = blessed.question({
      parent: this.screen,
      top: 'center',
      left: 'center',
      width: '50%',
      height: 'shrink',
      border: 'line',
      label: ' Confirm ',
      tags: true,
      keys: true,
      vi: false
    });

    confirm.ask(message, (err, value) => {
      callback(value);
    });

    this.screen.render();
  }

  showMessage(message, color = 'white') {
    const msg = blessed.message({
      parent: this.screen,
      top: 'center',
      left: 'center',
      width: 'shrink',
      height: 'shrink',
      border: 'line',
      style: {
        fg: color,
        border: {
          fg: color
        }
      },
      tags: true
    });

    msg.display(message, 2, () => {
      this.screen.render();
    });

    this.screen.render();
  }
}

module.exports = CliNotepad;
