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

// Determine mode - default to CLI for development
let mode = 'cli';
if (options.gui) {
  mode = 'gui';
} else if (options.cli) {
  mode = 'cli';
} else if (!process.env.DISPLAY || !process.stdout.isTTY) {
  // If no display or not in terminal, use CLI
  mode = 'cli';
}

if (mode === 'cli') {
  // Use simple CLI implementation for better compatibility
  const CliNotepad = require('./simple-cli');
  const notepad = new CliNotepad(options.file);
  notepad.start();
} else {
  // Launch Electron GUI
  let electron;
  try {
    electron = require('electron');
  } catch (error) {
    console.error('Error: Electron is not installed.');
    console.error('Please run: npm install');
    console.error('');
    console.error('Alternatively, you can use CLI mode:');
    console.error('  notepadGTX --cli');
    process.exit(1);
  }

  if (!electron || !electron.app) {
    console.error('Error: Electron failed to load properly.');
    console.error('Falling back to CLI mode...');
    console.error('');
    const CliNotepad = require('./simple-cli');
    const notepad = new CliNotepad(options.file);
    notepad.start();
  } else {
    const { app } = electron;
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
  }
}
