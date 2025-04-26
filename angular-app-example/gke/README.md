# Google Kubernetes Engine (GKE) Deployment

This directory contains configuration files and scripts for deploying the Angular application to Google Kubernetes Engine (GKE).

## Prerequisites

Before deploying to GKE, ensure you have the following:

1. Google Cloud SDK installed (`gcloud`)
2. Docker installed
3. `kubectl` installed
4. Access to a Google Cloud Project with GKE API enabled
5. Authentication configured for Google Cloud

## Deployment Files

The following Kubernetes resource files are included:

- `gke-deployment.yaml`: Defines the deployment of the Angular application
- `gke-service.yaml`: Defines the service to expose the application
- `gke-configmap.yaml`: Contains the Nginx configuration
- `gke-ingress.yaml`: Defines the ingress resource with GKE specific annotations for HTTPS and certificates
- `gke-hpa.yaml`: Horizontal Pod Autoscaler configuration for scaling based on CPU and memory usage

## Deployment Options

### Option 1: Using the Deployment Script

The `gke_deploy.sh` script in the parent directory automates the deployment process:

```bash
./gke_deploy.sh --project=my-gcp-project --cluster=my-cluster --domain=example.com --create-cluster
```

The script supports various options:

- `--project`: Google Cloud Project ID (required)
- `--cluster`: GKE cluster name (default: angular-cluster)
- `--zone`: GKE cluster zone (default: us-central1-a)
- `--region`: GKE cluster region for regional clusters (default: us-central1)
- `--size`: GKE cluster size (nodes) (default: 3)
- `--create-cluster`: Create a new GKE cluster if it doesn't exist
- `--domain`: Domain name for the application (default: example.com)
- `--regional`: Create a regional cluster instead of zonal
- And more (run `./gke_deploy.sh --help` for all options)

### Option 2: Manual Deployment

#### 1. Create a GKE Cluster (if needed)

```bash
gcloud container clusters create angular-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type e2-standard-2
```

#### 2. Get credentials for kubectl

```bash
gcloud container clusters get-credentials angular-cluster --zone us-central1-a
```

#### 3. Build and push Docker image

```bash
PROJECT_ID=$(gcloud config get-value project)
docker build -t gcr.io/${PROJECT_ID}/angular-app:latest -f ../Dockerfile ..
gcloud auth configure-docker -q
docker push gcr.io/${PROJECT_ID}/angular-app:latest
```

#### 4. Update manifest files

```bash
PROJECT_ID=$(gcloud config get-value project)
APP_DOMAIN="your-domain.com"

mkdir -p generated
for file in *.yaml; do
  cat $file | \
    sed "s|\${DOCKER_REGISTRY}|gcr.io/${PROJECT_ID}|g" | \
    sed "s|\${IMAGE_TAG}|latest|g" | \
    sed "s|\${APP_DOMAIN}|${APP_DOMAIN}|g" > generated/$file
done
```

#### 5. Apply the Kubernetes manifests

```bash
kubectl apply -f generated/
```

## Setting up HTTPS with GKE

The configuration uses Google-managed certificates for HTTPS. This requires:

1. A registered domain name
2. DNS configured to point to the load balancer IP
3. Static IP address (created automatically by the ingress)

After deployment, you'll need to:

1. Get the load balancer IP assigned to the ingress:
   ```bash
   kubectl get ingress angular-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

2. Configure your DNS settings to point your domain to this IP address

3. Wait for the certificate to be provisioned (can take 15-60 minutes)
   ```bash
   kubectl get managedcertificate
   ```

## Advanced Configuration

For advanced GKE configuration options, consider:

1. Using Cloud SQL for database needs
2. Setting up Cloud IAP for secure access
3. Configuring network policies for additional security
4. Using Google Cloud Armor for DDoS protection
5. Setting up Cloud Monitoring for observability

## Troubleshooting

Check the status of deployed resources:

```bash
# Check deployments
kubectl get deployments

# Check pods and their status
kubectl get pods

# View pod logs for debugging
kubectl logs <pod-name>

# Check certificate status
kubectl describe managedcertificate angular-app-certificate
```

Certificate provisioning issues:
- Make sure DNS is properly configured
- GKE managed certificates can take up to an hour to provision
- Verify domain ownership in Google Cloud Console