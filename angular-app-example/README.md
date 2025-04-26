# Angular Deployment Platform

A comprehensive deployment platform for Angular applications with support for multiple deployment strategies, including Kubernetes orchestration, Nginx configuration, and Istio service mesh integration.

## Features

- **Multiple Deployment Options**: Deploy to standard Kubernetes, GKE, or using standalone Nginx
- **Istio Service Mesh Integration**: Advanced traffic management, security, and observability
- **Helm Charts**: Customizable Helm charts for consistent deployments
- **Canary Deployments**: Test new versions with header-based routing or traffic splitting
- **Automated Scripts**: Simplified deployment with comprehensive scripts
- **GitHub Actions Integration**: CI/CD pipeline examples for automated deployments

## Repository Structure

```
angular-app-example/
├── helm-chart/                # Helm chart for Kubernetes deployments
│   ├── templates/             # Kubernetes manifests + Istio configurations
│   ├── values.yaml            # Default configuration values
│   └── README.md              # Helm chart documentation
├── istio/                     # Standalone Istio configurations
│   ├── traffic/               # Traffic management resources
│   └── README.md              # Istio configuration guide
├── scripts/                   # Helper scripts
│   └── create-tls-secrets.sh  # TLS certificate creation for Istio
├── multi-stage.Dockerfile     # Optimized Docker build file
├── helm_deploy.sh             # Standard Kubernetes deployment script
├── gke_deploy.sh              # Google Kubernetes Engine deployment script
├── deploy.sh                  # Unified deployment script for all environments
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

1. **Deploy to Standard Kubernetes**

```bash
# Deploy with default settings
./deploy.sh --target kubernetes

# Deploy with TLS and custom domain
./deploy.sh --target kubernetes --tls --domain example.com
```

2. **Deploy to Google Kubernetes Engine (GKE)**

```bash
# Deploy to GKE
./deploy.sh --target gke --project my-gcp-project --cluster my-cluster --zone us-central1-a
```

3. **Test Canary Deployments**

After deployment with Istio enabled:

```bash
# Test the canary version (header-based routing)
curl -H "x-canary: true" https://example.com/

# Or configure traffic splitting in values.yaml for percentage-based routing
```

## Deployment Options

### Helm Chart Deployment

The Helm chart provides a flexible way to deploy the Angular application with all the necessary Kubernetes resources:

- Deployment for the application
- Service for network access
- Optional HPA for autoscaling
- Optional Istio resources for service mesh features

See [Helm Chart README](helm-chart/README.md) for detailed configuration options.

### Istio Integration

The deployment includes comprehensive Istio service mesh integration for:

- Traffic management (routing, canary deployments, circuit breaking)
- Security (mTLS, authorization)
- Observability (metrics, tracing, logging)

See [Istio Integration Guide](helm-chart/README-istio-integration.md) for details.

### GKE-Specific Features

When deploying to Google Kubernetes Engine:

- Automatic cluster credentials setup
- Google Cloud Build integration
- GCP-specific optimizations

## Customization

### Configuration Values

The primary configuration is in `helm-chart/values.yaml`. Key sections include:

- `application`: Core application settings
- `image`: Docker image configuration
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