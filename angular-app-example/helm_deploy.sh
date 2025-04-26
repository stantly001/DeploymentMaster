#!/bin/bash
#==============================================================================
# Angular Application Helm Deployment Script
#
# This script deploys an Angular application to Kubernetes using Helm,
# with optional Istio service mesh integration.
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail # Exit on error and undefined variables

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
RELEASE_NAME="angular-app"
NAMESPACE="angular-app"
HELM_CHART_PATH="./helm-chart"
VALUES_FILE="$HELM_CHART_PATH/values.yaml"
TIMEOUT="5m"
CUSTOM_VALUES_FILE=""
TEMP_VALUES_FILE="/tmp/values-modified.yaml"

#------------------------------------------------------------------------------
# Display Header
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "     Angular Application Helm Deployment Tool"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Parse command-line arguments
#------------------------------------------------------------------------------
function parse_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
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
        echo "Usage: ./helm_deploy.sh [options]"
        echo ""
        echo "Options:"
        echo "  --release NAME       Set the Helm release name (default: angular-app)"
        echo "  --namespace NS       Set the Kubernetes namespace (default: angular-app)"
        echo "  --values FILE        Specify custom values file"
        echo "  --timeout DURATION   Set deployment timeout (default: 5m)"
        echo "  --help               Display this help message"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./helm_deploy.sh --help for usage information"
        exit 1
        ;;
    esac
  done

  # Log the configuration
  echo "Configuration:"
  echo "  Release name:  $RELEASE_NAME"
  echo "  Namespace:     $NAMESPACE"
  echo "  Helm chart:    $HELM_CHART_PATH"
  echo "  Timeout:       $TIMEOUT"
  if [ -n "$CUSTOM_VALUES_FILE" ]; then
    echo "  Values file:   $CUSTOM_VALUES_FILE"
  fi
  echo
}

#------------------------------------------------------------------------------
# Check for Istio and prepare namespace
#------------------------------------------------------------------------------
function setup_namespace() {
  echo "➤ Ensuring namespace '$NAMESPACE' exists..."
  kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

  # Check if Istio is installed
  if kubectl get crd gateways.networking.istio.io &> /dev/null; then
    echo "✓ Istio service mesh detected"
    ISTIO_ENABLED=true
    
    # Enable Istio sidecar injection
    echo "➤ Enabling Istio sidecar injection for namespace '$NAMESPACE'..."
    kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
  else
    echo "! Istio service mesh not detected"
    echo "  - The deployment will continue without Istio integration"
    echo "  - To enable Istio features, install Istio first"
    ISTIO_ENABLED=false
    
    # Prepare values file with Istio disabled
    if [ "$ISTIO_ENABLED" = false ]; then
      # Create a temporary values file with Istio disabled
      echo "➤ Creating values file with Istio disabled..."
      if [ -n "$CUSTOM_VALUES_FILE" ]; then
        cp "$CUSTOM_VALUES_FILE" "$TEMP_VALUES_FILE"
      else
        cp "$VALUES_FILE" "$TEMP_VALUES_FILE"
      fi
      yq e '.istio.enabled = false' -i "$TEMP_VALUES_FILE"
      CUSTOM_VALUES_FILE="$TEMP_VALUES_FILE"
    fi
  fi
}

#------------------------------------------------------------------------------
# Deploy the Helm chart
#------------------------------------------------------------------------------
function deploy_chart() {
  echo "➤ Deploying Helm chart '$RELEASE_NAME'..."
  
  # Prepare the Helm command
  HELM_CMD=(helm upgrade --install "$RELEASE_NAME" "$HELM_CHART_PATH" \
            --namespace "$NAMESPACE" \
            --timeout "$TIMEOUT" \
            --create-namespace \
            --wait)
  
  # Add custom values file if specified
  if [ -n "$CUSTOM_VALUES_FILE" ]; then
    HELM_CMD+=(--values "$CUSTOM_VALUES_FILE")
  fi
  
  # Execute the Helm command
  "${HELM_CMD[@]}"
  
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
    
    # Check for any Istio-specific issues
    echo
    echo "➤ Validating Istio configuration..."
    if command -v istioctl &> /dev/null; then
      istioctl analyze -n "$NAMESPACE" || true
    else
      echo "! istioctl not found. Skipping Istio validation."
    fi
  fi
  
  # Display application URLs
  echo
  echo "➤ Application access:"
  if [ "$ISTIO_ENABLED" = true ]; then
    echo "The application should be accessible through the Istio Gateway."
    echo "Check the Istio Ingress Gateway service for the external IP:"
    kubectl get svc -n istio-system istio-ingressgateway
  else
    echo "Service type: $(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.type}')"
    if kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.type}' | grep -q "LoadBalancer"; then
      EXTERNAL_IP=$(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      if [ -n "$EXTERNAL_IP" ]; then
        SERVICE_PORT=$(kubectl get svc -n "$NAMESPACE" "$RELEASE_NAME" -o jsonpath='{.spec.ports[0].port}')
        echo "Application URL: http://$EXTERNAL_IP:$SERVICE_PORT"
      else
        echo "External IP is not yet available. Check again later with:"
        echo "  kubectl get svc -n $NAMESPACE $RELEASE_NAME"
      fi
    else
      echo "The service is not exposed externally. Use port-forwarding to access it:"
      echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME 8080:80"
      echo "Then access the application at: http://localhost:8080"
    fi
  fi
}

#------------------------------------------------------------------------------
# Main flow
#------------------------------------------------------------------------------
function main() {
  print_banner
  parse_args "$@"
  setup_namespace
  deploy_chart
  show_deployment_info
  
  # Clean up
  if [ -f "$TEMP_VALUES_FILE" ]; then
    rm "$TEMP_VALUES_FILE"
  fi
  
  echo
  echo "===================================================="
  echo "✓ Deployment completed successfully!"
  echo "===================================================="
}

# Execute main function with all arguments
main "$@"