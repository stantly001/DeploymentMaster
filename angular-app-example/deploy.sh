#!/bin/bash
#==============================================================================
# Angular Application Unified Deployment Script
#
# This script provides a unified interface for deploying the Angular app to
# different Kubernetes environments with proper configuration.
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
SCRIPTS_DIR="$(dirname "$0")/scripts"
DEPLOY_TARGET="kubernetes" # kubernetes, gke
RELEASE_NAME="angular-app"
NAMESPACE="angular-app"
VALUES_FILE=""
TIMEOUT="5m"
DOMAIN=""
CREATE_TLS_CERT=false
PROJECT_ID="" # For GKE
CLUSTER_NAME="" # For GKE
CLUSTER_ZONE="" # For GKE
IMAGE_TAG="" # For Docker image

#------------------------------------------------------------------------------
# Display Header
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "        Angular Application Deployment Tool"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Display help
#------------------------------------------------------------------------------
function show_help() {
  echo "Usage: ./deploy.sh [options]"
  echo ""
  echo "Options:"
  echo "  --target TYPE        Deployment target (kubernetes, gke) (default: kubernetes)"
  echo "  --release NAME       Set the Helm release name (default: angular-app)"
  echo "  --namespace NS       Set the Kubernetes namespace (default: angular-app)"
  echo "  --values FILE        Specify custom values file"
  echo "  --timeout DURATION   Set deployment timeout (default: 5m)"
  echo "  --domain DOMAIN      Set domain for TLS certificate"
  echo "  --tls                Create TLS certificate for Istio Gateway"
  echo ""
  echo "GKE-specific options:"
  echo "  --project ID         GCP project ID (required for GKE)"
  echo "  --cluster NAME       GKE cluster name (default: angular-cluster)"
  echo "  --zone ZONE          GKE cluster zone (default: us-central1-a)"
  echo "  --image-tag TAG      Docker image tag to deploy (default: latest)"
  echo ""
  echo "  --help               Display this help message"
  echo ""
  echo "Examples:"
  echo "  # Deploy to standard Kubernetes"
  echo "  ./deploy.sh --target kubernetes"
  echo ""
  echo "  # Deploy to GKE with TLS"
  echo "  ./deploy.sh --target gke --project my-project --domain myapp.example.com --tls"
  exit 0
}

#------------------------------------------------------------------------------
# Parse command-line arguments
#------------------------------------------------------------------------------
function parse_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --target)
        DEPLOY_TARGET="$2"
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
      --values)
        VALUES_FILE="$2"
        shift
        shift
        ;;
      --timeout)
        TIMEOUT="$2"
        shift
        shift
        ;;
      --domain)
        DOMAIN="$2"
        shift
        shift
        ;;
      --tls)
        CREATE_TLS_CERT=true
        shift
        ;;
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
      --image-tag)
        IMAGE_TAG="$2"
        shift
        shift
        ;;
      --help)
        show_help
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./deploy.sh --help for usage information"
        exit 1
        ;;
    esac
  done

  # Validate arguments
  if [[ "$DEPLOY_TARGET" != "kubernetes" && "$DEPLOY_TARGET" != "gke" ]]; then
    echo "Error: Invalid target. Must be 'kubernetes' or 'gke'"
    exit 1
  fi

  if [[ "$DEPLOY_TARGET" == "gke" && -z "$PROJECT_ID" ]]; then
    echo "Error: --project is required for GKE deployment"
    exit 1
  fi

  if [[ "$CREATE_TLS_CERT" == true && -z "$DOMAIN" ]]; then
    echo "Error: --domain is required when --tls is specified"
    exit 1
  fi

  # Set defaults for GKE-specific options
  if [[ "$DEPLOY_TARGET" == "gke" ]]; then
    CLUSTER_NAME=${CLUSTER_NAME:-"angular-cluster"}
    CLUSTER_ZONE=${CLUSTER_ZONE:-"us-central1-a"}
    IMAGE_TAG=${IMAGE_TAG:-"latest"}
  fi

  # Log the configuration
  echo "Configuration:"
  echo "  Target:        $DEPLOY_TARGET"
  echo "  Release name:  $RELEASE_NAME"
  echo "  Namespace:     $NAMESPACE"
  
  if [[ -n "$VALUES_FILE" ]]; then
    echo "  Values file:   $VALUES_FILE"
  fi
  
  if [[ "$CREATE_TLS_CERT" == true ]]; then
    echo "  Domain:        $DOMAIN"
    echo "  Create TLS:    Yes"
  fi
  
  if [[ "$DEPLOY_TARGET" == "gke" ]]; then
    echo "  GCP Project:   $PROJECT_ID"
    echo "  GKE Cluster:   $CLUSTER_NAME"
    echo "  GKE Zone:      $CLUSTER_ZONE"
    echo "  Image tag:     $IMAGE_TAG"
  fi
  
  echo
}

