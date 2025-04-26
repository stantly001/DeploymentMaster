# Angular Application Deployment Guide

This comprehensive guide covers various methods for deploying Angular applications in production environments, with a focus on Nginx-based deployments.

## Table of Contents

1. [Deployment Options](#deployment-options)
2. [Nginx Deployment](#nginx-deployment)
3. [Docker Deployment](#docker-deployment)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [Continuous Deployment](#continuous-deployment)
6. [Performance Optimizations](#performance-optimizations)
7. [Security Considerations](#security-considerations)
8. [Troubleshooting](#troubleshooting)

## Deployment Options

There are several approaches to deploying Angular applications:

1. **Static Web Server**: Deploy the built Angular app to a web server like Nginx or Apache.
2. **Docker Containers**: Package the app and web server together in a Docker container.
3. **Kubernetes**: Orchestrate containerized deployments for high availability.
4. **Cloud Platform Services**: Use platform-specific services like AWS S3/CloudFront, Azure Static Web Apps, or Google Cloud Storage.

This guide focuses primarily on the Nginx-based deployment approach, which offers an excellent balance of performance, flexibility, and control.

## Nginx Deployment

### Prerequisites

- Node.js and npm for building the Angular application
- Nginx web server installed on the target server
- SSH access to the target server

### Deployment Steps

1. **Build the Angular application**:
   ```bash
   ng build --configuration production
   ```
   This creates optimized static files in the `dist/` directory.

2. **Copy files to the server**:
   ```bash
   scp -r dist/angular-app-example/* user@server:/var/www/html/
   ```
   
   Alternatively, use the provided deployment script:
   ```bash
   ./deploy.sh -e prod -s your-server.com -u your-user -d /var/www/html
   ```

3. **Configure Nginx**:
   
   Basic configuration (`nginx.conf`):
   ```nginx
   server {
     listen 80;
     server_name example.com;
     root /var/www/html;
     index index.html;

     # Angular routing support
     location / {
       try_files $uri $uri/ /index.html;
     }
   }
   ```
   
   For production, use the enhanced `nginx-prod.conf` which includes:
   - HTTPS configuration
   - Security headers
   - Performance optimizations
   - Asset caching

4. **Test and apply the Nginx configuration**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## Docker Deployment

Docker provides a consistent deployment environment and simplifies the process.

### Prerequisites

- Docker installed on both development and target machines
- Container registry access (Docker Hub, ECR, GCR, etc.)

### Deployment Steps

1. **Build the Docker image** using the provided Dockerfile:
   ```bash
   docker build -t angular-app:latest .
   ```

2. **Test the image locally**:
   ```bash
   docker run -p 8080:80 angular-app:latest
   ```

3. **Push to a container registry**:
   ```bash
   docker tag angular-app:latest registry/username/angular-app:version
   docker push registry/username/angular-app:version
   ```

4. **Deploy on the target server**:
   ```bash
   docker pull registry/username/angular-app:version
   docker run -d -p 80:80 registry/username/angular-app:version
   ```

### Docker Compose (Optional)

For more complex setups with additional services, use Docker Compose:

```yaml
version: '3'
services:
  web:
    image: registry/username/angular-app:version
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl
    restart: always
```

## Kubernetes Deployment

Kubernetes provides scalability, high availability, and automated deployments for production environments.

### Prerequisites

- Kubernetes cluster (managed or self-hosted)
- kubectl configured to access your cluster
- Container registry with your Docker image

### Deployment Steps

1. **Apply the Kubernetes manifests** from the `k8s/` directory:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

2. **Verify the deployment**:
   ```bash
   kubectl get deployments
   kubectl get services
   kubectl get ingress
   ```

3. **Scale the deployment** as needed:
   ```bash
   kubectl scale deployment angular-app --replicas=5
   ```

For more details, see the README in the `k8s/` directory.

## Continuous Deployment

Automate your deployments using CI/CD pipelines.

### GitHub Actions Example

```yaml
name: Deploy Angular App

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build
      run: npm run build:prod
      
    - name: Build Docker image
      run: docker build -t myregistry/angular-app:${{ github.sha }} .
      
    - name: Push Docker image
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push myregistry/angular-app:${{ github.sha }}
        
    - name: Deploy to production
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          docker pull myregistry/angular-app:${{ github.sha }}
          docker stop angular-app || true
          docker rm angular-app || true
          docker run -d --name angular-app -p 80:80 myregistry/angular-app:${{ github.sha }}
```

## Performance Optimizations

To optimize your Angular app deployment:

1. **Enable Gzip/Brotli compression** (already configured in provided Nginx configs)

2. **Implement aggressive caching** for static assets (configured in the Nginx configurations)

3. **Use a CDN** for global distribution:
   - Configure your CDN to point to your Nginx server as the origin
   - Update your CSP headers to allow the CDN domain

4. **Enable HTTP/2** for multiplexing and reduced latency (configured in nginx-prod.conf)

5. **Optimize bundle size**:
   ```bash
   ng build --configuration production --source-map=false --build-optimizer=true
   ```

## Security Considerations

The provided configurations include several security enhancements:

1. **HTTPS enforcement** with modern cipher suites and protocols

2. **Security headers**:
   - Content-Security-Policy
   - X-XSS-Protection
   - X-Frame-Options
   - X-Content-Type-Options
   - Strict-Transport-Security

3. **Server hardening**:
   - Running Nginx as a non-root user
   - Hiding server version information
   - Restricting access to hidden files

4. **Regular updates**:
   ```bash
   sudo apt update && sudo apt upgrade -y nginx
   ```

## Troubleshooting

### Common Issues

1. **404 errors on page refresh**
   - Ensure the `try_files` directive is correctly configured in Nginx
   - Check that the location block is properly targeting all routes

2. **Mixed content warnings**
   - Make sure all resources are loaded over HTTPS
   - Update hardcoded HTTP URLs in your Angular app

3. **CORS issues**
   - Add appropriate CORS headers in your Nginx configuration:
     ```nginx
     add_header 'Access-Control-Allow-Origin' 'https://your-app.com';
     add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
     add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
     ```

4. **Performance issues**
   - Check for proper caching configuration
   - Verify that compression is enabled and working
   - Use browser developer tools to identify bottlenecks

5. **SSL/TLS certificate problems**
   - Verify certificate validity: `openssl x509 -in certificate.crt -text -noout`
   - Check certificate chain is complete
   - Ensure private key matches certificate: `openssl pkey -in privateKey.key -pubout -outform pem | sha256sum`

For additional support, consult the Nginx documentation or post specific issues to Stack Overflow or the Angular community forums.