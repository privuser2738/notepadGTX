#!/usr/bin/env node

// CLI-only entry point for pkg binary
const { program } = require('commander');
const path = require('path');

program
  .name('notepadGTX')
  .description('Advanced notepad - CLI mode')
  .option('-f, --file <path>', 'Open file on launch')
  .parse(process.argv);

const options = program.opts();

// Use simple CLI for better pkg compatibility
const CliNotepad = require('./simple-cli');
const notepad = new CliNotepad(options.file);
notepad.start();
