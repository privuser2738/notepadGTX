#!/usr/bin/env node

const { program } = require('commander');
const path = require('path');

program
  .name('notepadGTX')
  .description('Advanced notepad with CLI and GUI modes')
  .option('-c, --cli', 'Launch in CLI mode')
  .option('-g, --gui', 'Launch in GUI mode')
  .option('-f, --file <path>', 'Open file on launch')
  .parse(process.argv);

const options = program.opts();

// Determine mode
let mode = 'gui'; // default
if (options.cli) {
  mode = 'cli';
} else if (options.gui) {
  mode = 'gui';
} else if (!process.env.DISPLAY && process.stdout.isTTY) {
  // If no display and running in terminal, default to CLI
  mode = 'cli';
}

if (mode === 'cli') {
  const CliNotepad = require('./cli-notepad');
  const notepad = new CliNotepad(options.file);
  notepad.start();
} else {
  // Launch Electron GUI
  try {
    const { app } = require('electron');
    const GuiNotepad = require('./gui-notepad');

    app.whenReady().then(() => {
      const notepad = new GuiNotepad(options.file);
      notepad.start();
    });

    app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') {
        app.quit();
      }
    });
  } catch (error) {
    if (error.code === 'MODULE_NOT_FOUND') {
      console.error('Error: Electron is not installed.');
      console.error('Please run: npm install');
      console.error('');
      console.error('Alternatively, you can use CLI mode:');
      console.error('  notepadGTX --cli');
      process.exit(1);
    } else {
      throw error;
    }
  }
}
