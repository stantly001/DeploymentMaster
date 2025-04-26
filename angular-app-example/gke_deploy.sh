#!/bin/bash
#==============================================================================
# Google Kubernetes Engine (GKE) Deployment Script for Angular Application
#
# This script deploys an Angular application to GKE using Helm with
# optional Istio service mesh integration.
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
PROJECT_ID=""                                   # GCP project ID (required)
CLUSTER_NAME="angular-cluster"                  # GKE cluster name
CLUSTER_ZONE="us-central1-a"                    # GKE cluster zone
RELEASE_NAME="angular-app"                      # Helm release name
NAMESPACE="angular-app"                         # Kubernetes namespace
HELM_CHART_PATH="./helm-chart"                  # Path to Helm chart
VALUES_FILE="$HELM_CHART_PATH/values.yaml"      # Default values file
CUSTOM_VALUES_FILE=""                           # Custom values file (optional)
TEMP_VALUES_FILE="/tmp/gke-values-modified.yaml" # Temp values file
DOCKER_IMAGE=""                                 # Docker image to deploy
TIMEOUT="5m"                                    # Deployment timeout

#------------------------------------------------------------------------------
# Display header banner
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "   Angular Application GKE Deployment Tool"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Display help message
#------------------------------------------------------------------------------
function show_help() {
  echo "Usage: ./gke_deploy.sh [options]"
  echo ""
  echo "Options:"
  echo "  --project PROJECT_ID    Google Cloud project ID (required)"
  echo "  --cluster CLUSTER_NAME  GKE cluster name (default: angular-cluster)"
  echo "  --zone ZONE             GKE cluster zone (default: us-central1-a)"
  echo "  --release NAME          Helm release name (default: angular-app)"
  echo "  --namespace NS          Kubernetes namespace (default: angular-app)"
  echo "  --image IMAGE           Docker image to deploy (default: gcr.io/PROJECT_ID/angular-app:latest)"
  echo "  --values FILE           Custom values file for Helm"
  echo "  --timeout DURATION      Deployment timeout (default: 5m)"
  echo "  --help                  Display this help message"
  echo ""
  echo "Examples:"
  echo "  # Deploy with default settings"
  echo "  ./gke_deploy.sh --project my-gcp-project"
  echo ""
  echo "  # Deploy specific image version to custom namespace"
  echo "  ./gke_deploy.sh --project my-gcp-project --image gcr.io/my-gcp-project/angular-app:v1.2.3 --namespace production"
  exit 0
}

#------------------------------------------------------------------------------
# Parse command-line arguments
#------------------------------------------------------------------------------
function parse_args() {
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
      --release)
        RELEASE_NAME="$2"
        shift
        shift
        ;;
      --namespace)
        NAMESPACE="$2"
        shift
        shift
        ;;
      --image)
        DOCKER_IMAGE="$2"
        shift
        shift
        ;;
      --values)
        CUSTOM_VALUES_FILE="$2"
        shift
        shift
        ;;
      --timeout)
        TIMEOUT="$2"
        shift
        shift
        ;;
      --help)
        show_help
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./gke_deploy.sh --help for usage information"
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

  # Set default Docker image if not provided
  if [ -z "$DOCKER_IMAGE" ]; then
    DOCKER_IMAGE="gcr.io/$PROJECT_ID/angular-app:latest"
  fi

  # Log the configuration
  echo "Configuration:"
  echo "  GCP Project:   $PROJECT_ID"
  echo "  GKE Cluster:   $CLUSTER_NAME (in zone $CLUSTER_ZONE)"
  echo "  Release name:  $RELEASE_NAME"
  echo "  Namespace:     $NAMESPACE"
  echo "  Docker Image:  $DOCKER_IMAGE"
  echo "  Timeout:       $TIMEOUT"
  if [ -n "$CUSTOM_VALUES_FILE" ]; then
    echo "  Values file:   $CUSTOM_VALUES_FILE"
  fi
  echo
}

#------------------------------------------------------------------------------
# Prepare values file with Docker image info
#------------------------------------------------------------------------------
function prepare_values_file() {
  echo "➤ Preparing values file with image information..."
  
  # Start with the appropriate values file
  if [ -n "$CUSTOM_VALUES_FILE" ]; then
    cp "$CUSTOM_VALUES_FILE" "$TEMP_VALUES_FILE"
  else
    cp "$VALUES_FILE" "$TEMP_VALUES_FILE"
  fi
  
  # Extract repository and tag from Docker image
  IMAGE_REPO="${DOCKER_IMAGE%:*}"
  IMAGE_TAG="${DOCKER_IMAGE##*:}"
  
  # Use yq if available, otherwise fall back to sed
  if command -v yq &> /dev/null; then
    yq e ".image.repository = \"$IMAGE_REPO\"" -i "$TEMP_VALUES_FILE"
    yq e ".image.tag = \"$IMAGE_TAG\"" -i "$TEMP_VALUES_FILE"
  else
    # Fallback to sed for modifying values
    sed -i.bak "s|repository:.*|repository: $IMAGE_REPO|g" "$TEMP_VALUES_FILE"
    sed -i.bak "s|tag:.*|tag: $IMAGE_TAG|g" "$TEMP_VALUES_FILE"
    rm -f "${TEMP_VALUES_FILE}.bak"
  fi
  
  echo "✓ Values file prepared with image: $IMAGE_REPO:$IMAGE_TAG"
}

