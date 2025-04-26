import { Home, Code, Cloud, Info, Settings, LogOut } from "lucide-react";
import { Link, useLocation } from "wouter";

interface SidebarProps {
  sidebarOpen: boolean;
}

export default function Sidebar({ sidebarOpen }: SidebarProps) {
  const [location] = useLocation();
  
  const navItems = [
    { icon: <Home className="h-5 w-5 mr-3" />, name: "Dashboard", path: "/" },
    { icon: <Code className="h-5 w-5 mr-3" />, name: "Build Configurations", path: "/build-config" },
    { icon: <Cloud className="h-5 w-5 mr-3" />, name: "Helm Charts", path: "/helm-charts" },
    { icon: <Cloud className="h-5 w-5 mr-3" />, name: "GKE Clusters", path: "/gke-clusters" },
    { icon: <Info className="h-5 w-5 mr-3" />, name: "Deployment Logs", path: "/deployment-logs" },
    { icon: <Settings className="h-5 w-5 mr-3" />, name: "Settings", path: "/settings" },
  ];
  
  return (
    <aside className={`bg-gray-800 text-white w-64 fixed inset-y-0 left-0 transform md:translate-x-0 transition-transform duration-200 ease-in-out z-10 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
      <div className="pt-16 pb-4 px-6 flex flex-col h-full">
        <nav className="mt-8 flex-1">
          <div className="space-y-1">
            {navItems.map((item) => (
              <Link key={item.path} href={item.path}>
                <a className={`flex items-center px-4 py-2 rounded-md ${
                  location === item.path 
                    ? 'text-white bg-primary-600' 
                    : 'text-gray-300 hover:bg-gray-700'
                }`}>
                  {item.icon}
                  {item.name}
                </a>
              </Link>
            ))}
          </div>
        </nav>
        <div className="border-t border-gray-700 pt-4">
          <a href="#" className="flex items-center px-4 py-2 text-gray-300 hover:bg-gray-700 rounded-md">
            <LogOut className="h-5 w-5 mr-3" />
            Logout
          </a>
        </div>
      </div>
    </aside>
  );
}
