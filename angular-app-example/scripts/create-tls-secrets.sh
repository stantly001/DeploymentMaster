#!/bin/bash
#==============================================================================
# Create TLS Secrets for Istio Gateway
#
# This script creates TLS secrets used by Istio Gateway for secure HTTPS access.
# It can create self-signed certificates for development or use existing 
# certificates for production.
#
# Author: Your Name
# Date: April 2025
#==============================================================================

set -eo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
NAMESPACE="angular-app"
SECRET_NAME="angular-tls-cert"
DEFAULT_DOMAIN="example.com"
CERT_DIR="/tmp/certs"
CERT_VALIDITY_DAYS=365
COUNTRY="US"
STATE="CA"
LOCALITY="San Francisco"
ORGANIZATION="Example Inc."

#------------------------------------------------------------------------------
# Banner
#------------------------------------------------------------------------------
function print_banner() {
  echo "===================================================="
  echo "     Create TLS Secrets for Istio Gateway"
  echo "===================================================="
  echo
}

#------------------------------------------------------------------------------
# Parse command-line arguments
#------------------------------------------------------------------------------
function parse_args() {
  DOMAIN="$DEFAULT_DOMAIN"
  MODE="self-signed"
  CERT_PATH=""
  KEY_PATH=""
  
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --domain)
        DOMAIN="$2"
        shift
        shift
        ;;
      --namespace)
        NAMESPACE="$2"
        shift
        shift
        ;;
      --secret-name)
        SECRET_NAME="$2"
        shift
        shift
        ;;
      --existing-cert)
        MODE="existing"
        CERT_PATH="$2"
        shift
        shift
        ;;
      --existing-key)
        MODE="existing"
        KEY_PATH="$2"
        shift
        shift
        ;;
      --help)
        echo "Usage: ./create-tls-secrets.sh [options]"
        echo ""
        echo "Options:"
        echo "  --domain DOMAIN         Domain name for certificate (default: example.com)"
        echo "  --namespace NAMESPACE   Kubernetes namespace (default: angular-app)"
        echo "  --secret-name NAME      Name of the Kubernetes secret (default: angular-tls-cert)"
        echo "  --existing-cert PATH    Path to existing certificate file (PEM format)"
        echo "  --existing-key PATH     Path to existing private key file (PEM format)"
        echo "  --help                  Display this help message"
        echo ""
        echo "Examples:"
        echo "  # Create self-signed certificate for example.com"
        echo "  ./create-tls-secrets.sh --domain example.com"
        echo ""
        echo "  # Use existing certificate files"
        echo "  ./create-tls-secrets.sh --existing-cert ./cert.pem --existing-key ./key.pem"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run ./create-tls-secrets.sh --help for usage information"
        exit 1
        ;;
    esac
  done
  
  # Validate arguments
  if [[ "$MODE" == "existing" && ( -z "$CERT_PATH" || -z "$KEY_PATH" ) ]]; then
    echo "Error: When using existing certificates, both --existing-cert and --existing-key are required"
    exit 1
  fi

  # Log the configuration
  echo "Configuration:"
  echo "  Domain:       $DOMAIN"
  echo "  Namespace:    $NAMESPACE"
  echo "  Secret name:  $SECRET_NAME"
  if [[ "$MODE" == "self-signed" ]]; then
    echo "  Mode:         Creating self-signed certificate"
  else
    echo "  Mode:         Using existing certificate files"
    echo "  Certificate:  $CERT_PATH"
    echo "  Private key:  $KEY_PATH"
  fi
  echo
}

#------------------------------------------------------------------------------
# Create self-signed certificate
#------------------------------------------------------------------------------
function create_self_signed_cert() {
  echo "➤ Creating self-signed certificate for $DOMAIN..."
  
  # Create temporary directory for certificates
  mkdir -p "$CERT_DIR"
  
  # Create config file for OpenSSL
  cat > "$CERT_DIR/openssl.cnf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = $COUNTRY
ST = $STATE
L = $LOCALITY
O = $ORGANIZATION
CN = $DOMAIN

[v3_req]
subjectAltName = @alt_names
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = www.$DOMAIN
EOF

  # Generate private key and certificate
  openssl req -x509 -nodes -days $CERT_VALIDITY_DAYS \
    -newkey rsa:2048 -keyout "$CERT_DIR/tls.key" -out "$CERT_DIR/tls.crt" \
    -config "$CERT_DIR/openssl.cnf"
  
  echo "✓ Self-signed certificate created successfully"
  
  # Set paths for the create_secret function
  CERT_PATH="$CERT_DIR/tls.crt"
  KEY_PATH="$CERT_DIR/tls.key"
}

#------------------------------------------------------------------------------
# Create Kubernetes TLS secret
#------------------------------------------------------------------------------
function create_secret() {
  echo "➤ Creating Kubernetes secret '$SECRET_NAME' in namespace '$NAMESPACE'..."
  
  # Ensure namespace exists
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
  
  # Create or update TLS secret
  kubectl create secret tls "$SECRET_NAME" \
    --cert="$CERT_PATH" --key="$KEY_PATH" \
    --namespace="$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -
  
  echo "✓ Secret created successfully"
  
  # Verify the secret exists
  if kubectl get secret "$SECRET_NAME" -n "$NAMESPACE" > /dev/null; then
    echo "✓ Verified: Secret '$SECRET_NAME' exists in namespace '$NAMESPACE'"
  else
    echo "✗ Error: Secret creation failed"
    exit 1
  fi
}

#------------------------------------------------------------------------------
# Clean up temporary files
#------------------------------------------------------------------------------
function cleanup() {
  if [[ "$MODE" == "self-signed" && -d "$CERT_DIR" ]]; then
    echo "➤ Cleaning up temporary certificate files..."
    rm -rf "$CERT_DIR"
  fi
}

#------------------------------------------------------------------------------
# Main execution
#------------------------------------------------------------------------------
function main() {
  print_banner
  parse_args "$@"
  
  # Create certificates if needed
  if [[ "$MODE" == "self-signed" ]]; then
    create_self_signed_cert
  fi
  
  # Create the secret
  create_secret
  
  # Show information about using the secret
  echo
  echo "The TLS secret is now ready to use with Istio Gateway."
  echo "Make sure your Helm values.yaml file has the following settings:"
  echo
  echo "istio:"
  echo "  enabled: true"
  echo "  gateway:"
  echo "    tls:"
  echo "      enabled: true"
  echo "      mode: SIMPLE"
  echo "      credentialName: $SECRET_NAME"
  echo
  
  # Final cleanup
  cleanup
  
  echo "===================================================="
  echo "✓ TLS Secret Creation Complete!"
  echo "===================================================="
}

# Execute main function with all arguments
main "$@"