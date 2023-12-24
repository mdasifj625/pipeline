#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm if it's installed

NODE_VERSION="18" # Define the desired Node.js version

# Check if Node.js with specified version is installed
if ! command -v node &>/dev/null || ! node -v | grep -q "v$NODE_VERSION"; then
    # Install NVM if not installed
    if ! [ -s "$NVM_DIR/nvm.sh" ]; then
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        . "$NVM_DIR/nvm.sh"
    fi

    # Install the specified Node.js version
    nvm install "$NODE_VERSION"
    nvm use "$NODE_VERSION"
fi
