// Electron GUI entry point (for packaged app)
const { app } = require('electron');
const GuiNotepad = require('./gui-notepad');

// Parse command line for file argument
let fileToOpen = null;
const args = process.argv.slice(1);
for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '-f' || arg === '--file') {
    fileToOpen = args[i + 1];
    break;
  } else if (!arg.startsWith('-') && !arg.includes('electron') && !arg.endsWith('.asar')) {
    // Assume it's a file path if it doesn't look like a flag or electron path
    fileToOpen = arg;
  }
}

app.whenReady().then(() => {
  const notepad = new GuiNotepad(fileToOpen);
  notepad.start();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
