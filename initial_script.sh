#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm if it's installed

NODE_VERSION="18"   # Define the desired Node.js version
APP_NAME="pipeline" # application name to start pm2

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

npm install -g pm2

if pm2 list | grep -q $APP_NAME; then
    echo "App is running, restarting..."
    pm2 restart $APP_NAME
else
    echo "App is not running, starting..."
    pm2 start index.js --name $APP_NAME
fi
