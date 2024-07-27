


# Spring Boot and Nginx Deployment

This project demonstrates a simple deployment setup for a Spring Boot backend and a static HTML frontend using Nginx as a reverse proxy.

## Infrastructure Setup

In this setup, we have a simple yet efficient infrastructure that supports both frontend and backend services. The backend service, built with Java 17 and Spring Boot, runs on port 8080, while the frontend service is served by Nginx on port 80. The Nginx server is configured to proxy all requests starting with `/api/` to the backend service, while serving static files (like `index.html`) directly to the clients.

### Scalability

To scale this setup, we can utilize load balancers and auto-scaling groups. Nginx can act as a reverse proxy to distribute incoming requests to multiple instances of the backend service, which can be managed using an auto-scaling group. This ensures that the application can handle varying loads by dynamically adjusting the number of instances based on traffic.

### Maintainability

The use of systemd for managing the backend service ensures easy monitoring, starting, stopping, and restarting of the service. Furthermore, using scripts for deployment automates the setup process, reducing the risk of human error and ensuring consistency across different environments.

### Reliability

For reliability, we can set up health checks and monitoring for both Nginx and the backend service. Tools like Prometheus and Grafana can be integrated to monitor system metrics and application performance. Additionally, implementing proper logging mechanisms ensures that any issues can be quickly identified and resolved. Nginx configurations can be managed using Ansible or similar configuration management tools to ensure consistency and ease of updates across servers.

## Deployment

### Prerequisites

- Ubuntu server
- Java 17
- Nginx
- Spring Boot application

### Steps

1. **Install necessary packages:**

   ```bash
   apt-get update
   apt-get install -y openjdk-17-jdk nginx
   ```

2. **Build the backend application:**

   Navigate to the directory containing the `build.gradle` file and run:

   ```bash
   ./gradlew build
   ```

3. **Deploy the backend and frontend applications:**

   Create a `app.sh` script with the following content and run it:

   ```bash
   #!/bin/bash

   # Backend setup
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
   mkdir -p /var/www/html/
   cp /root/index.html /var/www/html/index.html

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
   ```

4. **Access the services:**

   - Frontend: http://43.204.100.254/
   - Backend: http://43.204.100.254/api/

This setup ensures a clear separation of concerns, where Nginx handles serving static content and reverse proxies API requests to the backend service. It also lays a foundation for scaling, maintainability, and reliability enhancements.
