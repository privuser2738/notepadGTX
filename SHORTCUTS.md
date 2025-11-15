# notepadGTX Keyboard Shortcuts

## Both CLI and GUI Modes

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+U` | Save | Save the current file |
| `Ctrl+N` | Save As | Save with a new filename |
| `Ctrl+V` | Open | Open an existing file |
| `Ctrl+K` | Exit | Close the application |

## CLI Mode Only

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Exit | Alternative exit (standard terminal) |

## GUI Mode Additional Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+N` | New File | Create a new file |
| `Ctrl+C` | Copy | Copy selected text |
| `Ctrl+X` | Cut | Cut selected text |
| `Ctrl+V` | Paste | Paste (note: conflicts with Open in menu) |
| `Ctrl+Z` | Undo | Undo last change |
| `Ctrl+Y` | Redo | Redo last undo |
| `Ctrl+A` | Select All | Select all text |

## Launch Commands

```bash
# GUI mode (default)
notepadGTX
notepadGTX -g
notepadGTX --gui

# CLI mode
notepadGTX -c
notepadGTX --cli

# Open specific file
notepadGTX -f myfile.txt
notepadGTX --cli -f myfile.txt

# Get help
notepadGTX --help
```

## Tips

- In CLI mode, unsaved changes are protected - you'll get a confirmation prompt
- In GUI mode, the status bar shows real-time line, word, and character counts
- Both modes support basic text editing operations
- Files are saved with UTF-8 encoding
