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

### アーキテクチャ

- [フロントエンドアーキテクチャ](./docs/FRONTEND_ARCHITECTURE.md)
- [バックエンドアーキテクチャ](./docs/BACKEND_ARCHITECTURE.md)

### コメント規約

- [コメント規約](./docs/COMMENT_GUIDE.md)

### API設計指針

- [バックエンドAPI設計指針](./docs/BACKEND_API_GUIDE.md)

## 学習ログリンク

### spike

- [1-バックエンド側の環境構築](./docs/spike/1-バックエンド側の環境構築.md)
- [19-Dapperで接続を供給するパターンについて調べる](./docs/spike/19-Dapperで接続を供給するパターンについて調べる.md)
- [27-アーキテクチャテストの調査](./docs/spike/27-アーキテクチャテストの調査.md)
- [28-ドキュメント生成ライブラリ](./docs/spike/28-ドキュメント生成ライブラリ.md)
- [30-Storybook](./docs/spike/30-Storybook.md)

### task

- [3-フロントエンド側の環境構築](./docs/task/3-フロントエンド側の環境構築.md)
- [5-pre-commitの設定](./docs/task/5-pre-commitの設定.md)
- [8-TypeScriptのstrictを有効にする](./docs/task/8-TypeScriptのstrictを有効にする.md)
- [10-VSCodeの設定を整備する](./docs/task/10-VSCodeの設定を整備する.md)
- [11-DB環境の構築](./docs/task/11-DB環境の構築.md)
- [14-SQL Serverへの接続を確立する](./docs/task/14-SQLServerへの接続を確立する.md)
- [16-OpenAPIドキュメントをファイルに出力する](./docs/task/16-OpenAPIドキュメントをファイルに出力する.md)
- [17-TanStack Queryでプロジェクト一覧を表示する](./docs/task/17-TanStackQueryでプロジェクト一覧を表示する.md)
- [22-GitHooksをLeftHookに変更する](./docs/task/22-GitHooksをLeftHookに変更する.md)
- [26-動作確認の簡易化](./docs/task/26-動作確認の簡易化.md)
- [33-npmとnodeのバージョン固定](./docs/task/33-npmとnodeのバージョン固定.md)
- [35-コメント規約の作成](./docs/task/36-コメント規約の作成.md)
- [37-アーキテクチャの決定](./docs/task/37-アーキテクチャの決定.md)
- [49-dotnet周りのバージョン固定作業](./docs/task/49-dotnet周りのバージョン固定作業.md)

### bug

-
