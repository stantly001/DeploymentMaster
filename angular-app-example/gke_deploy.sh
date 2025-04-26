#!/bin/bash
# Google Kubernetes Engine (GKE) Deployment Script for Angular Application
# This script handles the deployment of an Angular application to GKE

set -e

# Default values
PROJECT_ID=${PROJECT_ID:-""}
CLUSTER_NAME=${CLUSTER_NAME:-"angular-cluster"}
CLUSTER_ZONE=${CLUSTER_ZONE:-"us-central1-a"}
CLUSTER_REGION=${CLUSTER_REGION:-"us-central1"}
CLUSTER_SIZE=${CLUSTER_SIZE:-"3"}
MACHINE_TYPE=${MACHINE_TYPE:-"e2-standard-2"}
ENV=${ENV:-"prod"}
NAMESPACE=${NAMESPACE:-"default"}
RELEASE_NAME=${RELEASE_NAME:-"angular-app"}
APP_DOMAIN=${APP_DOMAIN:-"example.com"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
CREATE_CLUSTER=${CREATE_CLUSTER:-"false"}
USE_HELM=${USE_HELM:-"true"}
USE_REGIONAL=${USE_REGIONAL:-"false"}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project=*)
      PROJECT_ID="${1#*=}"
      shift
      ;;
    --cluster=*)
      CLUSTER_NAME="${1#*=}"
      shift
      ;;
    --zone=*)
      CLUSTER_ZONE="${1#*=}"
      shift
      ;;
    --region=*)
      CLUSTER_REGION="${1#*=}"
      shift
      ;;
    --size=*)
      CLUSTER_SIZE="${1#*=}"
      shift
      ;;
    --machine-type=*)
      MACHINE_TYPE="${1#*=}"
      shift
      ;;
    --env=*)
      ENV="${1#*=}"
      shift
      ;;
    --namespace=*)
      NAMESPACE="${1#*=}"
      shift
      ;;
    --release=*)
      RELEASE_NAME="${1#*=}"
      shift
      ;;
    --domain=*)
      APP_DOMAIN="${1#*=}"
      shift
      ;;
    --tag=*)
      IMAGE_TAG="${1#*=}"
      shift
      ;;
    --create-cluster)
      CREATE_CLUSTER="true"
      shift
      ;;
    --no-helm)
      USE_HELM="false"
      shift
      ;;
    --regional)
      USE_REGIONAL="true"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --project=ID            Google Cloud Project ID [required]"
      echo "  --cluster=NAME          GKE cluster name [default: angular-cluster]"
      echo "  --zone=ZONE             GKE cluster zone [default: us-central1-a]"
      echo "  --region=REGION         GKE cluster region for regional clusters [default: us-central1]"
      echo "  --size=SIZE             GKE cluster size (nodes) [default: 3]"
      echo "  --machine-type=TYPE     GKE node machine type [default: e2-standard-2]"
      echo "  --env=ENV               Environment to deploy to (dev, staging, prod) [default: prod]"
      echo "  --namespace=NAMESPACE   Kubernetes namespace to deploy to [default: default]"
      echo "  --release=NAME          Helm release name [default: angular-app]"
      echo "  --domain=DOMAIN         Domain name for the application [default: example.com]"
      echo "  --tag=TAG               Image tag [default: latest]"
      echo "  --create-cluster        Create a new GKE cluster if it doesn't exist"
      echo "  --no-helm               Use kubectl instead of Helm for deployment"
      echo "  --regional              Create a regional cluster instead of zonal"
      echo "  --help                  Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "${PROJECT_ID}" ]; then
  echo "❌ Google Cloud Project ID is required. Use --project=PROJECT_ID"
  exit 1
fi

echo "🚀 Starting GKE deployment for Angular application"
echo "☁️  Google Cloud Project: ${PROJECT_ID}"
echo "🔧 GKE Cluster: ${CLUSTER_NAME}"
if [ "${USE_REGIONAL}" = "true" ]; then
  echo "🌎 Region: ${CLUSTER_REGION}"
else
  echo "🌎 Zone: ${CLUSTER_ZONE}"
fi
echo "⚙️  Environment: ${ENV}"
echo "📦 Kubernetes Namespace: ${NAMESPACE}"
echo "🌐 Domain: ${APP_DOMAIN}"

# Configure gcloud
echo "⚙️  Configuring gcloud..."
gcloud config set project ${PROJECT_ID}

