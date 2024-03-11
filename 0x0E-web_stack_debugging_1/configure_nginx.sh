#!/bin/bash

# Update package list and install Nginx
sudo apt-get update
sudo apt-get install -y nginx

# Check if Nginx is already running
if ! sudo service nginx status > /dev/null 2>&1; then
    # If not running, start Nginx
    sudo service nginx start
fi

# Ensure Nginx is configured to listen on port 80 for all active IPv4 IPs
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
sudo sed -i '/listen 80 default_server;/c\    listen 80 default_server;' /etc/nginx/sites-available/default

# Configure a new Nginx site
sudo tee /etc/nginx/sites-available/web-01 > /dev/null <<EOL
server {
    listen 80;
    listen [::]:80;

    server_name localhost;

    location /hbnb_static {
        alias /data/web_static/current/;
    }

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOL

# Create a symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/web-01 /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx to apply changes
sudo service nginx restart
