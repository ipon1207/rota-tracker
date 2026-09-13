# Rota Tracker

## 開発環境のセットアップ

このリポジトリを `clone` したら、以下のコマンドを実行する

ルートディレクトリとフロントエンドのパッケージインストールが走る

```bash
npm run setup
```

## 開発環境の起動

リポジトリのルートで以下を実行すると、DBコンテナ・API・フロントエンドがまとめて起動

```bash
npm install
npm run dev
```

| 対象 | URL |
| --- | --- |
| フロントエンド | <http://localhost:5173> |
| API | <http://localhost:5243> |
| DB | localhost:14330 (SQL Server) |

`npm run dev` は次の順で処理

1. `docker compose up -d --wait` でDBコンテナを起動し、ヘルスチェックが通るまで待機する
2. `dotnet run` と `vite` を並列で起動する

Ctrl+CでAPIとフロントエンドは停止するが、DBコンテナは起動したままのため、停止する場合は `npm run db:down` を実行する

### 個別のスクリプト

| スクリプト | 内容 |
| --- | --- |
| `npm run dev:api` | APIのみ起動 |
| `npm run dev:web` | フロントエンドのみ起動 |
| `npm run db:up` | DBコンテナを起動 (ヘルスチェック待ち) |
| `npm run db:down` | DBコンテナを停止 |
| `npm run db:logs` | DBコンテナのログを追跡 |

### 事前準備

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) が起動していること
- `db/.env` (Git管理外) にSAパスワードを定義していること

```ini
MSSQL_SA_PASSWORD={パスワード}
```

## コーディング規約

### ドキュメント運用方針

- [ドキュメント運用方針](./docs/DOCUMENT_POLICY.md)

### アーキテクチャ

- [フロントエンドアーキテクチャ](./docs/FRONTEND_ARCHITECTURE.md)
- [バックエンドアーキテクチャ](./docs/BACKEND_ARCHITECTURE.md)

### コメント規約

- [コメント規約](./docs/COMMENT_GUIDE.md)

### API設計指針

- [バックエンドAPI設計指針](./docs/BACKEND_API_GUIDE.md)

## 学習ログ

タスクごとの決定・調査の記録。個別リンクは張らず、フォルダを直接見る

- [task](./docs/task/) — 実装したタスクの記録
- [spike](./docs/spike/) — 実装前の調査記録
