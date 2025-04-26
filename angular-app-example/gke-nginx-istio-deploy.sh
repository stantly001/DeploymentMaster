#!/bin/bash
#==============================================================================
# GKE + Nginx + Istio Deployment Script for Angular Application
#
# This script orchestrates the deployment of an Angular application to Google
# Kubernetes Engine (GKE) using Nginx for serving the app, with Istio service
# mesh capabilities for advanced traffic management and routing.
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
PROJECT_ID=""                               # GCP project ID (required)
CLUSTER_NAME="angular-cluster"              # GKE cluster name
CLUSTER_ZONE="us-central1-a"                # GKE cluster zone
RELEASE_NAME="angular-app"                  # Helm release name
NAMESPACE="angular-app"                     # Kubernetes namespace
IMAGE_TAG="latest"                          # Docker image tag
DOMAIN=""                                   # Domain for TLS
ENABLE_TLS=false                            # Enable TLS
ENABLE_CANARY=false                         # Enable canary deployment
CANARY_PERCENTAGE=0                         # Percentage of traffic to canary (0-100)
HELM_TIMEOUT="5m"                           # Helm deployment timeout

# Paths
SCRIPTS_DIR="$(dirname "$0")/scripts"
DOCKERFILE_PATH="./Dockerfile"
HELM_CHART_PATH="./helm-chart"
TEMP_VALUES_FILE="/tmp/gke-nginx-istio-values.yaml"

# Steps to execute
DO_BUILD=false
DO_PUSH=false
DO_DEPLOY=false
DO_ALL=false

#------------------------------------------------------------------------------
# Display header banner
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "     GKE + Nginx + Istio Deployment Tool"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Display help message
#------------------------------------------------------------------------------
function show_help() {
  echo "Usage: ./gke-nginx-istio-deploy.sh [options] [commands]"
  echo ""
  echo "Commands:"
  echo "  build           Build the Docker image"
  echo "  push            Push the Docker image to GCR"
  echo "  deploy          Deploy to GKE using Helm"
  echo "  all             Perform all actions (build, push, deploy)"
  echo ""
  echo "Options:"
  echo "  --project ID         GCP project ID (required)"
  echo "  --cluster NAME       GKE cluster name (default: angular-cluster)"
  echo "  --zone ZONE          GKE cluster zone (default: us-central1-a)"
  echo "  --release NAME       Helm release name (default: angular-app)"
  echo "  --namespace NS       Kubernetes namespace (default: angular-app)"
  echo "  --tag TAG            Docker image tag (default: latest)"
  echo "  --domain DOMAIN      Domain for TLS"
  echo "  --enable-tls         Enable TLS for the application"
  echo "  --enable-canary      Enable canary deployment"
  echo "  --canary-split PCT   Percentage of traffic to send to canary (0-100)"
  echo "  --help               Display this help message"
  echo ""
  echo "Examples:"
  echo "  # Build and push the Docker image"
  echo "  ./gke-nginx-istio-deploy.sh --project my-gcp-project build push"
  echo ""
  echo "  # Deploy with canary splitting 20% traffic"
  echo "  ./gke-nginx-istio-deploy.sh --project my-gcp-project --enable-canary --canary-split 20 deploy"
  echo ""
  echo "  # Do everything with TLS"
  echo "  ./gke-nginx-istio-deploy.sh --project my-gcp-project --domain example.com --enable-tls all"
  exit 0
}

