# Angular Deployment Platform

A comprehensive deployment platform for Angular applications with support for multiple deployment strategies, including Kubernetes orchestration, Nginx configuration, and Istio service mesh integration.

## Features

- **Multiple Deployment Options**: Deploy to standard Kubernetes, GKE, or using standalone Nginx
- **Istio Service Mesh Integration**: Advanced traffic management, security, and observability
- **Nginx Web Server**: Optimized for Angular apps with proper routing and security headers
- **Helm Charts**: Customizable Helm charts for consistent deployments
- **Canary Deployments**: Test new versions with header-based routing or traffic splitting
- **Automated Scripts**: Simplified deployment with comprehensive scripts
- **GitHub Actions Integration**: CI/CD pipeline examples for automated deployments

## Repository Structure

```
angular-app-example/
├── helm-chart/                # Helm chart for Kubernetes deployments
│   ├── templates/             # Kubernetes manifests + Istio configurations
│   │   ├── deployment.yaml    # Main application deployment
│   │   ├── canary-deployment.yaml # Canary release deployment
│   │   ├── service.yaml       # Kubernetes service
│   │   ├── nginx-configmap.yaml # Nginx configuration
│   │   ├── istio-gateway.yaml # Istio ingress gateway
│   │   ├── istio-virtual-service.yaml # Istio routing rules
│   │   └── istio-destination-rule.yaml # Istio traffic policies
│   ├── values.yaml            # Default configuration values
│   └── README-istio-integration.md # Istio integration guide
├── scripts/                   # Helper scripts
│   ├── create-tls-secrets.sh  # TLS certificate creation for Istio
│   └── build-push-gcr.sh      # Build and push to Google Container Registry
├── Dockerfile                 # Multi-stage build for Angular with Nginx
├── nginx.conf                 # Nginx configuration for Angular SPA
├── helm_deploy.sh             # Standard Kubernetes deployment script
├── gke_deploy.sh              # Google Kubernetes Engine deployment script
├── deploy.sh                  # Unified deployment script for all environments
├── gke-nginx-istio-deploy.sh  # All-in-one GKE+Nginx+Istio deployment
└── .github/workflows/         # GitHub Actions CI/CD workflows
```

## Getting Started

### Prerequisites

- Docker
- Kubernetes cluster (local or cloud-based)
- Helm 3.2+
- kubectl configured for your cluster
- (Optional) Istio 1.8+ for service mesh features
- (Optional) Google Cloud SDK for GKE deployments

### Quick Start

1. **Deploy to Standard Kubernetes with Nginx**

```bash
# Deploy with default settings
./deploy.sh --target kubernetes

# Deploy with TLS and custom domain
./deploy.sh --target kubernetes --tls --domain example.com
```

2. **Deploy to Google Kubernetes Engine (GKE) with Nginx and Istio**

```bash
# Build, push to GCR, and deploy to GKE with Istio
./gke-nginx-istio-deploy.sh --project my-gcp-project --domain example.com --enable-tls all

# Deploy with canary release splitting 20% of traffic
./gke-nginx-istio-deploy.sh --project my-gcp-project --enable-canary --canary-split 20 deploy
```

3. **Test Canary Deployments**

After deployment with Istio enabled:

```bash
# Test the canary version (header-based routing)
curl -H "x-canary: true" https://example.com/

# The percentage-based traffic splitting happens automatically
```

## Deployment Components

### Nginx Configuration

The Nginx web server is configured optimally for Angular applications:

- SPA routing support (redirects to index.html for client-side routing)
- Gzip compression for improved performance
- Proper cache headers for static assets
- Security headers (Content-Security-Policy, X-XSS-Protection, etc.)
- Health check endpoint for Kubernetes probes

### Helm Chart Deployment

The Helm chart provides a flexible way to deploy the Angular application with all the necessary Kubernetes resources:

- Deployment for the application with Nginx
- ConfigMap for Nginx configuration
- Service for network access
- Optional HPA for autoscaling
- Optional Istio resources for service mesh features

### Istio Integration

The deployment includes comprehensive Istio service mesh integration for:

- Traffic management (routing, canary deployments, circuit breaking)
- Security (mTLS, authorization)
- Observability (metrics, tracing, logging)

See [Istio Integration Guide](helm-chart/README-istio-integration.md) for details.

### GKE-Specific Features

When deploying to Google Kubernetes Engine:

- Automatic cluster credentials setup
- Google Container Registry integration
- Node pool selection
- GCP-specific optimizations

## Combined GKE + Nginx + Istio Deployment

The `gke-nginx-istio-deploy.sh` script provides an all-in-one solution for deploying Angular applications to GKE with:

1. **Nginx as the web server** (via ConfigMap)
2. **Istio for advanced traffic management**
3. **Canary deployment capabilities**
4. **TLS support with automatic certificate creation**

This script handles:

- Building the Docker image with Nginx
- Pushing to Google Container Registry
- Configuring Istio Gateway and routing rules
- Setting up Nginx with proper configuration
- Creating TLS certificates for secure communication

### Usage Examples

```bash
# Build and push the Docker image
./gke-nginx-istio-deploy.sh --project my-gcp-project build push

# Deploy with canary deployment (20% traffic to canary)
./gke-nginx-istio-deploy.sh --project my-gcp-project --enable-canary --canary-split 20 deploy

# Deploy with TLS and custom domain
./gke-nginx-istio-deploy.sh --project my-gcp-project --domain example.com --enable-tls deploy

# Do everything at once
./gke-nginx-istio-deploy.sh --project my-gcp-project --domain example.com --enable-tls --enable-canary --canary-split 10 all
```

## Customization

### Configuration Values

The primary configuration is in `helm-chart/values.yaml`. Key sections include:

- `application`: Core application settings
- `image`: Docker image configuration
- `container.nginx`: Nginx configuration settings
- `service`: Network configuration
- `autoscaling`: HPA settings
- `istio`: Service mesh configuration

### Adding Custom Domains and TLS

1. Create TLS certificates:

```bash
./scripts/create-tls-secrets.sh --domain example.com
```

2. Deploy with Istio Gateway enabled:

```bash
./deploy.sh --target kubernetes --tls --domain example.com
```

## CI/CD Integration

The repository includes GitHub Actions workflows for:

- Docker image building and publishing
- Helm chart linting and testing
- Automated deployment to GKE

See the workflows in `.github/workflows/` for implementation details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.