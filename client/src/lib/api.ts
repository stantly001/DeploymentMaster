import { apiRequest } from "./queryClient";

// Deployment related functions
export async function createDeployment(deploymentData: any) {
  const response = await apiRequest("POST", "/api/deployments", deploymentData);
  return await response.json();
}

export async function updateDeploymentStatus(id: number, status: string) {
  const response = await apiRequest("PATCH", `/api/deployments/${id}/status`, { status });
  return await response.json();
}

// Configuration related functions
export async function getConfigurationByName(name: string) {
  const response = await apiRequest("GET", `/api/configurations/${name}`, undefined);
  return await response.json();
}

export async function updateConfiguration(id: number, content: string) {
  const response = await apiRequest("PATCH", `/api/configurations/${id}`, { content });
  return await response.json();
}