#------------------------------------------------------------------------------
# Configure Google Cloud and get GKE cluster credentials
#------------------------------------------------------------------------------
function setup_gcloud() {
  echo "➤ Configuring gcloud to use project $PROJECT_ID..."
  gcloud config set project "$PROJECT_ID"
  
  echo "➤ Getting credentials for GKE cluster $CLUSTER_NAME..."
  gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$CLUSTER_ZONE"
  
  if [ $? -ne 0 ]; then
    echo "✗ Failed to get GKE cluster credentials"
    echo "Make sure:"
    echo "  - The cluster '$CLUSTER_NAME' exists in zone '$CLUSTER_ZONE'"
    echo "  - You have permission to access the cluster"
    echo "  - Google Cloud SDK is properly installed and authenticated"
    exit 1
  fi
  
  echo "✓ Successfully connected to GKE cluster"
}

#------------------------------------------------------------------------------
# Check Istio status and prepare namespace
#------------------------------------------------------------------------------
function setup_namespace() {
  # Create namespace if it doesn't exist
  echo "➤ Creating namespace $NAMESPACE if it doesn't exist..."
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
  
  # Check if Istio is installed in the cluster
  if kubectl get crd gateways.networking.istio.io &> /dev/null; then
    echo "✓ Istio service mesh detected in the cluster"
    ISTIO_ENABLED=true
    
    # Enable Istio sidecar injection
    echo "➤ Enabling Istio sidecar injection for namespace $NAMESPACE..."
    kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
  else
    echo "! Istio service mesh not detected in the cluster"
    echo "  - The deployment will continue without Istio integration"
    echo "  - To enable Istio features, install it with: istioctl install --set profile=demo -y"
    ISTIO_ENABLED=false
    
    # Update values file to disable Istio
    if command -v yq &> /dev/null; then
      yq e '.istio.enabled = false' -i "$TEMP_VALUES_FILE"
    else
      # Using grep with line numbers to find the istio enabled line
      ISTIO_LINE=$(grep -n "istio:" "$TEMP_VALUES_FILE" | cut -d ":" -f1)
      if [ -n "$ISTIO_LINE" ]; then
        ENABLED_LINE=$((ISTIO_LINE + 1))
        sed -i "${ENABLED_LINE}s/enabled: true/enabled: false/" "$TEMP_VALUES_FILE"
      fi
    fi
  fi
}

#------------------------------------------------------------------------------
# Deploy with Helm
#------------------------------------------------------------------------------
function deploy_with_helm() {
  echo "➤ Deploying Helm chart with release name $RELEASE_NAME..."
  
  # Use Helm to deploy
  helm upgrade --install "$RELEASE_NAME" "$HELM_CHART_PATH" \
    --namespace "$NAMESPACE" \
    --timeout "$TIMEOUT" \
    --create-namespace \
    --values "$TEMP_VALUES_FILE" \
    --wait
  
  # Check if deployment was successful
  if [ $? -eq 0 ]; then
    echo "✓ Helm deployment successful"
  else
    echo "✗ Helm deployment failed"
    exit 1
  fi
}

#------------------------------------------------------------------------------
# Show deployment information
#------------------------------------------------------------------------------
function show_deployment_info() {
  echo "➤ Checking deployment status..."
  kubectl get pods -n "$NAMESPACE"
  
  echo
  echo "➤ Service details:"
  kubectl get svc -n "$NAMESPACE"
  
  # Display Istio resources if enabled
  if [ "$ISTIO_ENABLED" = true ]; then
    echo
    echo "➤ Istio resources:"
    
    echo "Gateway:"
    kubectl get gateway -n "$NAMESPACE"
    
    echo
    echo "Virtual Service:"
    kubectl get virtualservice -n "$NAMESPACE"
    
    echo
    echo "Destination Rule:"
    kubectl get destinationrule -n "$NAMESPACE"
  fi
  
  # Check for Istio Ingress Gateway
  if [ "$ISTIO_ENABLED" = true ]; then
    echo
    echo "➤ Istio Ingress Gateway:"
    kubectl get svc -n istio-system istio-ingressgateway
    
    INGRESS_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -n "$INGRESS_IP" ]; then
      echo
      echo "✓ Application should be accessible via Istio Gateway at:"
      echo "  http://$INGRESS_IP"
      echo "  (Make sure to configure your DNS or /etc/hosts to point to this IP)"
    fi
  # Check for regular LoadBalancer service
  elif kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.type}' | grep -q LoadBalancer; then
    echo
    echo "➤ Waiting for LoadBalancer IP assignment..."
    # Wait for a bit to allow IP assignment
    for i in {1..6}; do
      echo -n "."
      sleep 5
      LB_IP=$(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      if [ -n "$LB_IP" ]; then
        break
      fi
    done
    echo
    
    if [ -n "$LB_IP" ]; then
      SVC_PORT=$(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.ports[0].port}')
      echo "✓ Application is accessible at: http://$LB_IP:$SVC_PORT"
    else
      echo "! LoadBalancer IP is not yet available. Check later with:"
      echo "  kubectl get svc -n $NAMESPACE $RELEASE_NAME"
    fi
  else
    echo
    echo "➤ Application access:"
    echo "The service is not exposed via LoadBalancer. Use port-forwarding to access:"
    echo "kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 8080:80"
  fi
}

#------------------------------------------------------------------------------
# Main execution
#------------------------------------------------------------------------------
function main() {
  print_banner
  parse_args "$@"
  prepare_values_file
  setup_gcloud
  setup_namespace
  deploy_with_helm
  show_deployment_info
  
  # Clean up temporary files
  if [ -f "$TEMP_VALUES_FILE" ]; then
    rm -f "$TEMP_VALUES_FILE"
  fi
  
  echo
  echo "===================================================="
  echo "✓ GKE Deployment completed successfully!"
  echo "===================================================="
}

# Execute main function with all arguments
main "$@"