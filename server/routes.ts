import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { insertDeploymentSchema, insertConfigurationSchema } from "@shared/schema";
import z from "zod";

export async function registerRoutes(app: Express): Promise<Server> {
  // Get all deployments (with optional limit)
  app.get("/api/deployments", async (req, res) => {
    try {
      const limit = req.query.limit ? parseInt(req.query.limit as string) : undefined;
      const deployments = await storage.getDeployments(limit);
      
      // Get user info for each deployment
      const deploymentsWithUserInfo = await Promise.all(
        deployments.map(async (deployment) => {
          let user = undefined;
          if (deployment.deployedBy) {
            user = await storage.getUser(deployment.deployedBy);
          }
          
          return {
            ...deployment,
            deployedBy: user ? {
              id: user.id,
              username: user.username,
              email: user.email,
              fullName: user.fullName
            } : undefined
          };
        })
      );
      
      res.json(deploymentsWithUserInfo);
    } catch (error) {
      console.error("Error fetching deployments:", error);
      res.status(500).json({ message: "Failed to fetch deployments" });
    }
  });
  
  // Get a specific deployment
  app.get("/api/deployments/:id", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const deployment = await storage.getDeployment(id);
      
      if (!deployment) {
        return res.status(404).json({ message: "Deployment not found" });
      }
      
      let user = undefined;
      if (deployment.deployedBy) {
        user = await storage.getUser(deployment.deployedBy);
      }
      
      res.json({
        ...deployment,
        deployedBy: user ? {
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName
        } : undefined
      });
    } catch (error) {
      console.error("Error fetching deployment:", error);
      res.status(500).json({ message: "Failed to fetch deployment" });
    }
  });
  
  // Create a new deployment
  app.post("/api/deployments", async (req, res) => {
    try {
      const deploymentData = insertDeploymentSchema.parse(req.body);
      const deployment = await storage.createDeployment(deploymentData);
      res.status(201).json(deployment);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          message: "Invalid deployment data", 
          errors: error.errors 
        });
      }
      console.error("Error creating deployment:", error);
      res.status(500).json({ message: "Failed to create deployment" });
    }
  });
  
  // Update deployment status
  app.patch("/api/deployments/:id/status", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const { status } = req.body;
      
      if (!status || typeof status !== "string") {
        return res.status(400).json({ message: "Status is required" });
      }
      
      const updatedDeployment = await storage.updateDeploymentStatus(id, status);
      
      if (!updatedDeployment) {
        return res.status(404).json({ message: "Deployment not found" });
      }
      
      res.json(updatedDeployment);
    } catch (error) {
      console.error("Error updating deployment status:", error);
      res.status(500).json({ message: "Failed to update deployment status" });
    }
  });
  
  // Get all configurations
  app.get("/api/configurations", async (req, res) => {
    try {
      const configType = req.query.type as string | undefined;
      
      let configurations;
      if (configType) {
        configurations = await storage.getConfigurationByType(configType);
      } else {
        configurations = await storage.getConfigurations();
      }
      
      res.json(configurations);
    } catch (error) {
      console.error("Error fetching configurations:", error);
      res.status(500).json({ message: "Failed to fetch configurations" });
    }
  });
  
  // Get a configuration by name
  app.get("/api/configurations/:name", async (req, res) => {
    try {
      const name = req.params.name;
      const configuration = await storage.getConfigurationByName(name);
      
      if (!configuration) {
        return res.status(404).json({ message: "Configuration not found" });
      }
      
      res.json(configuration);
    } catch (error) {
      console.error("Error fetching configuration:", error);
      res.status(500).json({ message: "Failed to fetch configuration" });
    }
  });
  
  // Create a new configuration
  app.post("/api/configurations", async (req, res) => {
    try {
      const configData = insertConfigurationSchema.parse(req.body);
      const configuration = await storage.createConfiguration(configData);
      res.status(201).json(configuration);
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({ 
          message: "Invalid configuration data", 
          errors: error.errors 
        });
      }
      console.error("Error creating configuration:", error);
      res.status(500).json({ message: "Failed to create configuration" });
    }
  });
  
  // Update a configuration
  app.patch("/api/configurations/:id", async (req, res) => {
    try {
      const id = parseInt(req.params.id);
      const { content } = req.body;
      
      if (!content || typeof content !== "string") {
        return res.status(400).json({ message: "Content is required" });
      }
      
      const updatedConfig = await storage.updateConfiguration(id, content);
      
      if (!updatedConfig) {
        return res.status(404).json({ message: "Configuration not found" });
      }
      
      res.json(updatedConfig);
    } catch (error) {
      console.error("Error updating configuration:", error);
      res.status(500).json({ message: "Failed to update configuration" });
    }
  });
  
  // Get deployment stats
  app.get("/api/stats", async (req, res) => {
    try {
      const deployments = await storage.getDeployments();
      
      const successfulDeployments = deployments.filter(d => d.status === "successful").length;
      const failedDeployments = deployments.filter(d => d.status === "failed").length;
      
      // Calculate average build time (mock data for now)
      const avgBuildTime = "3m 42s";
      
      // Calculate last deployment time
      let lastDeploymentTime = "N/A";
      if (deployments.length > 0) {
        const latestDeployment = deployments[0]; // Already sorted by time
        lastDeploymentTime = latestDeployment.deployedAt 
          ? new Date(latestDeployment.deployedAt).toLocaleString() 
          : "N/A";
      }
      
      res.json({
        successfulDeployments,
        failedDeployments,
        avgBuildTime,
        lastDeploymentTime
      });
    } catch (error) {
      console.error("Error fetching stats:", error);
      res.status(500).json({ message: "Failed to fetch deployment stats" });
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}
