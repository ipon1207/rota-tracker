# Scalarの導入・セットアップ

- [Minimal API で OpenAPI / Scalar を利用する方法](https://aspnet.keicode.com/minimalapi/minimalapi-how-to-use-openapi-scalar.php)

## パッケージの追加

`.csproj` があるディレクトリで以下を実行

```bash
dotnet package add Scalar.AspNetCore
```

## Minimal API で最小構成

- `builder.Services.AddOpenApi()`
- `app.MapOpenApi()`
- `app.MapScalarApiReference()`

```CSharp:Program.cs
using Scalar.AspNetCore;
using WheelTracker.Api.Features.Projects;
using WheelTracker.Api.Infrastructure;

// WHY: DB側の列名が snake_case のため、PascalCase のプロパティへ自動マッピングさせる
// NOTE: アプリ全体に効くグローバル設定
//       プロパティ名を変更するとコンパイルエラーにならず、実行時に既定値が入る
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

builder.Services.AddSingleton<SqlConnectionFactory>();
builder.Services.AddScoped<ProjectRepository>();

WebApplication app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();

app.RegisterProjectItemsEndPoints();

app.Run();
```
