#!/bin/bash

APP_NAME="pipeline"

npm install -g pm2

if pm2 list | grep -q $APP_NAME; then
    echo "App is running, restarting..."
    pm2 restart $APP_NAME
else
    echo "App is not running, starting..."
    pm2 start index.js --name $APP_NAME
fi
