# TanStack Queryでプロジェクト一覧を表示する

## Viteでプロキシを設定する

- [Viteでプロキシを設定する](https://qiita.com/sho03/items/6f4a191527f0f8a6ab1c)

`vite.config.ts` に `server.proxy` 設定を追加することで、バックエンドサーバに対してリクエストをした場合に、`localhost:5243/api/` へリクエストされるようになる

```ts:vite.config.ts
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:5243/',
      changeOrigin: true,
    },
  },
}
```

## TanStack Queryの使い方

- [TanstackQueryに入門してみる](https://qiita.com/A-Yuki28/items/1224e19c86bbcd4d4890)
- [データフェッチング（TanStack Query）](https://zenn.dev/rasshii/books/learning-react-2026/viewer/20-tanstack-query)

### 準備

- クエリクライアントの設定

`TanStack Query` を使う前に、`QueryClient` を設定し、`TanStack Query` を使用するコンポーネントを `QueryClientProvider` でラップする必要がある

```tsx
import {
  QueryClient,
  QueryClientProvider,
} from '@tanstack/react-query'

const queryClient = new QueryClient()

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Example />
    </QueryClientProvider>
  )
}
```

### `useQuery`（データの取得）

データ取得には、`useQuery` というフックを使う

`useQuery` の引数に `queryKey` と `queryFn` をプロパティとして持つオブジェクトを渡す

```tsx
import { useQuery } from '@tanstack/react-query'

function App() {
  const { isPending, isError, data, error } = useQuery({ 
    queryKey: ['todos'], 
    queryFn: fetchTodoList 
  })
}
```

```tsx
import { useQuery } from '@tanstack/react-query'

type User = {
  id: number
  name: string
  email: string
}

function UserProfile({ userId }: { userId: number }) {
  const { data, isLoading, isError, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: async () => {
      const response = await fetch(`/api/users/${userId}`)
      if (!response.ok) throw new Error('Failed to fetch')
      return response.json() as Promise<User>
    }
  })

  if (isLoading) return <p>読み込み中...</p>
  if (isError) return <p>エラー: {error.message}</p>

  return (
    <div>
      <h2>{data?.name}</h2>
      <p>{data?.email}</p>
    </div>
  )
}
```

### 状態フラグの使い分け (`isPending` / `isLoading` / `isFetching`)

| **フラグ** | **意味** | **使いどころ** |
| --- | --- | --- |
| `isPending` | data がまだ存在しない（最初のフェッチ中、または失敗後） | データ取得前のスケルトン/スピナー表示全般 |
| `isLoading` | 初回の取得中のみ `true`（`isPending && isFetching`） | 初回だけスピナーを出したい場合 |
| `isFetching` | バックグラウンドでの再取得中も含めて `true` | 再取得中のインジケーター表示 |
| `isError` | エラーが発生している | エラーメッセージ表示 |

> #### `isLoading` と `isPending` の使い分けに関して
>
> **特別な事情がなければ `isPending` を使う**のが推奨

## npmパッケージがコーディング中にimport補完をしてくれない

まだ一度も `import` していないパッケージのシンボルを補完候補に出すには、TSが `package.json` の依存を走査する必要がある（`settings.json` で明示的に設定しないと既定で `auto` なので、依存が多い場合は自動的に無効化される）

```json:settings.json
{
  // パッケージの補完候補を出す
  "js/ts.preferences.includePackageJsonAutoImports": "on",
  "js/ts.suggest.autoImports": true,
}
```