#------------------------------------------------------------------------------
# Parse command-line arguments
#------------------------------------------------------------------------------
function parse_args() {
  # Parse options
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
      --tag)
        IMAGE_TAG="$2"
        shift
        shift
        ;;
      --domain)
        DOMAIN="$2"
        shift
        shift
        ;;
      --enable-tls)
        ENABLE_TLS=true
        shift
        ;;
      --enable-canary)
        ENABLE_CANARY=true
        shift
        ;;
      --canary-split)
        CANARY_PERCENTAGE="$2"
        shift
        shift
        ;;
      --help)
        show_help
        ;;
      build|push|deploy|all)
        if [[ "$1" == "build" ]]; then
          DO_BUILD=true
        elif [[ "$1" == "push" ]]; then
          DO_PUSH=true
        elif [[ "$1" == "deploy" ]]; then
          DO_DEPLOY=true
        elif [[ "$1" == "all" ]]; then
          DO_ALL=true
        fi
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./gke-nginx-istio-deploy.sh --help for usage information"
        exit 1
        ;;
    esac
  done

  # Validate required parameters
  if [ -z "$PROJECT_ID" ]; then
    echo "Error: --project PROJECT_ID is required"
    echo "Run ./gke-nginx-istio-deploy.sh --help for usage information"
    exit 1
  fi

  # If no commands specified, show help
  if [[ "$DO_BUILD" == "false" && "$DO_PUSH" == "false" && "$DO_DEPLOY" == "false" && "$DO_ALL" == "false" ]]; then
    echo "Error: No command specified (build, push, deploy, or all)"
    echo "Run ./gke-nginx-istio-deploy.sh --help for usage information"
    exit 1
  fi

  # If all is specified, do everything
  if [[ "$DO_ALL" == "true" ]]; then
    DO_BUILD=true
    DO_PUSH=true
    DO_DEPLOY=true
  fi

  # Validate TLS configuration
  if [[ "$ENABLE_TLS" == "true" && -z "$DOMAIN" ]]; then
    echo "Error: --domain is required when --enable-tls is specified"
    exit 1
  fi

  # Set the full Docker image name
  DOCKER_IMAGE="gcr.io/$PROJECT_ID/$RELEASE_NAME:$IMAGE_TAG"

  # Log the configuration
  echo "Configuration:"
  echo "  GCP Project:    $PROJECT_ID"
  echo "  GKE Cluster:    $CLUSTER_NAME (in zone $CLUSTER_ZONE)"
  echo "  Release name:   $RELEASE_NAME"
  echo "  Namespace:      $NAMESPACE"
  echo "  Docker Image:   $DOCKER_IMAGE"
  
  if [[ "$ENABLE_TLS" == "true" ]]; then
    echo "  TLS:            Enabled"
    echo "  Domain:         $DOMAIN"
  fi
  
  if [[ "$ENABLE_CANARY" == "true" ]]; then
    echo "  Canary:         Enabled"
    echo "  Canary Split:   $CANARY_PERCENTAGE%"
  fi
  
  echo "  Actions:"
  if [[ "$DO_BUILD" == "true" ]]; then echo "    - Build Docker image"; fi
  if [[ "$DO_PUSH" == "true" ]]; then echo "    - Push to GCR"; fi
  if [[ "$DO_DEPLOY" == "true" ]]; then echo "    - Deploy to GKE"; fi
  
  echo
}

#------------------------------------------------------------------------------
# Configure Google Cloud
#------------------------------------------------------------------------------
function setup_gcloud() {
  echo "➤ Configuring gcloud to use project $PROJECT_ID..."
  gcloud config set project "$PROJECT_ID"
  
  if [[ "$DO_PUSH" == "true" ]]; then
    echo "➤ Authenticating Docker to GCR..."
    gcloud auth configure-docker -q
  fi
  
  if [[ "$DO_DEPLOY" == "true" ]]; then
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
  fi
  
  echo "✓ GCP configuration complete"
}

#------------------------------------------------------------------------------
# Build Docker image
#------------------------------------------------------------------------------
function build_image() {
  if [[ "$DO_BUILD" == "true" ]]; then
    echo "➤ Building Docker image..."
    
    # Check if Dockerfile exists
    if [ ! -f "$DOCKERFILE_PATH" ]; then
      echo "✗ Dockerfile not found at $DOCKERFILE_PATH"
      exit 1
    fi
    
    docker build -t "$DOCKER_IMAGE" -f "$DOCKERFILE_PATH" .
    
    echo "✓ Docker image built successfully"
  fi
}

#------------------------------------------------------------------------------
# Push image to GCR
#------------------------------------------------------------------------------
function push_to_gcr() {
  if [[ "$DO_PUSH" == "true" ]]; then
    echo "➤ Pushing image to Google Container Registry..."
    
    docker push "$DOCKER_IMAGE"
    
    echo "✓ Image pushed to GCR successfully: $DOCKER_IMAGE"
  fi
}

