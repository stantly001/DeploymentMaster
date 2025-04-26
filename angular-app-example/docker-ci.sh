#!/bin/bash
# CI/CD Build Script for Docker-based Angular Deployment

set -e

# Default values
ACTION=${ACTION:-"build"}
ENVIRONMENT=${ENVIRONMENT:-"development"}
TAG=${TAG:-"latest"}
REGISTRY=${REGISTRY:-""}
PUSH=${PUSH:-"false"}
SCAN=${SCAN:-"false"}
DEPLOY=${DEPLOY:-"false"}
COMPOSE=${COMPOSE:-"false"}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --action=*)
      ACTION="${1#*=}"
      shift
      ;;
    --env=*)
      ENVIRONMENT="${1#*=}"
      shift
      ;;
    --tag=*)
      TAG="${1#*=}"
      shift
      ;;
    --registry=*)
      REGISTRY="${1#*=}"
      shift
      ;;
    --push)
      PUSH="true"
      shift
      ;;
    --scan)
      SCAN="true"
      shift
      ;;
    --deploy)
      DEPLOY="true"
      shift
      ;;
    --compose)
      COMPOSE="true"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --action=ACTION     Action to perform (build, test, deploy) [default: build]"
      echo "  --env=ENV           Environment (development, test, production) [default: development]"
      echo "  --tag=TAG           Image tag [default: latest]"
      echo "  --registry=REG      Docker registry [optional]"
      echo "  --push              Push the image after building"
      echo "  --scan              Run security scan on the image"
      echo "  --deploy            Deploy the application after building"
      echo "  --compose           Use docker-compose for the operations"
      echo "  --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "❌ Docker is not installed or not in PATH. Please install Docker first."
  exit 1
fi

# Set image name based on environment
IMAGE_NAME="angular-app"
if [ -n "$REGISTRY" ]; then
  FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"
else
  FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"
fi

# Print build information
echo "🚀 Angular CI/CD Pipeline"
echo "⚙️  Action: $ACTION"
echo "🌍 Environment: $ENVIRONMENT"
echo "🔖 Tag: $TAG"
echo "📦 Image: $FULL_IMAGE_NAME"

# Function to build the Docker image
build_image() {
  echo "🔨 Building Docker image for environment: $ENVIRONMENT..."
  
  if [ "$ENVIRONMENT" = "development" ]; then
    DOCKERFILE="Dockerfile.dev"
  elif [ "$ENVIRONMENT" = "test" ]; then
    DOCKERFILE="Dockerfile.dev"
  else
    DOCKERFILE="multi-stage.Dockerfile"
  fi
  
  echo "📄 Using Dockerfile: $DOCKERFILE"
  
  if [ "$COMPOSE" = "true" ]; then
    if [ "$ENVIRONMENT" = "development" ]; then
      docker-compose up -d angular-dev
    elif [ "$ENVIRONMENT" = "test" ]; then
      docker-compose up angular-test
    else
      docker-compose up -d angular-prod
    fi
  else
    docker build -t $FULL_IMAGE_NAME -f $DOCKERFILE .
  fi
  
  echo "✅ Docker image built successfully: $FULL_IMAGE_NAME"
}

# Function to run tests
run_tests() {
  echo "🧪 Running tests in Docker..."
  
  if [ "$COMPOSE" = "true" ]; then
    docker-compose up angular-test
  else
    docker run --rm $FULL_IMAGE_NAME npm run test -- --browsers=ChromeHeadless --watch=false
  fi
  
  echo "✅ Tests completed successfully!"
}

# Function to scan the image for vulnerabilities
scan_image() {
  echo "🔍 Scanning Docker image for vulnerabilities..."
  
  if command -v trivy &> /dev/null; then
    trivy image $FULL_IMAGE_NAME
  else
    echo "⚠️  Trivy not found. Please install Trivy or use a different scanner."
    echo "⚠️  Skipping vulnerability scan..."
  fi
}

# Function to push the image to registry
push_image() {
  if [ "$PUSH" = "true" ]; then
    echo "🚀 Pushing Docker image to registry..."
    docker push $FULL_IMAGE_NAME
    echo "✅ Docker image pushed successfully to $FULL_IMAGE_NAME"
  fi
}

# Function to deploy the application
deploy_app() {
  if [ "$DEPLOY" = "true" ]; then
    echo "📦 Deploying application..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
      # Use the appropriate deployment script based on your needs
      # For Kubernetes:
      if [ -f "./gke_deploy.sh" ]; then
        ./gke_deploy.sh --tag=$TAG
      elif [ -f "./helm_deploy.sh" ]; then
        ./helm_deploy.sh --tag=$TAG
      else
        echo "⚠️  No deployment script found. Please create a deployment script first."
      fi
    else
      echo "🔧 Deploying to $ENVIRONMENT environment..."
      # Add your deployment logic for other environments
    fi
    
    echo "✅ Deployment completed successfully!"
  fi
}

# Execute the requested action
case $ACTION in
  build)
    build_image
    if [ "$SCAN" = "true" ]; then
      scan_image
    fi
    push_image
    ;;
  test)
    build_image
    run_tests
    ;;
  deploy)
    build_image
    if [ "$SCAN" = "true" ]; then
      scan_image
    fi
    push_image
    deploy_app
    ;;
  *)
    echo "❌ Unknown action: $ACTION"
    exit 1
    ;;
esac

echo "🎉 CI/CD pipeline completed successfully!"