import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Edit } from "lucide-react";
import ActionButton from "./ActionButton";

interface ConfigCardProps {
  title: string;
  content: string;
  onEdit?: () => void;
}

export default function ConfigCard({ title, content, onEdit }: ConfigCardProps) {
  return (
    <Card>
      <CardHeader className="px-6 py-4 border-b border-gray-200">
        <CardTitle className="text-lg font-medium">{title}</CardTitle>
      </CardHeader>
      <CardContent className="p-6">
        <div className="bg-gray-50 p-4 rounded-md overflow-hidden mb-4 text-sm">
          <pre className="whitespace-pre-wrap text-gray-700 font-mono">{content}</pre>
        </div>
        <ActionButton
          variant="outline"
          icon={<Edit className="h-5 w-5 text-gray-500" />}
          onClick={onEdit}
        >
          Edit Configuration
        </ActionButton>
      </CardContent>
    </Card>
  );
}
