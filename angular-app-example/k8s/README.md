# Kubernetes Deployment for Angular Application

This directory contains Kubernetes manifests for deploying the Angular application with Nginx.

## Contents

- `deployment.yaml`: Defines the Kubernetes Deployment for the Angular application
- `service.yaml`: Defines the Kubernetes Service to expose the application
- `ingress.yaml`: Defines the Kubernetes Ingress for routing external traffic

## Deployment Steps

1. Build and push your Docker image to your container registry:
   ```bash
   docker build -t your-registry/angular-app:tag .
   docker push your-registry/angular-app:tag
   ```

2. Update the deployment.yaml file to use your image:
   ```yaml
   containers:
   - name: angular-app
     image: your-registry/angular-app:tag
   ```

3. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

4. Check the status of your deployment:
   ```bash
   kubectl get deployment angular-app
   kubectl get service angular-app-service
   kubectl get ingress angular-app-ingress
   ```

## Configuration

### Resources
The deployment is configured with the following resource limits and requests:
- CPU: 500m (limit), 100m (request)
- Memory: 512Mi (limit), 128Mi (request)

Adjust these values based on your application's needs.

### Scaling
By default, the deployment runs with 3 replicas. To scale:
```bash
kubectl scale deployment angular-app --replicas=5
```

### Ingress Configuration
The included Ingress is configured for:
- HTTPS with TLS
- Automatic redirection from HTTP to HTTPS
- Support for Angular's HTML5 routing

Update the `host` field in the Ingress to match your domain.

## Monitoring
The deployment includes readiness and liveness probes to help Kubernetes monitor the health of your pods:
- Readiness probe: Checks if the application is ready to receive traffic
- Liveness probe: Ensures the application is still running correctly

## Troubleshooting

### Common Issues

1. **Pod Startup Failure**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Ingress Not Working**
   ```bash
   kubectl get ingress
   kubectl describe ingress angular-app-ingress
   ```
   
3. **TLS Certificate Issues**
   ```bash
   kubectl get certificate
   kubectl describe certificate angular-app-tls
   ```

### Environment-Specific Configuration

For different environments, consider using:
- Kustomize for environment-specific configurations
- Helm for parameterized deployments
- Separate namespaces for isolation