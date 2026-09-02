import { useQuery } from '@tanstack/react-query';

import './App.css';
import type { components } from '@/lib/api/schema.gen';

type Project = components['schemas']['Project'];

function App() {
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      const response = await fetch('/api/projects');

      if (!response.ok) throw new Error('プロジェクト一覧の取得に失敗しました');

      return response.json() as Promise<Project[]>;
    },
  });

  if (isLoading) {
    return (
      <div className="p-8">
        <p className="text-gray-500">読み込み中...</p>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="p-8">
        <p className="text-red-500">エラー：{error.message}</p>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="mb-4 text-2xl font-bold">プロジェクト一覧</h1>
      <ul className="space-y-2">
        {data?.map((project) => (
          <li key={project.id} className="rounded bg-gray-100 p-4">
            <p className="font-bold">{project.title}</p>
            <p className="text-sm text-gray-600">{project.categoryId}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
