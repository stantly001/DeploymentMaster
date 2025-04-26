# Angular Application Helm Chart

A Helm chart for deploying Angular applications to Kubernetes with Istio service mesh integration.

## Features

- **Deployment Options**: Deploy single or multi-version (for canary deployments)
- **Istio Service Mesh Integration**: Traffic management, security, and observability
- **Horizontal Pod Autoscaling**: Automatically scale based on CPU/memory usage
- **Flexible Configuration**: Highly customizable through values.yaml

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Istio 1.8+ (optional, for service mesh features)

## Installation

### Basic Installation

```bash
helm install angular-app ./helm-chart
```

### With Custom Values

```bash
helm install angular-app ./helm-chart --values custom-values.yaml
```

### Using the Deployment Script

The repository includes helper scripts for deploying to different environments:

```bash
# For a standard Kubernetes cluster
./helm_deploy.sh

# For Google Kubernetes Engine (GKE)
./gke_deploy.sh --project your-gcp-project-id
```

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter                         | Description                                          | Default                            |
|-----------------------------------|------------------------------------------------------|-----------------------------------|
| `application.name`                | Name of your application                             | `angular-app`                     |
| `application.version`             | Version of your application                          | `1.0.0`                           |
| `replicaCount`                    | Number of replicas                                   | `2`                               |
| `image.repository`                | Image repository                                     | `gcr.io/your-project/angular-app` |
| `image.tag`                       | Image tag                                            | `latest`                          |
| `image.pullPolicy`                | Image pull policy                                    | `Always`                          |
| `service.type`                    | Kubernetes service type                              | `ClusterIP`                       |
| `service.port`                    | Kubernetes service port                              | `80`                              |
| `autoscaling.enabled`             | Enable autoscaling                                   | `true`                            |
| `autoscaling.minReplicas`         | Minimum number of replicas                           | `2`                               |
| `autoscaling.maxReplicas`         | Maximum number of replicas                           | `10`                              |
| `istio.enabled`                   | Enable Istio integration                             | `true`                            |
| `istio.gateway.hosts`             | List of hosts for Istio gateway                      | `["example.com"]`                 |
| `istio.trafficManagement.canary.enabled` | Enable canary deployments                     | `true`                            |
| `istio.trafficManagement.trafficShifting.enabled` | Enable traffic splitting              | `true`                           |

See the `values.yaml` file for the complete list of parameters.

## Istio Integration

When Istio is enabled, the chart deploys additional resources:

- **Gateway**: Provides entry points to the application
- **VirtualService**: Defines traffic routing rules
- **DestinationRule**: Configures connection pools and circuit breakers
- **PeerAuthentication**: Sets mTLS policies
- **AuthorizationPolicy**: Controls access to the service
- **Telemetry**: Configures metrics, tracing, and access logging

### Canary Deployments

The chart supports canary deployments by creating a second deployment with different version labels. The traffic is routed using Istio's VirtualService:

- Header-based routing: Send traffic with `x-canary: true` header to the canary version
- Weighted traffic splitting: Send a specified percentage of traffic to each version

## Example: Deploying with Canary Testing

1. Deploy the application with traffic splitting:

```yaml
# custom-values.yaml
istio:
  enabled: true
  trafficManagement:
    trafficShifting:
      enabled: true
      stableVersion: "v1"
      stableWeight: 90
      canaryVersion: "v2" 
      canaryWeight: 10
```

2. Deploy using custom values:

```bash
helm install angular-app ./helm-chart --values custom-values.yaml
```

3. Gradually increase traffic to the new version once validated.

## Troubleshooting

If you encounter issues with the deployment:

1. Check pod status:
   ```bash
   kubectl get pods -n <namespace>
   ```

2. Check Istio resources:
   ```bash
   kubectl get virtualservice,gateway,destinationrule -n <namespace>
   ```

3. Check pod logs:
   ```bash
   kubectl logs <pod-name> -n <namespace>
   ```