#------------------------------------------------------------------------------
# Prepare values for Helm chart
#------------------------------------------------------------------------------
function prepare_values_file() {
  if [[ "$DO_DEPLOY" == "true" ]]; then
    echo "➤ Preparing values for Helm deployment..."
    
    # Start with the default values file
    cp "$HELM_CHART_PATH/values.yaml" "$TEMP_VALUES_FILE"
    
    # Update image information
    # shellcheck disable=SC2016
    sed -i "s|repository:.*|repository: gcr.io/$PROJECT_ID/$RELEASE_NAME|g" "$TEMP_VALUES_FILE"
    sed -i "s|tag:.*|tag: $IMAGE_TAG|g" "$TEMP_VALUES_FILE"
    
    # Enable GKE-specific settings
    sed -i "s|gke:\n  enabled: false|gke:\n  enabled: true|g" "$TEMP_VALUES_FILE"
    sed -i "s|projectId:.*|projectId: \"$PROJECT_ID\"|g" "$TEMP_VALUES_FILE"
    sed -i "s|clusterName:.*|clusterName: \"$CLUSTER_NAME\"|g" "$TEMP_VALUES_FILE"
    
    # Enable Nginx
    sed -i "s|nginx:\n    enabled: true|nginx:\n    enabled: true|g" "$TEMP_VALUES_FILE"
    
    # Configure Canary if enabled
    if [[ "$ENABLE_CANARY" == "true" && "$CANARY_PERCENTAGE" -gt 0 ]]; then
      STABLE_PERCENTAGE=$((100 - CANARY_PERCENTAGE))
      
      # Enable traffic shifting
      sed -i "s|trafficShifting:\n      enabled: false|trafficShifting:\n      enabled: true|g" "$TEMP_VALUES_FILE"
      sed -i "s|stableWeight:.*|stableWeight: $STABLE_PERCENTAGE|g" "$TEMP_VALUES_FILE"
      sed -i "s|canaryWeight:.*|canaryWeight: $CANARY_PERCENTAGE|g" "$TEMP_VALUES_FILE"
    fi
    
    # Configure TLS if enabled
    if [[ "$ENABLE_TLS" == "true" ]]; then
      # Update Gateway hosts
      sed -i "s|hosts:\n      - \"\\*\"|hosts:\n      - \"$DOMAIN\"|g" "$TEMP_VALUES_FILE"
      
      # Enable TLS
      sed -i "s|tls:\n      enabled: false|tls:\n      enabled: true|g" "$TEMP_VALUES_FILE"
      
      # Set credential name (will be created later)
      TLS_SECRET_NAME="${RELEASE_NAME}-tls-cert"
      sed -i "s|credentialName:.*|credentialName: \"$TLS_SECRET_NAME\"|g" "$TEMP_VALUES_FILE"
    fi
    
    echo "✓ Values file prepared successfully"
  fi
}

#------------------------------------------------------------------------------
# Create TLS certificate if required
#------------------------------------------------------------------------------
function create_tls_cert() {
  if [[ "$DO_DEPLOY" == "true" && "$ENABLE_TLS" == "true" ]]; then
    echo "➤ Creating TLS certificate for $DOMAIN..."
    
    # Check if create-tls-secrets.sh exists and is executable
    if [[ ! -x "$SCRIPTS_DIR/create-tls-secrets.sh" ]]; then
      echo "Error: TLS certificate creation script not found or not executable"
      echo "Expected path: $SCRIPTS_DIR/create-tls-secrets.sh"
      exit 1
    fi
    
    # Create TLS certificate
    TLS_SECRET_NAME="${RELEASE_NAME}-tls-cert"
    "$SCRIPTS_DIR/create-tls-secrets.sh" --domain "$DOMAIN" --namespace "$NAMESPACE" --secret-name "$TLS_SECRET_NAME"
    
    echo "✓ TLS certificate created successfully"
  fi
}

