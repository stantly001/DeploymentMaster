import { pgTable, text, serial, integer, boolean, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull().unique(),
  password: text("password").notNull(),
  email: text("email"),
  fullName: text("full_name"),
});

export const deployments = pgTable("deployments", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  buildNumber: integer("build_number").notNull(),
  status: text("status").notNull(), // successful, failed, pending
  environment: text("environment").notNull(), // production, staging, development
  deployedBy: integer("deployed_by").references(() => users.id),
  deployedAt: timestamp("deployed_at").notNull().defaultNow(),
});

export const configurations = pgTable("configurations", {
  id: serial("id").primaryKey(),
  name: text("name").notNull().unique(),
  configType: text("config_type").notNull(), // nginx, angular, helm
  content: text("content").notNull(),
  createdBy: integer("created_by").references(() => users.id),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const insertUserSchema = createInsertSchema(users).pick({
  username: true,
  password: true,
  email: true,
  fullName: true,
});

export const insertDeploymentSchema = createInsertSchema(deployments).pick({
  name: true,
  buildNumber: true,
  status: true,
  environment: true,
  deployedBy: true,
});

export const insertConfigurationSchema = createInsertSchema(configurations).pick({
  name: true,
  configType: true,
  content: true,
  createdBy: true,
});

export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof users.$inferSelect;

export type InsertDeployment = z.infer<typeof insertDeploymentSchema>;
export type Deployment = typeof deployments.$inferSelect;

export type InsertConfiguration = z.infer<typeof insertConfigurationSchema>;
export type Configuration = typeof configurations.$inferSelect;
