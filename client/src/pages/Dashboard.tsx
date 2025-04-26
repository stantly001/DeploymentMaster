import { useState, useEffect } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";
import Header from "@/components/Header";
import Sidebar from "@/components/Sidebar";
import StatCard from "@/components/StatCard";
import DeploymentTable from "@/components/DeploymentTable";
import ConfigCard from "@/components/ConfigCard";
import ActionButton from "@/components/ActionButton";
import { 
  CheckCircle, 
  AlertCircle, 
  Zap, 
  Calendar, 
  PlusCircle, 
  RotateCcw, 
  AlertOctagon,
  Settings 
} from "lucide-react";
import { createDeployment } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";

export default function Dashboard() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { toast } = useToast();

  // Fetch deployment stats
  const statsQuery = useQuery({
    queryKey: ['/api/stats'],
  });

  // Fetch recent deployments
  const deploymentsQuery = useQuery({
    queryKey: ['/api/deployments'],
  });

  // Fetch configurations
  const nginxConfigQuery = useQuery({
    queryKey: ['/api/configurations/default-nginx-config'],
  });

  const angularConfigQuery = useQuery({
    queryKey: ['/api/configurations/angular-prod-config'],
  });

  // Mutation for creating a new deployment
  const deployMutation = useMutation({
    mutationFn: () => {
      return createDeployment({
        name: `deployment-v1.0.${Math.floor(Math.random() * 100)}`,
        buildNumber: Math.floor(Math.random() * 1000),
        status: "pending",
        environment: "production",
        deployedBy: 1
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['/api/deployments'] });
      queryClient.invalidateQueries({ queryKey: ['/api/stats'] });
      toast({
        title: "Deployment initiated",
        description: "Your new deployment has been initiated successfully.",
        variant: "default",
      });
    },
    onError: (error) => {
      toast({
        title: "Deployment failed",
        description: `Failed to initiate deployment: ${error}`,
        variant: "destructive",
      });
    }
  });

  const handleDeploy = () => {
    deployMutation.mutate();
  };

  const handleViewDeploymentDetails = (id: number) => {
    toast({
      title: "Viewing deployment details",
      description: `Viewing details for deployment ID: ${id}`,
    });
  };

  const handleRollbackDeployment = (id: number) => {
    toast({
      title: "Rollback initiated",
      description: `Rolling back deployment ID: ${id}`,
    });
  };

  const handleEditConfig = (configType: string) => {
    toast({
      title: "Edit configuration",
      description: `Editing ${configType} configuration`,
    });
  };

  const stats = statsQuery.data || {
    successfulDeployments: 0,
    failedDeployments: 0,
    avgBuildTime: "0m 0s",
    lastDeploymentTime: "N/A"
  };

  const deployments = deploymentsQuery.data || [];

  return (
    <div className="min-h-screen flex flex-col">
      <Header sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

      <div className="flex flex-1">
        <Sidebar sidebarOpen={sidebarOpen} />

        <main className="flex-1 md:ml-64 p-6">
          <div className="container mx-auto">
            {/* Dashboard Header */}
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-gray-800">Angular GKE Deployment Dashboard</h2>
              <p className="text-gray-600 mt-1">Monitor and manage your Angular app deployments to Google Kubernetes Engine</p>
            </div>

            {/* Deployment Status Overview */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
              <StatCard 
                title="Successful Deployments" 
                value={stats.successfulDeployments} 
                icon={<CheckCircle className="h-6 w-6" />}
                bgColor="bg-green-100"
                textColor="text-green-600"
              />
              <StatCard 
                title="Failed Deployments" 
                value={stats.failedDeployments} 
                icon={<AlertCircle className="h-6 w-6" />}
                bgColor="bg-red-100"
                textColor="text-red-600"
              />
              <StatCard 
                title="Build Time (avg)" 
                value={stats.avgBuildTime} 
                icon={<Zap className="h-6 w-6" />}
                bgColor="bg-blue-100"
                textColor="text-blue-600"
              />
              <StatCard 
                title="Last Deployed" 
                value={typeof stats.lastDeploymentTime === 'string' ? stats.lastDeploymentTime : 'N/A'} 
                icon={<Calendar className="h-6 w-6" />}
                bgColor="bg-purple-100"
                textColor="text-purple-600"
              />
            </div>

            {/* Quick Actions */}
            <div className="bg-white rounded-lg shadow mb-8">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="text-lg font-medium">Quick Actions</h3>
              </div>
              <div className="p-6 flex flex-wrap gap-4">
                <ActionButton 
                  onClick={handleDeploy} 
                  icon={<PlusCircle className="h-5 w-5" />}
                >
                  Deploy New Build
                </ActionButton>
                <ActionButton 
                  variant="outline" 
                  icon={<RotateCcw className="h-5 w-5 text-gray-500" />}
                >
                  Rollback Deployment
                </ActionButton>
                <ActionButton 
                  variant="outline" 
                  icon={<AlertOctagon className="h-5 w-5 text-gray-500" />}
                >
                  View Build Logs
                </ActionButton>
                <ActionButton 
                  variant="outline" 
                  icon={<Settings className="h-5 w-5 text-gray-500" />}
                  onClick={() => handleEditConfig('nginx')}
                >
                  Nginx Config
                </ActionButton>
              </div>
            </div>

            {/* Recent Deployments */}
            <div className="bg-white rounded-lg shadow mb-8">
              <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                <h3 className="text-lg font-medium">Recent Deployments</h3>
                <button className="text-sm text-primary-600 hover:text-primary-700 focus:outline-none">View All</button>
              </div>
              <div className="overflow-x-auto">
                <DeploymentTable 
                  deployments={deployments} 
                  onViewDetails={handleViewDeploymentDetails}
                  onRollback={handleRollbackDeployment}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Nginx Configuration */}
              <ConfigCard 
                title="Nginx Configuration" 
                content={nginxConfigQuery.data?.content || `server {
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
}`}
                onEdit={() => handleEditConfig('nginx')}
              />

              {/* Angular Build Configuration */}
              <ConfigCard 
                title="Angular Build Configuration" 
                content={angularConfigQuery.data?.content || `{
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
}`}
                onEdit={() => handleEditConfig('angular')}
              />
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