#------------------------------------------------------------------------------
# Create TLS certificate if requested
#------------------------------------------------------------------------------
function create_tls_cert() {
  if [[ "$CREATE_TLS_CERT" == true ]]; then
    echo "➤ Creating TLS certificate for $DOMAIN..."
    
    # Check if create-tls-secrets.sh exists and is executable
    if [[ ! -x "$SCRIPTS_DIR/create-tls-secrets.sh" ]]; then
      echo "Error: TLS certificate creation script not found or not executable"
      echo "Expected path: $SCRIPTS_DIR/create-tls-secrets.sh"
      exit 1
    fi
    
    # Create TLS certificate
    "$SCRIPTS_DIR/create-tls-secrets.sh" --domain "$DOMAIN" --namespace "$NAMESPACE"
  fi
}

#------------------------------------------------------------------------------
# Deploy to Kubernetes
#------------------------------------------------------------------------------
function deploy_to_kubernetes() {
  echo "➤ Deploying to standard Kubernetes..."
  
  # Check if helm_deploy.sh exists and is executable
  if [[ ! -x "./helm_deploy.sh" ]]; then
    echo "Error: Kubernetes deployment script not found or not executable"
    echo "Expected path: ./helm_deploy.sh"
    exit 1
  fi
  
  # Build command arguments
  CMD_ARGS=("--release" "$RELEASE_NAME" "--namespace" "$NAMESPACE" "--timeout" "$TIMEOUT")
  
  if [[ -n "$VALUES_FILE" ]]; then
    CMD_ARGS+=("--values" "$VALUES_FILE")
  fi
  
  # Execute the deployment script
  ./helm_deploy.sh "${CMD_ARGS[@]}"
}

#------------------------------------------------------------------------------
# Deploy to GKE
#------------------------------------------------------------------------------
function deploy_to_gke() {
  echo "➤ Deploying to Google Kubernetes Engine (GKE)..."
  
  # Check if gke_deploy.sh exists and is executable
  if [[ ! -x "./gke_deploy.sh" ]]; then
    echo "Error: GKE deployment script not found or not executable"
    echo "Expected path: ./gke_deploy.sh"
    exit 1
  fi
  
  # Build command arguments
  CMD_ARGS=(
    "--project" "$PROJECT_ID"
    "--cluster" "$CLUSTER_NAME"
    "--zone" "$CLUSTER_ZONE"
    "--release" "$RELEASE_NAME"
    "--namespace" "$NAMESPACE"
    "--timeout" "$TIMEOUT"
  )
  
  if [[ -n "$VALUES_FILE" ]]; then
    CMD_ARGS+=("--values" "$VALUES_FILE")
  fi
  
  if [[ -n "$IMAGE_TAG" ]]; then
    CMD_ARGS+=("--image" "gcr.io/$PROJECT_ID/angular-app:$IMAGE_TAG")
  fi
  
  # Execute the GKE deployment script
  ./gke_deploy.sh "${CMD_ARGS[@]}"
}

#------------------------------------------------------------------------------
# Main execution
#------------------------------------------------------------------------------
function main() {
  print_banner
  parse_args "$@"
  
  # Create TLS certificate if requested
  create_tls_cert
  
  # Deploy to the selected target
  case "$DEPLOY_TARGET" in
    kubernetes)
      deploy_to_kubernetes
      ;;
    gke)
      deploy_to_gke
      ;;
    *)
      echo "Error: Unknown deployment target: $DEPLOY_TARGET"
      exit 1
      ;;
  esac
  
  echo
  echo "===================================================="
  echo "✓ Deployment process completed!"
  echo "===================================================="
}

# Execute main function with all arguments
main "$@"