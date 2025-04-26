# Istio Integration for Angular Application

This directory contains Istio configuration files for deploying the Angular application with the Istio service mesh. Most of these configurations have been incorporated into the Helm chart for better management and deployment, but these standalone files are provided for reference and testing.

## Directory Structure

- **traffic/**: Traffic management configurations
  - canary-deployment.yaml: Configures header-based routing to canary deployments
  - traffic-shifting.yaml: Configures weighted traffic routing between versions
  - circuit-breaker.yaml: Circuit breaker configuration for resilience
  - fault-injection.yaml: Fault injection for testing

## Using Istio with the Angular Application

### Prerequisites

1. Kubernetes cluster with Istio installed
2. kubectl configured to communicate with your cluster
3. istioctl command-line tool

### Installation

Istio configurations are automatically applied when deploying with Helm if Istio is enabled. To manually apply these configurations:

1. Create and label the namespace:
   ```bash
   kubectl create namespace angular-app
   kubectl label namespace angular-app istio-injection=enabled
   ```

2. Apply the standalone Istio configurations:
   ```bash
   kubectl apply -f istio/traffic/
   ```

### Traffic Management

The Istio configurations enable several advanced traffic management features:

1. **Canary Deployments**: Test new versions by routing specific requests (with header `x-canary: true`) to the new version.

2. **Gradual Rollout**: Shift a percentage of traffic to a new version for gradual testing and rollout.

3. **Circuit Breaking**: Prevent cascading failures with connection limits and outlier detection.

4. **Fault Injection**: Test application resilience by injecting delays and errors (with header `x-test-fault: inject-fault`).

### Notes for Production Use

- Configure the Gateway hosts to match your actual domain names
- Adjust circuit breaker parameters based on your application's performance characteristics
- Configure mTLS for secure communication between services
- Set up proper authorization policies for each component

## Using Helm Chart Instead

For most production scenarios, use the Helm chart which incorporates all these Istio configurations in a more maintainable way. See the `helm-chart` directory for details.