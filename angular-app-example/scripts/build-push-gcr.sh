#!/bin/bash
#==============================================================================
# Build and Push Docker Image to Google Container Registry
#
# This script builds the Angular application using the Dockerfile and pushes
# the resulting image to Google Container Registry (GCR).
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
PROJECT_ID="" # GCP project ID
IMAGE_NAME="angular-app"
IMAGE_TAG="latest"
DOCKERFILE_PATH="./Dockerfile"

#------------------------------------------------------------------------------
# Display header banner
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "     Build and Push to Google Container Registry"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Display help message
#------------------------------------------------------------------------------
function show_help() {
  echo "Usage: ./build-push-gcr.sh [options]"
  echo ""
  echo "Options:"
  echo "  --project PROJECT_ID    Google Cloud project ID (required)"
  echo "  --tag TAG              Image tag (default: latest)"
  echo "  --dockerfile PATH      Path to Dockerfile (default: ./Dockerfile)"
  echo "  --help                 Display this help message"
  echo ""
  echo "Examples:"
  echo "  # Build and push with default tag"
  echo "  ./build-push-gcr.sh --project my-gcp-project"
  echo ""
  echo "  # Build and push with specific tag"
  echo "  ./build-push-gcr.sh --project my-gcp-project --tag v1.2.3"
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
      --tag)
        IMAGE_TAG="$2"
        shift
        shift
        ;;
      --dockerfile)
        DOCKERFILE_PATH="$2"
        shift
        shift
        ;;
      --help)
        show_help
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./build-push-gcr.sh --help for usage information"
        exit 1
        ;;
    esac
  done

  # Validate required parameters
  if [ -z "$PROJECT_ID" ]; then
    echo "Error: --project PROJECT_ID is required"
    echo "Run ./build-push-gcr.sh --help for usage information"
    exit 1
  fi

  # Construct the full image name
  GCR_IMAGE="gcr.io/$PROJECT_ID/$IMAGE_NAME:$IMAGE_TAG"

  # Log the configuration
  echo "Configuration:"
  echo "  GCP Project:   $PROJECT_ID"
  echo "  Image:         $GCR_IMAGE"
  echo "  Dockerfile:    $DOCKERFILE_PATH"
  echo
}

#------------------------------------------------------------------------------
# Configure Google Cloud
#------------------------------------------------------------------------------
function setup_gcloud() {
  echo "➤ Configuring gcloud to use project $PROJECT_ID..."
  gcloud config set project "$PROJECT_ID"
  
  echo "➤ Authenticating Docker to GCR..."
  gcloud auth configure-docker -q
  
  echo "✓ GCP configuration complete"
}

#------------------------------------------------------------------------------
# Build Docker image
#------------------------------------------------------------------------------
function build_image() {
  echo "➤ Building Docker image..."
  
  docker build -t "$GCR_IMAGE" -f "$DOCKERFILE_PATH" .
  
  echo "✓ Docker image built successfully"
}

#------------------------------------------------------------------------------
# Push image to GCR
#------------------------------------------------------------------------------
function push_to_gcr() {
  echo "➤ Pushing image to Google Container Registry..."
  
  docker push "$GCR_IMAGE"
  
  echo "✓ Image pushed to GCR successfully: $GCR_IMAGE"
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
  
  echo
  echo "===================================================="
  echo "✓ Build and push completed successfully!"
  echo "===================================================="
  echo
  echo "To deploy this image to GKE, run:"
  echo "./deploy.sh --target gke --project $PROJECT_ID --image-tag $IMAGE_TAG"
}

# Execute main function with all arguments
main "$@"