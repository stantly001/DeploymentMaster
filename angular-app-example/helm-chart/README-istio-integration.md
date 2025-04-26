# Istio Service Mesh Integration Guide

This document explains how to leverage Istio service mesh capabilities with the Angular application deployment.

## What is Istio?

Istio is an open-source service mesh that provides a way to control how microservices share data with one another. It includes features for:

- **Traffic Management**: Intelligent routing and control
- **Security**: Automatic mTLS, policy enforcement
- **Observability**: Metrics, logs, and traces
- **Platform Support**: Works on Kubernetes, VMs, and more

## Prerequisites

- Kubernetes cluster with Istio installed (1.8+)
- Helm 3.2+
- `kubectl` configured to communicate with your cluster
- `istioctl` (optional, but recommended)

## Installation

### 1. Install Istio on your cluster

If Istio is not already installed:

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | sh -

# Add istioctl to your path
export PATH=$PWD/istio-1.17.1/bin:$PATH

# Install Istio with demo profile
istioctl install --set profile=demo -y
```

### 2. Deploy the Angular application

```bash
# Deploy with Istio integration enabled
./deploy.sh --target kubernetes --tls --domain example.com
```

## Configuration Options

The helm chart `values.yaml` file contains comprehensive Istio configuration options:

```yaml
istio:
  enabled: true                         # Master toggle for Istio features
  
  # Gateway configuration
  gateway:
    hosts:                              # Domains for the application
      - "example.com"
      - "www.example.com"
    httpsRedirect: true                 # Redirect HTTP to HTTPS
    tls:
      enabled: true                     # Enable TLS
      mode: SIMPLE                      # TLS mode (SIMPLE, MUTUAL, PASSTHROUGH)
      credentialName: angular-tls-cert  # K8s secret with TLS cert
  
  # Traffic Management
  trafficManagement:
    # Canary deployments
    canary:
      enabled: true                     # Enable header-based routing
      header: "x-canary"                # Header to check
      version: "v2"                     # Canary version to route to
    
    # Traffic splitting
    trafficShifting:
      enabled: true                     # Enable weighted traffic routing
      stableVersion: "v1"               # Current version
      stableWeight: 90                  # % of traffic to stable
      canaryVersion: "v2"               # New version
      canaryWeight: 10                  # % of traffic to canary
    
    # Circuit breaker
    circuitBreaker:
      enabled: true                     # Enable circuit breaker
      # ...detailed connection settings...
    
    # Fault injection for testing
    faultInjection:
      enabled: true                     # Enable fault injection
      # ...fault configuration...
    
    # Request timeouts
    timeout: "10s"                      # Global request timeout
    
    # Retry policy
    retries:
      attempts: 3                       # Max retry attempts
      perTryTimeout: "2s"               # Timeout per retry
      retryOn: "gateway-error,connect-failure,refused-stream"
  
  # Security
  security:
    # Authorization policies
    authorization:
      enabled: true                     # Enable authorization
      # ...rules configuration...
    
    # mTLS settings
    peerAuthentication:
      enabled: true                     # Enable mTLS
      mtlsMode: STRICT                  # mTLS mode
      # ...port-level settings...
  
  # Observability
  telemetry:
    enabled: true                       # Enable observability
    # ...metrics, tracing, logging configuration...
```

## Key Features

### 1. Canary Deployments

Test new versions by routing specific requests to the new version:

```bash
# Test the canary version
curl -H "x-canary: true" https://example.com/
```

### 2. Traffic Splitting

Gradually roll out new versions by controlling the percentage of traffic:

```yaml
trafficShifting:
  enabled: true
  stableVersion: "v1"
  stableWeight: 90     # 90% of traffic
  canaryVersion: "v2"
  canaryWeight: 10     # 10% of traffic
```

### Visualizing Traffic with Kiali

If you have Kiali installed with Istio:

```bash
# Set up port forwarding to access Kiali
kubectl port-forward svc/kiali -n istio-system 20001:20001

# Access Kiali dashboard
open http://localhost:20001/
```

### Distributed Tracing

To enable tracing (when configured):

```bash
# Forward Jaeger port
kubectl port-forward svc/jaeger-query -n istio-system 16686:16686

# Access Jaeger UI
open http://localhost:16686/
```

## Troubleshooting

### Common Issues

1. **TLS Certificate Issues**
   - Verify certificate secret exists: `kubectl get secret angular-tls-cert -n angular-app`
   - Create a new certificate: `./scripts/create-tls-secrets.sh --domain example.com`

2. **Traffic Not Routing Correctly**
   - Check VirtualService: `kubectl get virtualservice -n angular-app -o yaml`
   - Validate Gateway: `kubectl get gateway -n angular-app -o yaml`
   - Verify service and port names match the destination

3. **Istio Sidecar Injection Not Working**
   - Check namespace label: `kubectl get namespace angular-app --show-labels`
   - Recreate pods if needed: `kubectl rollout restart deployment -n angular-app`

### Analyzing Istio Configuration

```bash
# Analyze Istio config for issues
istioctl analyze -n angular-app

# Check proxy status
istioctl proxy-status
```

## Further Customization

For advanced customization, you can:

1. Edit the Istio templates directly in `helm-chart/templates/`
2. Create custom overlay files for specific environments
3. Use `istioctl` for advanced configuration and troubleshooting

## Additional Resources

- [Istio Documentation](https://istio.io/latest/docs/)
- [Traffic Management Tasks](https://istio.io/latest/docs/tasks/traffic-management/)
- [Security Tasks](https://istio.io/latest/docs/tasks/security/)