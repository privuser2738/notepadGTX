const { BrowserWindow, Menu, dialog } = require('electron');
const fs = require('fs');
const path = require('path');

class GuiNotepad {
  constructor(filePath) {
    this.currentFile = filePath || null;
    this.modified = false;
    this.window = null;
  }

  start() {
    // Create browser window
    this.window = new BrowserWindow({
      width: 1000,
      height: 700,
      title: 'notepadGTX',
      webPreferences: {
        nodeIntegration: true,
        contextIsolation: false
      },
      icon: path.join(__dirname, '../assets/icon.png')
    });

    // Load HTML
    this.window.loadFile(path.join(__dirname, 'gui.html'));

    // Set up menu
    this.setupMenu();

    // Update title when modified
    this.window.webContents.on('did-finish-load', () => {
      if (this.currentFile) {
        this.openFile(this.currentFile);
      }
      this.updateTitle();

      // Set up IPC listeners for content changes
      this.setupIPCListeners();
    });

    // Prevent closing with unsaved changes
    this.window.on('close', (e) => {
      if (this.modified) {
        const choice = dialog.showMessageBoxSync(this.window, {
          type: 'question',
          buttons: ['Cancel', 'Discard Changes', 'Save'],
          title: 'Unsaved Changes',
          message: 'Do you want to save the changes?'
        });

        if (choice === 0) {
          e.preventDefault();
        } else if (choice === 2) {
          this.save();
          if (this.modified) {
            e.preventDefault();
          }
        }
      }
    });
  }

  setupMenu() {
    const template = [
      {
        label: 'File',
        submenu: [
          {
            label: 'New',
            accelerator: 'Ctrl+Shift+N',
            click: () => this.newFile()
          },
          {
            label: 'Open',
            accelerator: 'Ctrl+V',
            click: () => this.open()
          },
          {
            label: 'Save',
            accelerator: 'Ctrl+U',
            click: () => this.save()
          },
          {
            label: 'Save As',
            accelerator: 'Ctrl+N',
            click: () => this.saveAs()
          },
          { type: 'separator' },
          {
            label: 'Exit',
            accelerator: 'Ctrl+K',
            click: () => this.window.close()
          }
        ]
      },
      {
        label: 'Edit',
        submenu: [
          { role: 'undo' },
          { role: 'redo' },
          { type: 'separator' },
          { role: 'cut' },
          { role: 'copy' },
          { role: 'paste' },
          { role: 'selectAll' }
        ]
      },
      {
        label: 'View',
        submenu: [
          { role: 'reload' },
          { role: 'toggleDevTools' },
          { type: 'separator' },
          { role: 'resetZoom' },
          { role: 'zoomIn' },
          { role: 'zoomOut' }
        ]
      }
    ];

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
  }

  setupIPCListeners() {
    // Listen for content changes from renderer
    this.window.webContents.executeJavaScript(`
      const textarea = document.getElementById('editor');
      let contentChanged = false;

      textarea.addEventListener('input', () => {
        if (!contentChanged) {
          contentChanged = true;
          window.electronAPI.contentChanged();
        }
      });

      window.electronAPI = {
        contentChanged: () => {
          // Signal to main process
          const event = new CustomEvent('content-changed');
          document.dispatchEvent(event);
        }
      };

      document.addEventListener('content-changed', () => {
        document.title = document.title.includes('*') ? document.title : document.title + ' *';
      });
    `);

    // Poll for changes (simple approach)
    let lastContent = '';
    setInterval(() => {
      this.window.webContents.executeJavaScript(`
        document.getElementById('editor').value;
      `).then(content => {
        if (content !== lastContent && lastContent !== '') {
          if (!this.modified) {
            this.modified = true;
            this.updateTitle();
          }
        }
        lastContent = content;
      }).catch(() => {});
    }, 500);
  }

  updateTitle() {
    const fileName = this.currentFile ? path.basename(this.currentFile) : 'Untitled';
    const modifiedMarker = this.modified ? ' *' : '';
    this.window.setTitle(`notepadGTX - ${fileName}${modifiedMarker}`);
  }

  newFile() {
    if (this.modified) {
      const choice = dialog.showMessageBoxSync(this.window, {
        type: 'question',
        buttons: ['Cancel', 'Discard', 'Save'],
        title: 'Unsaved Changes',
        message: 'Do you want to save the changes?'
      });

      if (choice === 0) return;
      if (choice === 2) this.save();
    }

    this.currentFile = null;
    this.modified = false;
    this.window.webContents.executeJavaScript(`
      document.getElementById('editor').value = '';
    `);
    this.updateTitle();
  }

  open() {
    const files = dialog.showOpenDialogSync(this.window, {
      properties: ['openFile'],
      filters: [
        { name: 'Text Files', extensions: ['txt', 'md', 'js', 'json', 'html', 'css', 'py', 'java', 'c', 'cpp'] },
        { name: 'All Files', extensions: ['*'] }
      ]
    });

    if (files && files[0]) {
      this.openFile(files[0]);
    }
  }

  openFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      this.currentFile = filePath;
      this.modified = false;

      this.window.webContents.executeJavaScript(`
        document.getElementById('editor').value = ${JSON.stringify(content)};
      `);

      this.updateTitle();
    } catch (err) {
      dialog.showErrorBox('Error', `Failed to open file: ${err.message}`);
    }
  }

  save() {
    if (!this.currentFile) {
      this.saveAs();
      return;
    }

    this.window.webContents.executeJavaScript(`
      document.getElementById('editor').value;
    `).then(content => {
      try {
        fs.writeFileSync(this.currentFile, content, 'utf8');
        this.modified = false;
        this.updateTitle();
      } catch (err) {
        dialog.showErrorBox('Error', `Failed to save file: ${err.message}`);
      }
    });
  }

  saveAs() {
    const filePath = dialog.showSaveDialogSync(this.window, {
      filters: [
        { name: 'Text Files', extensions: ['txt'] },
        { name: 'All Files', extensions: ['*'] }
      ]
    });

    if (filePath) {
      this.currentFile = filePath;
      this.save();
    }
  }
}

module.exports = GuiNotepad;