#------------------------------------------------------------------------------
# Deploy with Helm
#------------------------------------------------------------------------------
function deploy_with_helm() {
  if [[ "$DO_DEPLOY" == "true" ]]; then
    echo "➤ Deploying Helm chart with release name $RELEASE_NAME..."
    
    # Ensure namespace exists
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Enable Istio sidecar injection if Istio is available
    if kubectl get crd gateways.networking.istio.io &> /dev/null; then
      echo "✓ Istio service mesh detected in the cluster"
      kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
    else
      echo "! Istio service mesh not detected"
      echo "  - The deployment will continue but without Istio integration"
      echo "  - To enable Istio features, install it first"
      
      # Disable Istio in values
      sed -i "s|istio:\n  enabled: true|istio:\n  enabled: false|g" "$TEMP_VALUES_FILE"
    fi
    
    # Deploy with Helm
    helm upgrade --install "$RELEASE_NAME" "$HELM_CHART_PATH" \
      --namespace "$NAMESPACE" \
      --values "$TEMP_VALUES_FILE" \
      --timeout "$HELM_TIMEOUT" \
      --create-namespace \
      --wait
    
    if [ $? -eq 0 ]; then
      echo "✓ Helm deployment successful"
    else
      echo "✗ Helm deployment failed"
      exit 1
    fi
  fi
}

#------------------------------------------------------------------------------
# Show deployment information
#------------------------------------------------------------------------------
function show_deployment_info() {
  if [[ "$DO_DEPLOY" == "true" ]]; then
    echo "➤ Checking deployment status..."
    kubectl get deployments -n "$NAMESPACE"
    
    echo
    echo "➤ Pods:"
    kubectl get pods -n "$NAMESPACE"
    
    echo
    echo "➤ Service details:"
    kubectl get svc -n "$NAMESPACE"
    
    # Show Istio resources if they exist
    if kubectl get crd gateways.networking.istio.io &> /dev/null; then
      echo
      echo "➤ Istio Gateway:"
      kubectl get gateway -n "$NAMESPACE" || true
      
      echo
      echo "➤ Istio Virtual Service:"
      kubectl get virtualservice -n "$NAMESPACE" || true
      
      echo
      echo "➤ Istio Destination Rule:"
      kubectl get destinationrule -n "$NAMESPACE" || true
      
      # Show Istio Ingress Gateway details
      echo
      echo "➤ Istio Ingress Gateway:"
      INGRESS_IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
      
      if [ -n "$INGRESS_IP" ]; then
        echo "Ingress Gateway IP: $INGRESS_IP"
        
        if [[ "$ENABLE_TLS" == "true" ]]; then
          echo "Application URL: https://$DOMAIN"
          echo "(Make sure to configure your DNS to point to $INGRESS_IP)"
        else
          echo "Application URL: http://$INGRESS_IP"
        fi
        
        if [[ "$ENABLE_CANARY" == "true" ]]; then
          echo
          echo "To test the canary deployment, use:"
          echo "curl -H \"x-canary: true\" http://$INGRESS_IP"
        fi
      else
        echo "Ingress Gateway IP not yet available."
      fi
    else
      # Regular service
      if kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.type}' | grep -q LoadBalancer; then
        echo
        echo "➤ LoadBalancer details:"
        LB_IP=$(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        
        if [ -n "$LB_IP" ]; then
          echo "LoadBalancer IP: $LB_IP"
          echo "Application URL: http://$LB_IP"
        else
          echo "LoadBalancer IP not yet available."
        fi
      fi
    fi
  fi
}

#------------------------------------------------------------------------------
# Clean up temporary files
#------------------------------------------------------------------------------
function cleanup() {
  if [ -f "$TEMP_VALUES_FILE" ]; then
    rm -f "$TEMP_VALUES_FILE"
  fi
}

#------------------------------------------------------------------------------
# Main execution
#------------------------------------------------------------------------------
function main() {
  print_banner
  parse_args "$@"
  setup_gcloud
  build_image
  push_to_gcr
  prepare_values_file
  create_tls_cert
  deploy_with_helm
  show_deployment_info
  cleanup
  
  echo
  echo "===================================================="
  echo "✓ Deployment process completed successfully!"
  echo "===================================================="
}

# Execute main function with all arguments
main "$@"