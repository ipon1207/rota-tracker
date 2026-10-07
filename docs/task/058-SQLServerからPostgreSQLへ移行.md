# SQL Server から PostgreSQL へ移行

## 目的

RaspberryPiでRotaTrackerをホスティング？したい

しかし、RaspberryPiは **ARM64** アーキテクチャのため、SQL Serverが動作しない（dotnetは動作するらしい）

そのため、PostgreSQLに移行することで実現可能にする（副産物として、テーブル定義の幅が広がる）

## `docker-compose.yaml` の書き換え

```yaml
services:
  db:
    image: postgres:18
    container_name: rota-tracker-db
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
      POSTGRES_DB: "rota_tracker"
    ports:
      - "54320:5432"
    volumes:
      # NOTE: postgres 18 以降のイメージはデータを /var/lib/postgresql/<メジャー>/docker に置くため、親ディレクトリにマウントする
      - pg-data:/var/lib/postgresql
      # NOTE: ボリュームが空の初回起動時だけ、ファイル名順 (schema → seed) に実行される
      - ./schema.sql:/docker-entrypoint-initdb.d/01-schema.sql:ro
      - ./seed.sql:/docker-entrypoint-initdb.d/02-seed.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d rota_tracker || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

volumes:
  pg-data:
```

## `scheam.sql` の型の置き換え

- [3.3. 文字データ型](https://www.postgresql.jp/document/7.2/user/datatype-character.html)
- [5.3. 識別列](https://www.postgresql.jp/docs/17/ddl-identity-columns.html)
- [8.6. 論理値データ型](https://www.postgresql.jp/docs/9.4/datatype-boolean.html)

| SQL Server | PostgreSQL |
| --- | --- |
| `NVARCHAR(n)` | `VARCHAR(n)` |
| `NVARCHAR(MAX)` | `TEXT` |
| `INT IDENTITY` | `INT GENERATED ALWAYS AS IDENTITY` |
| `DATETIME2 DEFAULT SYSUTCDATETIME()` | `TIMESTAMPTZ DEFAULT AS now()` |
| `BIT` | `BOOLEAN` |

- `TEXT`: **制限無し可変長文字列**
- `GENERATED ALWAYS AS IDENTITY`: **自動的に値が生成される特殊な列**
- `TIMESTAMPTZ DEFAULT AS now()`: **現在時刻をデフォルト値として使用**
- `BOOLEAN`: **真偽値を取る** (`TRUE`, `'t'`, `'false'`, `'no'`...)

## APIのパッケージ差し替え

C#で利用していた `Microsoft.Data.SqlClient` から `Npgsql 10.0.03` に差し替え

`SqlConnectionFactory.cs` と `ProjectRepository.cs` を書き換え

```diff
- using Microsoft.Data.SqlClient;
+ using Npgsql;

...

- public SqlConnection Create() => new(_connectionString);
+ public NpgsqlConnection Create() => new(_connectionString);

...

- using SqlConnection connection = factory.Create();
+ using NpgsqlConnection connection = factory.Create();
```
