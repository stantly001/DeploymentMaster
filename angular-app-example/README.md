# Angular Application Deployment with Nginx

This project demonstrates how to deploy an Angular application using Nginx as a web server. This setup provides an efficient, secure, and production-ready environment for serving your Angular single-page application.

## Features

- Optimized Nginx configuration for Angular applications
- HTML5 routing support
- Gzip compression for optimal loading speeds
- Security headers configuration
- SSL/TLS ready
- Static asset caching
- Detailed deployment script with backup functionality

## Project Structure

- `src/`: Angular application source code
- `nginx.conf`: Nginx server configuration
- `deploy.sh`: Deployment script
- `Dockerfile`: Docker configuration for containerized deployment

## Deployment Options

### Option 1: Direct Server Deployment

1. Build your Angular application:
   ```bash
   npm run build:prod
   ```

2. Run the deployment script:
   ```bash
   ./deploy.sh --environment prod --server your-server.com --user username --dir /var/www/html
   ```

   This will:
   - Build the application for production
   - Backup any existing deployment on the server
   - Copy the new build to the server
   - Configure Nginx
   - Restart Nginx

### Option 2: Docker Deployment

1. Build the Docker image:
   ```bash
   docker build -t angular-app .
   ```

2. Run the container:
   ```bash
   docker run -p 80:80 angular-app
   ```

### Option 3: Kubernetes Deployment

For Kubernetes deployment, you can use the Docker image built in Option 2 and create Kubernetes manifests as needed.

## Nginx Configuration Highlights

The provided `nginx.conf` includes:

- HTML5 routing configuration (`try_files $uri $uri/ /index.html`)
- Gzip compression for text-based assets
- Cache control headers for static assets
- Security headers (X-Frame-Options, X-XSS-Protection, etc.)
- Commented SSL/TLS configuration ready to be enabled

## Customizing the Deployment

### Server Configuration

Edit `nginx.conf` to customize:
- Server name (domain)
- SSL/TLS settings
- Cache durations
- Security headers
- API proxying (if needed)

### Deployment Script

The `deploy.sh` script accepts several parameters:
- `--environment` (`-e`): Environment to deploy to (dev, staging, prod)
- `--server` (`-s`): Server address
- `--port` (`-p`): SSH port
- `--user` (`-u`): SSH user
- `--dir` (`-d`): Remote directory to deploy to

Example:
```bash
./deploy.sh -e prod -s example.com -p 22 -u deployer -d /var/www/angular-app
```

## Security Considerations

1. Always use HTTPS in production (uncomment and configure SSL in nginx.conf)
2. Keep Nginx updated to the latest stable version
3. Review and customize the Content-Security-Policy header
4. Consider implementing rate limiting for production

## Performance Optimizations

The configuration includes:
- Gzip compression
- Browser caching
- Efficient routing

For further optimizations:
- Enable HTTP/2 (requires SSL)
- Implement a CDN for static assets
- Configure Brotli compression

## Troubleshooting

Common issues:

1. **404 errors on page refresh**: Ensure the `try_files $uri $uri/ /index.html;` directive is properly configured in Nginx.

2. **Permission denied errors**: Check file permissions and ownership on the server.

3. **Nginx configuration test fails**: Run `nginx -t` to identify syntax errors.

## Learn More

For more information about Angular deployment, see:
- [Angular Deployment Guide](https://angular.io/guide/deployment)
- [Nginx Documentation](https://nginx.org/en/docs/)