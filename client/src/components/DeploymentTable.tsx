import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Eye, RotateCcw } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { formatDistanceToNow } from "date-fns";

interface DeploymentUser {
  id: number;
  username: string;
  email?: string;
  fullName?: string;
}

interface Deployment {
  id: number;
  name: string;
  buildNumber: number;
  status: string;
  environment: string;
  deployedBy?: DeploymentUser;
  deployedAt: Date;
}

interface DeploymentTableProps {
  deployments: Deployment[];
  onViewDetails?: (id: number) => void;
  onRollback?: (id: number) => void;
}

export default function DeploymentTable({
  deployments,
  onViewDetails,
  onRollback,
}: DeploymentTableProps) {
  const getStatusBadge = (status: string) => {
    switch (status.toLowerCase()) {
      case "successful":
        return <Badge className="bg-green-100 text-green-800">Successful</Badge>;
      case "failed":
        return <Badge className="bg-red-100 text-red-800">Failed</Badge>;
      case "pending":
        return <Badge className="bg-yellow-100 text-yellow-800">Pending</Badge>;
      default:
        return <Badge className="bg-gray-100 text-gray-800">{status}</Badge>;
    }
  };

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Deployment</TableHead>
          <TableHead>Status</TableHead>
          <TableHead>Environment</TableHead>
          <TableHead>Deployed By</TableHead>
          <TableHead>Deployed At</TableHead>
          <TableHead>Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {deployments.map((deployment) => (
          <TableRow key={deployment.id}>
            <TableCell>
              <div className="flex items-center">
                <div className="flex-shrink-0 h-10 w-10 flex items-center justify-center rounded-md bg-primary-100 text-primary-600">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M5.5 2a3.5 3.5 0 101.665 6.58L8.585 10l-1.42 1.42a3.5 3.5 0 101.414 1.414l8.128-8.127a1 1 0 00-1.414-1.414L10 8.586l-1.42-1.42A3.5 3.5 0 005.5 2zM4 5.5a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0zm0 9a1.5 1.5 0 113 0 1.5 1.5 0 01-3 0z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="ml-4">
                  <div className="text-sm font-medium text-gray-900">{deployment.name}</div>
                  <div className="text-sm text-gray-500">Build #{deployment.buildNumber}</div>
                </div>
              </div>
            </TableCell>
            <TableCell>{getStatusBadge(deployment.status)}</TableCell>
            <TableCell className="text-sm text-gray-500">{deployment.environment}</TableCell>
            <TableCell>
              {deployment.deployedBy ? (
                <div className="flex items-center">
                  <Avatar className="h-8 w-8">
                    <AvatarImage 
                      src={`https://ui-avatars.com/api/?name=${encodeURIComponent(deployment.deployedBy.fullName || deployment.deployedBy.username)}`} 
                      alt={deployment.deployedBy.fullName || deployment.deployedBy.username} 
                    />
                    <AvatarFallback>{(deployment.deployedBy.fullName || deployment.deployedBy.username).substring(0, 2).toUpperCase()}</AvatarFallback>
                  </Avatar>
                  <div className="ml-3">
                    <div className="text-sm font-medium text-gray-900">{deployment.deployedBy.fullName || deployment.deployedBy.username}</div>
                    <div className="text-sm text-gray-500">{deployment.deployedBy.email}</div>
                  </div>
                </div>
              ) : (
                <span className="text-sm text-gray-500">Unknown</span>
              )}
            </TableCell>
            <TableCell className="text-sm text-gray-500">
              {formatDistanceToNow(new Date(deployment.deployedAt), { addSuffix: true })}
            </TableCell>
            <TableCell>
              <div className="flex space-x-2">
                <button 
                  className="text-primary-600 hover:text-primary-900 focus:outline-none"
                  onClick={() => onViewDetails && onViewDetails(deployment.id)}
                >
                  <Eye className="h-5 w-5" />
                </button>
                <button 
                  className="text-primary-600 hover:text-primary-900 focus:outline-none"
                  onClick={() => onRollback && onRollback(deployment.id)}
                >
                  <RotateCcw className="h-5 w-5" />
                </button>
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
