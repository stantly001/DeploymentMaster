#!/bin/bash
# Automated Docker Build Script for Angular Application
# This script automates the build and push of Docker images for the Angular application

set -e

# Default values
IMAGE_NAME=${IMAGE_NAME:-"angular-app"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-""}
DOCKERFILE_PATH="./Dockerfile"
BUILD_CONTEXT="."
PUSH=${PUSH:-"false"}
BUILD_ARGS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --image=*)
      IMAGE_NAME="${1#*=}"
      shift
      ;;
    --tag=*)
      IMAGE_TAG="${1#*=}"
      shift
      ;;
    --registry=*)
      DOCKER_REGISTRY="${1#*=}"
      shift
      ;;
    --dockerfile=*)
      DOCKERFILE_PATH="${1#*=}"
      shift
      ;;
    --context=*)
      BUILD_CONTEXT="${1#*=}"
      shift
      ;;
    --build-arg=*)
      BUILD_ARGS="$BUILD_ARGS --build-arg ${1#*=}"
      shift
      ;;
    --push)
      PUSH="true"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --image=NAME           Docker image name [default: angular-app]"
      echo "  --tag=TAG              Image tag [default: latest]"
      echo "  --registry=REG         Docker registry [optional]"
      echo "  --dockerfile=PATH      Path to Dockerfile [default: ./Dockerfile]"
      echo "  --context=PATH         Build context path [default: .]"
      echo "  --build-arg=ARG=VAL    Build argument to pass to Docker build"
      echo "  --push                 Push the image after building"
      echo "  --help                 Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Set the full image name with registry if provided
if [ -n "$DOCKER_REGISTRY" ]; then
  FULL_IMAGE_NAME="$DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
else
  FULL_IMAGE_NAME="$IMAGE_NAME:$IMAGE_TAG"
fi

echo "🔨 Starting Docker build process for Angular application"
echo "📦 Image: $FULL_IMAGE_NAME"
echo "📄 Dockerfile: $DOCKERFILE_PATH"
echo "📁 Build Context: $BUILD_CONTEXT"

# Build the Docker image
echo "🔧 Building Docker image..."
docker build -t $FULL_IMAGE_NAME -f $DOCKERFILE_PATH $BUILD_CONTEXT $BUILD_ARGS

echo "✅ Docker image built successfully: $FULL_IMAGE_NAME"

# Push the image if requested
if [ "$PUSH" = "true" ]; then
  echo "🚀 Pushing Docker image to registry..."
  docker push $FULL_IMAGE_NAME
  echo "✅ Docker image pushed successfully to $FULL_IMAGE_NAME"
fi

# Create a Docker image manifest summary
echo "📋 Docker Image Summary:"
echo "-----------------------------------"
echo "Image Name: $FULL_IMAGE_NAME"
echo "Size: $(docker images $FULL_IMAGE_NAME --format "{{.Size}}")"
echo "Created: $(docker images $FULL_IMAGE_NAME --format "{{.CreatedAt}}")"
echo "-----------------------------------"

echo "🎉 Docker build process completed successfully!"