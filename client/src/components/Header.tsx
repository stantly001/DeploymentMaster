import { useState } from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { CheckCircle, Bell, Menu } from "lucide-react";

interface HeaderProps {
  sidebarOpen: boolean;
  setSidebarOpen: (open: boolean) => void;
}

export default function Header({ sidebarOpen, setSidebarOpen }: HeaderProps) {
  return (
    <header className="bg-primary-700 text-white shadow-md">
      <div className="container mx-auto px-4 py-3 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <button 
            onClick={() => setSidebarOpen(!sidebarOpen)} 
            className="md:hidden p-2 rounded-md hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-white"
          >
            <Menu className="h-6 w-6" />
          </button>
          <div className="flex items-center">
            <CheckCircle className="h-8 w-8 mr-2" />
            <h1 className="text-xl font-bold">Angular GKE Deployment</h1>
          </div>
        </div>
        
        <div className="flex items-center space-x-4">
          <button className="p-2 rounded-full hover:bg-primary-600 focus:outline-none focus:ring-2 focus:ring-white">
            <Bell className="h-5 w-5" />
          </button>
          <div className="relative">
            <button className="flex items-center space-x-1 focus:outline-none">
              <Avatar className="h-8 w-8 border-2 border-white">
                <AvatarImage src="https://ui-avatars.com/api/?name=Admin" alt="User" />
                <AvatarFallback>AD</AvatarFallback>
              </Avatar>
              <span className="hidden md:inline-block">Admin</span>
              <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
