import { 
  users, type User, type InsertUser,
  deployments, type Deployment, type InsertDeployment,
  configurations, type Configuration, type InsertConfiguration
} from "@shared/schema";

export interface IStorage {
  // User operations
  getUser(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
  
  // Deployment operations
  getDeployments(limit?: number): Promise<Deployment[]>;
  getDeployment(id: number): Promise<Deployment | undefined>;
  createDeployment(deployment: InsertDeployment): Promise<Deployment>;
  updateDeploymentStatus(id: number, status: string): Promise<Deployment | undefined>;
  
  // Configuration operations
  getConfigurations(): Promise<Configuration[]>;
  getConfigurationByName(name: string): Promise<Configuration | undefined>;
  getConfigurationByType(configType: string): Promise<Configuration[]>;
  createConfiguration(configuration: InsertConfiguration): Promise<Configuration>;
  updateConfiguration(id: number, content: string): Promise<Configuration | undefined>;
}

export class MemStorage implements IStorage {
  private users: Map<number, User>;
  private deployments: Map<number, Deployment>;
  private configurations: Map<number, Configuration>;
  private userId: number;
  private deploymentId: number;
  private configId: number;

  constructor() {
    this.users = new Map();
    this.deployments = new Map();
    this.configurations = new Map();
    this.userId = 1;
    this.deploymentId = 1;
    this.configId = 1;
    
    // Create default admin user
    this.createUser({
      username: "admin",
      password: "admin123",
      email: "admin@example.com",
      fullName: "Administrator"
    });
    
    // Create default configurations
    this.createConfiguration({
      name: "default-nginx-config",
      configType: "nginx",
      content: `server {
  listen 80;
  location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
    try_files $uri $uri/ /index.html;
  }
  # Caching static assets
  location ~* \\.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, max-age=31536000";
  }
}`,
      createdBy: 1
    });
    
    this.createConfiguration({
      name: "angular-prod-config",
      configType: "angular",
      content: `{
  "production": {
    "fileReplacements": [
      {
        "replace": "src/environments/environment.ts",
        "with": "src/environments/environment.prod.ts"
      }
    ],
    "optimization": true,
    "outputHashing": "all",
    "sourceMap": false,
    "namedChunks": false,
    "extractLicenses": true,
    "vendorChunk": false,
    "buildOptimizer": true,
    "budgets": [
      {
        "type": "initial",
        "maximumWarning": "2mb",
        "maximumError": "5mb"
      }
    ]
  }
}`,
      createdBy: 1
    });
    
    // Create sample deployments
    this.createDeployment({
      name: "production-v1.2.5",
      buildNumber: 458,
      status: "successful",
      environment: "production",
      deployedBy: 1
    });
    
    this.createDeployment({
      name: "staging-v1.2.5",
      buildNumber: 457,
      status: "successful",
      environment: "staging",
      deployedBy: 1
    });
    
    this.createDeployment({
      name: "dev-v1.2.4",
      buildNumber: 456,
      status: "failed",
      environment: "development",
      deployedBy: 1
    });
  }

  // User operations
  async getUser(id: number): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = this.userId++;
    const now = new Date();
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }
  
  // Deployment operations
  async getDeployments(limit?: number): Promise<Deployment[]> {
    const allDeployments = Array.from(this.deployments.values());
    // Sort by deployedAt in descending order
    allDeployments.sort((a, b) => {
      if (a.deployedAt && b.deployedAt) {
        return new Date(b.deployedAt).getTime() - new Date(a.deployedAt).getTime();
      }
      return 0;
    });
    
    if (limit) {
      return allDeployments.slice(0, limit);
    }
    
    return allDeployments;
  }
  
  async getDeployment(id: number): Promise<Deployment | undefined> {
    return this.deployments.get(id);
  }
  
  async createDeployment(insertDeployment: InsertDeployment): Promise<Deployment> {
    const id = this.deploymentId++;
    const deployedAt = new Date();
    const deployment: Deployment = { ...insertDeployment, id, deployedAt };
    this.deployments.set(id, deployment);
    return deployment;
  }
  
  async updateDeploymentStatus(id: number, status: string): Promise<Deployment | undefined> {
    const deployment = this.deployments.get(id);
    if (!deployment) return undefined;
    
    const updatedDeployment: Deployment = { ...deployment, status };
    this.deployments.set(id, updatedDeployment);
    return updatedDeployment;
  }
  
  // Configuration operations
  async getConfigurations(): Promise<Configuration[]> {
    return Array.from(this.configurations.values());
  }
  
  async getConfigurationByName(name: string): Promise<Configuration | undefined> {
    return Array.from(this.configurations.values()).find(
      (config) => config.name === name
    );
  }
  
  async getConfigurationByType(configType: string): Promise<Configuration[]> {
    return Array.from(this.configurations.values()).filter(
      (config) => config.configType === configType
    );
  }
  
  async createConfiguration(insertConfiguration: InsertConfiguration): Promise<Configuration> {
    const id = this.configId++;
    const now = new Date();
    const configuration: Configuration = { 
      ...insertConfiguration, 
      id, 
      createdAt: now,
      updatedAt: now
    };
    this.configurations.set(id, configuration);
    return configuration;
  }
  
  async updateConfiguration(id: number, content: string): Promise<Configuration | undefined> {
    const config = this.configurations.get(id);
    if (!config) return undefined;
    
    const updatedConfig: Configuration = { 
      ...config, 
      content,
      updatedAt: new Date()
    };
    this.configurations.set(id, updatedConfig);
    return updatedConfig;
  }
}

export const storage = new MemStorage();
