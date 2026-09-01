# SQL Serverへの接続を確立する

## user-secretsに接続文字列を設定する

- [【.NET】 ユーザーシークレット 学習メモ — 仕組みからアクセスパターンまで](https://zenn.dev/rendya/articles/dotnet-user-secrets-note)

### 初期化

```bash
dotnet user-secrets init
```

### 追加・更新

専用の `update` コマンドはなく、`set` が追加と更新を兼ねる
既存キーに `set` を実行すると上書きされる

```bash
dotnet user-secrets set "Api:Key" "my-secret-key"
dotnet user-secrets set "Api:BaseUrl" "https://api.example.com"
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Server=...;Password=secret"
```

### 一覧表示

```bash
dotnet use-secrets list
```

### 削除

```bash
dotnet user-secrets remove "Api:Key"
# 全削除
dotnet user-secrets clear
```

※ **開発専用の仕組みであることに留意する**

## 接続文字列の項目

- `Server` (`Data Source` / `Addr`): サーバー名を指定、ポートを変えている場合はカンマ区切りで指定、名前付きインスタンスならバックスラッシュで `HOST\SQLEXPRESS` と指定する
- `Database` (`Initialize Catalog`): 接続直後に使うデータベース（省略すると既定のデータベース）
- `Integrated Security=true` (`Trusted_Connection=true`): Windows認証、ユーザー名もパスワードも不要になる
- `User Id` / `Password`: SQLログイン
- `Authentication`: Entra IDなど、新しい認証方式を選択した場合に使う
- `Encrypt`: 通信を暗号化するか（`Microsoft.Data.SqliClient 4.0` 以降は既定で `true`）
- `TrustedServerCertificate`: サーバー証明書の発行元を検証するか、trueで検証をスキップする
- `Host Name In Certificate`: 証明書の名前と接続先が食い違う場合に正しい名前を指定する
- `ApplicationName`: 接続元の名前、SQL Server側のログや `sys.dm_exec_sessions` に出力されるようになる

## API叩いたらエラー出た

```PlainText
warn: Microsoft.AspNetCore.HttpsPolicy.HttpsRedirectionMiddleware[3]
      Failed to determine the https port for redirect.
fail: Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddleware[1]
      An unhandled exception has occurred while executing the request.
      System.InvalidOperationException: A parameterless default constructor or one matching signature (System.String id, System.String category_id, System.String title, System.Byte difficulty) is required for WheelTracker.Api.Data.Project materialization
         at Dapper.SqlMapper.GenerateDeserializerFromMap(Type type, DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing, ILGenerator il) in /_/Dapper/SqlMapper.cs:line 3528
         at Dapper.SqlMapper.GetTypeDeserializerImpl(Type type, DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing) in /_/Dapper/SqlMapper.cs:line 3359
         at Dapper.SqlMapper.TypeDeserializerCache.GetReader(DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing) in /_/Dapper/SqlMapper.TypeDeserializerCache.cs:line 151
         at Dapper.SqlMapper.TypeDeserializerCache.GetReader(Type type, DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing) in /_/Dapper/SqlMapper.TypeDeserializerCache.cs:line 50
         at Dapper.SqlMapper.GetTypeDeserializer(Type type, DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing) in /_/Dapper/SqlMapper.cs:line 3313
         at Dapper.SqlMapper.GetDeserializer(Type type, DbDataReader reader, Int32 startBound, Int32 length, Boolean returnNullIfFirstMissing) in /_/Dapper/SqlMapper.cs:line 1978
         at Dapper.SqlMapper.QueryAsync[T](IDbConnection cnn, Type effectiveType, CommandDefinition command) in /_/Dapper/SqlMapper.Async.cs:line 442
         at WheelTracker.Api.Data.ProjectRepository.GetAllAsync() in C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Api\Data\ProjectRepository.cs:line 35
         at Program.<>c.<<<Main>$>b__0_0>d.MoveNext() in C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Api\Program.cs:line 25
      --- End of stack trace from previous location ---
         at Microsoft.AspNetCore.Http.RequestDelegateFactory.<ExecuteTaskOfT>g__ExecuteAwaited|134_0[T](Task`1 task, HttpContext httpContext, JsonTypeInfo`1 jsonTypeInfo)
         at Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddlewareImpl.Invoke(HttpContext context)
```

projectテーブルの difficulty カラムの型が `TINYINT` だったので、C#でも `int` ではなく `byte` で受け取る必要があるらしい

→ `byte` をプログラム側で扱うのは面倒なので、スキーマの方を `INT` に変える
