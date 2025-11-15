#!/usr/bin/env node

// GUI-only entry point for Electron
const { app } = require('electron');
const { program } = require('commander');
const path = require('path');

program
  .name('notepadGTX-GUI')
  .description('Advanced notepad - GUI mode')
  .option('-f, --file <path>', 'Open file on launch')
  .parse(process.argv);

const options = program.opts();
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
