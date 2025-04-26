#!/bin/bash
# Helm Chart Deployment Script for Angular Application
# This script handles the deployment of an Angular application using Helm

set -e

# Default values
ENV=${ENV:-"prod"}
NAMESPACE=${NAMESPACE:-"default"}
RELEASE_NAME=${RELEASE_NAME:-"angular-app"}
CHART_PATH="./helm-chart"
APP_DOMAIN=${APP_DOMAIN:-"example.com"}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-""}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
VALUES_FILE="./helm-chart/values.yaml"
DRY_RUN=${DRY_RUN:-"false"}
TIMEOUT=${TIMEOUT:-"5m"}
INSTALL_ARGS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
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
    --registry=*)
      DOCKER_REGISTRY="${1#*=}"
      shift
      ;;
    --tag=*)
      IMAGE_TAG="${1#*=}"
      shift
      ;;
    --values=*)
      VALUES_FILE="${1#*=}"
      shift
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    --timeout=*)
      TIMEOUT="${1#*=}"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --env=ENV               Environment to deploy to (dev, staging, prod) [default: prod]"
      echo "  --namespace=NAMESPACE   Kubernetes namespace to deploy to [default: default]"
      echo "  --release=NAME          Helm release name [default: angular-app]"
      echo "  --domain=DOMAIN         Domain name for the application [default: example.com]"
      echo "  --registry=REG          Docker registry [optional]"
      echo "  --tag=TAG               Image tag [default: latest]"
      echo "  --values=FILE           Custom values file [default: ./helm-chart/values.yaml]"
      echo "  --dry-run               Perform a dry run of the installation"
      echo "  --timeout=DURATION      Set timeout for Helm operations [default: 5m]"
      echo "  --help                  Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "🚀 Starting Helm deployment for Angular application"
echo "⚙️  Environment: ${ENV}"
echo "🔧 Kubernetes Namespace: ${NAMESPACE}"
echo "📦 Helm Release: ${RELEASE_NAME}"
echo "🌐 Domain: ${APP_DOMAIN}"

# Create namespace if it doesn't exist
if ! kubectl get namespace ${NAMESPACE} > /dev/null 2>&1; then
  echo "📝 Creating namespace ${NAMESPACE}..."
  kubectl create namespace ${NAMESPACE}
fi

# Set values overrides
SET_VALUES="--set ingress.hosts[0].host=${APP_DOMAIN}"
SET_VALUES="${SET_VALUES} --set ingress.tls[0].hosts[0]=${APP_DOMAIN}"

if [ -n "${DOCKER_REGISTRY}" ]; then
  SET_VALUES="${SET_VALUES} --set container.image.repository=${DOCKER_REGISTRY}/angular-app"
fi

if [ -n "${IMAGE_TAG}" ]; then
  SET_VALUES="${SET_VALUES} --set container.image.tag=${IMAGE_TAG}"
fi

# Set the dry run flag if needed
if [ "${DRY_RUN}" = "true" ]; then
  INSTALL_ARGS="${INSTALL_ARGS} --dry-run"
fi

# Deploy with Helm
echo "☸️  Deploying with Helm..."
if helm status ${RELEASE_NAME} -n ${NAMESPACE} > /dev/null 2>&1; then
  echo "🔄 Upgrading existing release ${RELEASE_NAME}..."
  helm upgrade ${RELEASE_NAME} ${CHART_PATH} \
    -n ${NAMESPACE} \
    -f ${VALUES_FILE} \
    ${SET_VALUES} \
    --timeout ${TIMEOUT} \
    ${INSTALL_ARGS}
else
  echo "📦 Installing new release ${RELEASE_NAME}..."
  helm install ${RELEASE_NAME} ${CHART_PATH} \
    -n ${NAMESPACE} \
    -f ${VALUES_FILE} \
    ${SET_VALUES} \
    --timeout ${TIMEOUT} \
    ${INSTALL_ARGS}
fi

if [ "${DRY_RUN}" = "false" ]; then
  echo "⏳ Waiting for deployment to be ready..."
  kubectl -n ${NAMESPACE} rollout status deployment/${RELEASE_NAME}
  
  echo "ℹ️  Deployed resources:"
  kubectl -n ${NAMESPACE} get deployments,services,ingress,configmaps,secrets -l app=${RELEASE_NAME}
  
  echo "✅ Helm deployment completed successfully!"
  
  if kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} > /dev/null 2>&1; then
    INGRESS_HOST=$(kubectl -n ${NAMESPACE} get ingress ${RELEASE_NAME} -o jsonpath='{.spec.rules[0].host}')
    echo "🌐 Application is available at https://${INGRESS_HOST}"
  fi
else
  echo "✅ Dry run completed successfully!"
fi