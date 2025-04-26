#!/bin/bash
# Angular Application Deployment Script
# This script handles the deployment of an Angular application to various environments
# using different deployment methods (Nginx, Docker, Kubernetes)

set -e

# Default values
ENV=${ENV:-"prod"}
DEPLOYMENT_TYPE=${DEPLOYMENT_TYPE:-"nginx"}
APP_DOMAIN=${APP_DOMAIN:-"example.com"}
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)
IMAGE_TAG="v-${BUILD_NUMBER}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env=*)
      ENV="${1#*=}"
      shift
      ;;
    --type=*)
      DEPLOYMENT_TYPE="${1#*=}"
      shift
      ;;
    --domain=*)
      APP_DOMAIN="${1#*=}"
      shift
      ;;
    --docker-registry=*)
      DOCKER_REGISTRY="${1#*=}"
      shift
      ;;
    --image-tag=*)
      IMAGE_TAG="${1#*=}"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --env=ENV               Environment to deploy to (dev, staging, prod) [default: prod]"
      echo "  --type=TYPE             Deployment type (nginx, docker, kubernetes) [default: nginx]"
      echo "  --domain=DOMAIN         Domain name for the application [default: example.com]"
      echo "  --docker-registry=REG   Docker registry to use [required for docker/kubernetes deployment]"
      echo "  --image-tag=TAG         Image tag to use [default: v-YYYYMMDDHHMMSS]"
      echo "  --help                  Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🚀 Starting Angular application deployment"
echo "⚙️  Environment: ${ENV}"
echo "🔧 Deployment type: ${DEPLOYMENT_TYPE}"
echo "🌐 Domain: ${APP_DOMAIN}"
echo "📦 Build number: ${BUILD_NUMBER}"

# Build the application
echo "📦 Building the application for ${ENV} environment..."
npm run build:${ENV}

if [ ! -d "dist" ]; then
  echo "❌ Build failed: 'dist' directory not found"
  exit 1
fi

# Deploy based on deployment type
case ${DEPLOYMENT_TYPE} in
  nginx)
    echo "🔧 Deploying with Nginx..."
    NGINX_CONF="nginx-${ENV}.conf"
    
    if [ ! -f "${NGINX_CONF}" ]; then
      echo "⚠️ Nginx configuration file '${NGINX_CONF}' not found. Using default configuration."
      NGINX_CONF="nginx.conf"
    fi
    
    # Generate Nginx configuration
    echo "📝 Generating Nginx configuration..."
    node scripts/nginx-config-generator.js --env=${ENV} --domain=${APP_DOMAIN} --output=./nginx-${ENV}-generated.conf
    
    # Copy build artifacts to web server directory
    echo "📂 Copying build artifacts to web server directory..."
    DEPLOY_DIR="/var/www/html/${APP_DOMAIN}"
    sudo mkdir -p ${DEPLOY_DIR}
    sudo cp -r dist/angular-app-example/* ${DEPLOY_DIR}/
    
    # Copy and load Nginx configuration
    echo "📝 Installing Nginx configuration..."
    sudo cp ./nginx-${ENV}-generated.conf /etc/nginx/sites-available/${APP_DOMAIN}.conf
    sudo ln -sf /etc/nginx/sites-available/${APP_DOMAIN}.conf /etc/nginx/sites-enabled/
    
    # Test Nginx configuration and reload
    echo "🔍 Testing Nginx configuration..."
    sudo nginx -t
    if [ $? -eq 0 ]; then
      echo "🔄 Reloading Nginx..."
      sudo systemctl reload nginx
      echo "✅ Deployment completed successfully!"
    else
      echo "❌ Nginx configuration test failed. Deployment aborted."
      exit 1
    fi
    ;;
    
  docker)
    echo "🐳 Deploying with Docker..."
    
    if [ -z "${DOCKER_REGISTRY}" ]; then
      echo "❌ Docker registry not specified. Use --docker-registry=REGISTRY"
      exit 1
    fi
    
    # Build Docker image
    echo "🔨 Building Docker image..."
    docker build -t ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG} \
      --build-arg ENV=${ENV} \
      --build-arg APP_DOMAIN=${APP_DOMAIN} .
      
    # Push Docker image
    echo "📤 Pushing Docker image to registry..."
    docker push ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG}
    
    # Deploy to Docker host
    echo "🚀 Deploying to Docker host..."
    ssh ${DEPLOY_USER}@${DEPLOY_HOST} "
      docker pull ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG}
      docker stop angular-app || true
      docker rm angular-app || true
      docker run -d --name angular-app \
        -p 80:80 -p 443:443 \
        -v /etc/letsencrypt:/etc/nginx/ssl \
        --restart always \
        ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG}
      docker image prune -af --filter 'until=24h'
    "
    echo "✅ Deployment completed successfully!"
    ;;
    
  kubernetes)
    echo "☸️ Deploying to Kubernetes..."
    
    if [ -z "${DOCKER_REGISTRY}" ]; then
      echo "❌ Docker registry not specified. Use --docker-registry=REGISTRY"
      exit 1
    fi
    
    # Build and push Docker image
    echo "🔨 Building Docker image..."
    docker build -t ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG} \
      --build-arg ENV=${ENV} \
      --build-arg APP_DOMAIN=${APP_DOMAIN} .
      
    echo "📤 Pushing Docker image to registry..."
    docker push ${DOCKER_REGISTRY}/angular-app:${IMAGE_TAG}
    
    # Process Kubernetes manifests
    echo "📝 Processing Kubernetes manifests..."
    mkdir -p k8s/generated
    for file in k8s/*.yaml; do
      BASENAME=$(basename $file)
      cat $file | \
        sed "s|\${DOCKER_REGISTRY}|${DOCKER_REGISTRY}|g" | \
        sed "s|\${IMAGE_TAG}|${IMAGE_TAG}|g" | \
        sed "s|\${APP_DOMAIN}|${APP_DOMAIN}|g" > k8s/generated/$BASENAME
    done
    
    # Apply Kubernetes manifests
    echo "🚀 Applying Kubernetes manifests..."
    kubectl apply -f k8s/generated/
    
    # Wait for deployment to complete
    echo "⏳ Waiting for deployment to complete..."
    kubectl rollout status deployment/angular-app
    
    echo "✅ Deployment completed successfully!"
    ;;
    
  *)
    echo "❌ Unknown deployment type: ${DEPLOYMENT_TYPE}"
    exit 1
    ;;
esac

echo "🎉 Angular application deployed to ${ENV} environment using ${DEPLOYMENT_TYPE} method"