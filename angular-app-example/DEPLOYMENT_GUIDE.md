# Angular Application Deployment Guide

This guide provides comprehensive instructions for deploying Angular applications in various environments using different deployment methods.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deployment Options](#deployment-options)
   - [Nginx Deployment](#nginx-deployment)
   - [Docker Deployment](#docker-deployment)
   - [Kubernetes Deployment](#kubernetes-deployment)
3. [Continuous Integration/Continuous Deployment](#continuous-integrationcontinuous-deployment)
4. [SSL Configuration](#ssl-configuration)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying your Angular application, ensure you have the following:

- Node.js (v14+) and npm installed
- Angular CLI (`npm install -g @angular/cli`)
- Build artifacts generated (`ng build --prod`)
- For Docker deployment: Docker installed and Docker Hub account
- For Kubernetes deployment: kubectl configured with appropriate cluster access
- For all deployment methods: Domain name and SSL certificates (optional but recommended)

## Deployment Options

### Nginx Deployment

Nginx is a lightweight, high-performance web server that works well for serving Angular applications.

#### Basic Deployment Steps:

1. **Build your Angular application for production:**
   ```bash
   ng build --prod
   ```
   
2. **Install Nginx (if not already installed):**
   ```bash
   sudo apt update
   sudo apt install nginx
   ```
   
3. **Create an Nginx configuration file:**
   Create a file at `/etc/nginx/sites-available/your-app.conf` with the content from our `nginx.conf` template.
   
4. **Enable the site and restart Nginx:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/your-app.conf /etc/nginx/sites-enabled/
   sudo nginx -t  # Test the configuration
   sudo systemctl restart nginx
   ```

#### Using the Deployment Script:

Our included `deploy.sh` script automates this process:

```bash
./deploy.sh --env=prod --type=nginx --domain=your-domain.com
```

### Docker Deployment

Docker allows you to package your application with all dependencies in a container for consistent deployment across environments.

#### Basic Deployment Steps:

1. **Build your Docker image:**
   ```bash
   docker build -t your-username/angular-app:latest .
   ```
   
2. **Run the Docker container:**
   ```bash
   docker run -d -p 80:80 -p 443:443 -v /path/to/ssl:/etc/nginx/ssl --name angular-app your-username/angular-app:latest
   ```

#### Using the Deployment Script:

```bash
./deploy.sh --env=prod --type=docker --domain=your-domain.com --docker-registry=your-username
```

### Kubernetes Deployment

Kubernetes provides a powerful platform for scaling and managing containerized applications.

#### Basic Deployment Steps:

1. **Apply the Kubernetes manifests:**
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

#### Using the Deployment Script:

```bash
./deploy.sh --env=prod --type=kubernetes --domain=your-domain.com --docker-registry=your-username
```

## Continuous Integration/Continuous Deployment

This project includes a GitHub Actions workflow for automated CI/CD. The workflow:

1. Builds the Angular application
2. Runs unit and e2e tests
3. Builds and pushes a Docker image
4. Deploys to the specified environment

To use this workflow:

1. Add the following secrets to your GitHub repository:
   - `DOCKER_USERNAME` and `DOCKER_PASSWORD` for Docker Hub access
   - `SSH_PRIVATE_KEY` for deployment server access
   - `HOST` and `USERNAME` for the deployment server
   - `SLACK_WEBHOOK` for deployment notifications (optional)

2. Push to the main branch or manually trigger the workflow.

## SSL Configuration

For production deployments, SSL certificates are essential. We recommend using Let's Encrypt:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

Our Nginx configurations are pre-configured to use SSL certificates from `/etc/nginx/ssl/` or `/etc/letsencrypt/`.

## Troubleshooting

### Common Issues and Solutions

1. **404 errors on page refresh:**
   - Ensure your Nginx configuration includes proper URL rewriting for Angular's routing.
   - Check the `try_files $uri $uri/ /index.html;` directive in your Nginx configuration.

2. **SSL certificate issues:**
   - Verify certificate paths in Nginx configuration
   - Check certificate expiration: `certbot certificates`
   - Renew certificates if needed: `certbot renew`

3. **Docker container not starting:**
   - Check logs: `docker logs angular-app`
   - Verify port availability: `netstat -tuln | grep '80\|443'`

4. **Kubernetes deployment issues:**
   - Check pod status: `kubectl get pods`
   - View pod logs: `kubectl logs <pod-name>`
   - Inspect events: `kubectl get events`

For more complex troubleshooting, refer to the specific documentation for Nginx, Docker, or Kubernetes.

---

## Additional Resources

- [Angular Deployment Guide](https://angular.io/guide/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)