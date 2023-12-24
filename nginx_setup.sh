#!/bin/bash

APP_NAME="pipeline" # application name to setup nginx
APP_HOST="test.technicalwaves.com"
APP_PORT="3300"

# Check if Nginx is installed
if ! command -v nginx &>/dev/null; then
    echo "Nginx is not installed. Installing Nginx..."
    # Install Nginx (assuming apt package manager)
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update
    sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    sudo apt install -y nginx
fi

# Delete old and create a new Nginx configuration file for the application
CONFIG_FILE="/etc/nginx/sites-available/$APP_NAME.conf"

# Delete old Nginx configuration file for the application if it exists
if [ -f "$CONFIG_FILE" ]; then
    sudo rm "$CONFIG_FILE"
    echo "Old configuration file removed."
fi

sudo touch $CONFIG_FILE
if sudo systemctl reload nginx; then
    echo "Nginx configuration reloaded successfully."
else
    echo "Failed to reload Nginx. Check the configuration."
    exit 1
fi

# Configure Nginx to forward port 80 to port $APP_PORT
# echo "server {
#     listen 80;
#     server_name $APP_HOST;

#     location / {
#         proxy_pass http://127.0.0.1:$APP_PORT;
#         proxy_http_version 1.1;
#         proxy_set_header Upgrade \$http_upgrade;
#         proxy_set_header Connection 'upgrade';
#         proxy_set_header Host \$host;
#         proxy_cache_bypass \$http_upgrade;
#     }
# }" | sudo tee $CONFIG_FILE

# in case of https config

# make sure ssl folder is available
sudo mkdir -p /etc/nginx/ssl

# Read the content of cert.pem and save it to $APP_HOST.pem
sudo cat cert.pem | sudo tee /etc/nginx/ssl/$APP_HOST.pem >/dev/null

# Read the content of cert.key and save it to $APP_HOST.key
sudo cat cert.key | sudo tee /etc/nginx/ssl/$APP_HOST.key >/dev/null

# set the appropriate permission to the certificate
sudo chmod 600 /etc/nginx/ssl/$APP_HOST.pem
sudo chmod 600 /etc/nginx/ssl/$APP_HOST.key

# Finding the Nginx user and group
NGINX_USER=$(ps aux | grep 'nginx: worker process' | grep -v grep | awk '{print $1}' | head -n 1)
NGINX_GROUP=$(id -gn $NGINX_USER)

# Check if we found a user
if [ -z "$NGINX_USER" ] || ! id "$NGINX_USER" &>/dev/null; then
    echo "Nginx user not found or invalid. Exiting."
    exit 1
fi

# Change ownership of SSL certificate and key
sudo chown $NGINX_USER:$NGINX_GROUP /etc/nginx/ssl/$APP_HOST.pem
sudo chown $NGINX_USER:$NGINX_GROUP /etc/nginx/ssl/$APP_HOST.key

echo "Ownership of SSL files changed to $NGINX_USER:$NGINX_GROUP"

echo "server {
    listen 80;
    server_name $APP_HOST;

    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $APP_HOST;

    ssl_certificate /etc/nginx/ssl/$APP_HOST.pem; # .pem or .cert
    ssl_certificate_key /etc/nginx/ssl/$APP_HOST.key;

    # Forward HTTPS traffic to port $APP_PORT
    location / {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}" | sudo tee $CONFIG_FILE

# Enable the configuration by creating a symlink if it doesn't exist
if [ ! -f "/etc/nginx/sites-enabled/$APP_NAME.conf" ]; then
    sudo ln -s "$CONFIG_FILE" "/etc/nginx/sites-enabled/"
    echo "Symlink created for $APP_NAME configuration."
else
    echo "Symlink already exists for $APP_NAME configuration."
fi

# Check if there's a need to remove the default symlink
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
if sudo systemctl restart nginx; then
    echo "Nginx service restarted successfully."
else
    echo "Failed to restart Nginx. Check the configuration."
    exit 1
fi
echo "Nginx is configured to forward port 80 to port $APP_PORT for $APP_NAME."
