import { Button } from "@/components/ui/button";
import { ReactNode } from "react";

interface ActionButtonProps {
  children: ReactNode;
  onClick?: () => void;
  variant?: "default" | "secondary" | "outline" | "ghost";
  disabled?: boolean;
  icon?: ReactNode;
}

export default function ActionButton({
  children,
  onClick,
  variant = "default",
  disabled = false,
  icon
}: ActionButtonProps) {
  return (
    <Button
      variant={variant}
      onClick={onClick}
      disabled={disabled}
      className="inline-flex items-center"
    >
      {icon && <span className="mr-2">{icon}</span>}
      {children}
    </Button>
  );
}
