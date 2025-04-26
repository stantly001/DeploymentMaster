#!/bin/bash
# Script to deploy Angular application to Google Kubernetes Engine (GKE) using Helm

set -e

# Configuration variables
PROJECT_ID="" # Set your GCP project ID
CLUSTER_NAME="angular-cluster"
CLUSTER_ZONE="us-central1-a"
RELEASE_NAME="angular-app"
NAMESPACE="angular-app"
HELM_CHART_PATH="./helm-chart"
VALUES_FILE="$HELM_CHART_PATH/values.yaml"
DOCKER_IMAGE="gcr.io/$PROJECT_ID/angular-app:latest"
TIMEOUT="5m"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --project)
      PROJECT_ID="$2"
      shift
      shift
      ;;
    --cluster)
      CLUSTER_NAME="$2"
      shift
      shift
      ;;
    --zone)
      CLUSTER_ZONE="$2"
      shift
      shift
      ;;
    --image)
      DOCKER_IMAGE="$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: ./gke_deploy.sh [options]"
      echo ""
      echo "Options:"
      echo "  --project PROJECT_ID    Google Cloud project ID (required)"
      echo "  --cluster CLUSTER_NAME  GKE cluster name (default: angular-cluster)"
      echo "  --zone ZONE             GKE cluster zone (default: us-central1-a)"
      echo "  --image IMAGE           Docker image to deploy (default: gcr.io/PROJECT_ID/angular-app:latest)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$PROJECT_ID" ]; then
  echo "Error: --project PROJECT_ID is required"
  echo "Run ./gke_deploy.sh --help for usage information"
  exit 1
fi

# Update Docker image in values file
sed -i.bak "s|repository:.*|repository: ${DOCKER_IMAGE%:*}|g" $VALUES_FILE
sed -i.bak "s|tag:.*|tag: ${DOCKER_IMAGE##*:}|g" $VALUES_FILE

# Display banner
echo "===================================================="
echo "   Angular Application GKE Deployment Tool"
echo "===================================================="
echo
echo "Configuration:"
echo "  Project ID:    $PROJECT_ID"
echo "  Cluster:       $CLUSTER_NAME (in zone $CLUSTER_ZONE)"
echo "  Docker Image:  $DOCKER_IMAGE"
echo "  Namespace:     $NAMESPACE"
echo "  Helm Chart:    $HELM_CHART_PATH"
echo

# Configure gcloud
echo "➤ Configuring gcloud to use project $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Get GKE credentials
echo "➤ Getting credentials for GKE cluster $CLUSTER_NAME..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE

# Check if Istio is installed in the cluster
if kubectl get crd gateways.networking.istio.io &> /dev/null; then
  echo "✓ Istio CRDs found, proceeding with Istio-enabled deployment"
  ISTIO_ENABLED=true
else
  echo "! Istio not detected in the cluster. Will deploy without Istio service mesh integration."
  echo "  To enable Istio, you can install it with:"
  echo "  $ istioctl install --set profile=demo -y"
  ISTIO_ENABLED=false
  
  # Update values file to disable Istio
  if [ "$ISTIO_ENABLED" = false ]; then
    echo "➤ Modifying values file to disable Istio..."
    sed -i.bak 's/istio:\n  enabled: true/istio:\n  enabled: false/' $VALUES_FILE
  fi
fi

# Create namespace if it doesn't exist
echo "➤ Creating namespace $NAMESPACE if it doesn't exist..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Label namespace for Istio injection if Istio is enabled
if [ "$ISTIO_ENABLED" = true ]; then
  echo "➤ Enabling Istio sidecar injection for namespace $NAMESPACE..."
  kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
fi

# Deploy with Helm
echo "➤ Deploying Helm chart with release name $RELEASE_NAME..."
helm upgrade --install $RELEASE_NAME $HELM_CHART_PATH \
  --namespace $NAMESPACE \
  --timeout $TIMEOUT \
  --create-namespace \
  --wait

# Check deployment status
echo "➤ Checking deployment status..."
kubectl get pods -n $NAMESPACE

# Show services
echo
echo "➤ Service details:"
kubectl get svc -n $NAMESPACE

# Display Istio resources if enabled
if [ "$ISTIO_ENABLED" = true ]; then
  echo
  echo "➤ Istio Gateway:"
  kubectl get gateway -n $NAMESPACE
  
  echo
  echo "➤ Istio Virtual Service:"
  kubectl get virtualservice -n $NAMESPACE
  
  echo
  echo "➤ Istio Destination Rule:"
  kubectl get destinationrule -n $NAMESPACE
fi

# Check for LoadBalancer IP
if kubectl get svc -n $NAMESPACE | grep -q LoadBalancer; then
  echo
  echo "➤ Waiting for LoadBalancer IP address..."
  sleep 20
  LB_IP=$(kubectl get svc -n $NAMESPACE -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}')
  if [ -n "$LB_IP" ]; then
    echo "✓ Application is accessible at: http://$LB_IP"
  else
    echo "! LoadBalancer IP is not yet available. Check with 'kubectl get svc -n $NAMESPACE'"
  fi
fi

echo
echo "===================================================="
echo "✓ GKE Deployment completed!"
echo "===================================================="

# Restore original values file
if [ -f "$VALUES_FILE.bak" ]; then
  mv "$VALUES_FILE.bak" "$VALUES_FILE"
fi