# Check if cluster exists
CLUSTER_EXISTS=$(gcloud container clusters list --filter="name=${CLUSTER_NAME}" --format="value(name)")
if [ -z "$CLUSTER_EXISTS" ] && [ "${CREATE_CLUSTER}" = "true" ]; then
  echo "🔨 Creating GKE cluster ${CLUSTER_NAME}..."
  if [ "${USE_REGIONAL}" = "true" ]; then
    gcloud container clusters create ${CLUSTER_NAME} \
      --region ${CLUSTER_REGION} \
      --num-nodes ${CLUSTER_SIZE} \
      --machine-type ${MACHINE_TYPE} \
      --release-channel regular \
      --enable-autoscaling \
      --min-nodes 1 \
      --max-nodes 5
  else
    gcloud container clusters create ${CLUSTER_NAME} \
      --zone ${CLUSTER_ZONE} \
      --num-nodes ${CLUSTER_SIZE} \
      --machine-type ${MACHINE_TYPE} \
      --release-channel regular \
      --enable-autoscaling \
      --min-nodes 1 \
      --max-nodes 5
  fi
elif [ -z "$CLUSTER_EXISTS" ]; then
  echo "❌ Cluster ${CLUSTER_NAME} doesn't exist. Use --create-cluster to create it."
  exit 1
else
  echo "✅ Using existing cluster ${CLUSTER_NAME}"
fi

# Configure kubectl to use the cluster
echo "⚙️  Configuring kubectl..."
if [ "${USE_REGIONAL}" = "true" ]; then
  gcloud container clusters get-credentials ${CLUSTER_NAME} --region ${CLUSTER_REGION} --project ${PROJECT_ID}
else
  gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT_ID}
fi

# Create namespace if it doesn't exist
if ! kubectl get namespace ${NAMESPACE} > /dev/null 2>&1; then
  echo "📝 Creating namespace ${NAMESPACE}..."
  kubectl create namespace ${NAMESPACE}
fi

# Build container image
echo "🔨 Building and pushing Docker image..."
IMAGE_NAME="gcr.io/${PROJECT_ID}/angular-app:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME} -f angular-app-example/Dockerfile angular-app-example/
gcloud auth configure-docker -q
docker push ${IMAGE_NAME}

# Deploy application
if [ "${USE_HELM}" = "true" ]; then
  echo "☸️  Deploying with Helm..."
  
  # Set values overrides
  SET_VALUES="--set ingress.hosts[0].host=${APP_DOMAIN}"
  SET_VALUES="${SET_VALUES} --set ingress.tls[0].hosts[0]=${APP_DOMAIN}"
  SET_VALUES="${SET_VALUES} --set container.image.repository=gcr.io/${PROJECT_ID}/angular-app"
  SET_VALUES="${SET_VALUES} --set container.image.tag=${IMAGE_TAG}"
  
  # Check if Helm release exists
  if helm status ${RELEASE_NAME} -n ${NAMESPACE} > /dev/null 2>&1; then
    echo "🔄 Upgrading existing release ${RELEASE_NAME}..."
    helm upgrade ${RELEASE_NAME} angular-app-example/helm-chart \
      -n ${NAMESPACE} \
      ${SET_VALUES}
  else
    echo "📦 Installing new release ${RELEASE_NAME}..."
    helm install ${RELEASE_NAME} angular-app-example/helm-chart \
      -n ${NAMESPACE} \
      ${SET_VALUES}
  fi
  
  echo "⏳ Waiting for deployment to be ready..."
  kubectl -n ${NAMESPACE} rollout status deployment/${RELEASE_NAME}
else
  echo "📦 Deploying with kubectl..."
  
  # Process and apply Kubernetes manifests
  echo "📝 Processing Kubernetes manifests..."
  mkdir -p angular-app-example/k8s/generated
  for file in angular-app-example/k8s/*.yaml; do
    BASENAME=$(basename $file)
    cat $file | \
      sed "s|\${DOCKER_REGISTRY}|gcr.io/${PROJECT_ID}|g" | \
      sed "s|\${IMAGE_TAG}|${IMAGE_TAG}|g" | \
      sed "s|\${APP_DOMAIN}|${APP_DOMAIN}|g" > angular-app-example/k8s/generated/$BASENAME
  done
  
  echo "🚀 Applying Kubernetes manifests..."
  kubectl apply -f angular-app-example/k8s/generated/ -n ${NAMESPACE}
  
  echo "⏳ Waiting for deployment to be ready..."
  kubectl -n ${NAMESPACE} rollout status deployment/angular-app
fi

echo "✅ Deployment to GKE completed successfully!"

# Get ingress information if available
if kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} > /dev/null 2>&1; then
  INGRESS_HOST=$(kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} -o jsonpath='{.spec.rules[0].host}')
  echo "🌐 Application will be available at https://${INGRESS_HOST} once DNS is configured"
  
  # Get load balancer IP
  if [[ $(kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ]]; then
    LB_IP=$(kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo "🌐 Load balancer IP: ${LB_IP}"
    echo "ℹ️  Configure your DNS to point ${INGRESS_HOST} to ${LB_IP}"
  fi
fi

echo "🎉 GKE deployment completed!"