#!/bin/bash

# Installation script for notepadGTX

echo "Installing notepadGTX..."

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Make the binary executable
chmod +x bin/notepadGTX.js

# Create symlink for global access (optional)
read -p "Do you want to install notepadGTX globally? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    npm link
    echo "notepadGTX has been installed globally. You can now run 'notepadGTX' from anywhere."
else
    echo "Local installation complete. Run './bin/notepadGTX.js' to start."
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  notepadGTX          - Launch in GUI mode (default)"
echo "  notepadGTX --cli    - Launch in CLI mode"
echo "  notepadGTX -f file  - Open a specific file"
echo ""
echo "CLI Keyboard Shortcuts:"
echo "  Ctrl+U  - Save"
echo "  Ctrl+N  - Save As"
echo "  Ctrl+V  - Open"
echo "  Ctrl+K  - Exit"
echo ""
