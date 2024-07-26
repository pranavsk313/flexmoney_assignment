#!/bin/bash

# Backend setup
# Move app.jar to backend directory
mkdir -p /var/www/backend/
cp /root/spring-java17-gradle/app/build/libs/app-1.0-SNAPSHOT.jar /var/www/backend/app.jar

# Create systemd service for backend application
cat << EOF > /etc/systemd/system/backend.service
[Unit]
Description=Backend Service
After=network.target

[Service]
User=root
ExecStart=/usr/bin/java -jar /var/www/backend/app.jar
SuccessExitStatus=143
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Frontend setup
# Move index.html to frontend directory
mkdir -p /var/www/html/
cp /root/index.html /var/www/html/

# Configure nginx
cat << EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Restart nginx to apply changes
systemctl restart nginx

# Enable and start backend service
systemctl enable backend
systemctl start backend

