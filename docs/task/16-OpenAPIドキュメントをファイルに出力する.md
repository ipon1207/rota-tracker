# OpenAPIドキュメントをファイルに出力する

## Microsoft.Extensions.ApiDescription.Server

- [Microsoft.Extensions.ApiDescription.Server](https://www.nuget.org/packages/microsoft.extensions.apidescription.server/)
- [OpenAPI ドキュメントを生成する](https://learn.microsoft.com/ja-jp/aspnet/core/fundamentals/openapi/aspnetcore-openapi?view=aspnetcore-10.0&tabs=visual-studio%2Cvisual-studio-code)

### 導入方法

```bash
dotnet add package Microsoft.Extensions.ApiDescription.Server
```

### YAML形式でOpenAPIドキュメントを生成する

```C#:Program.cs
app.MapOpenApi("/openapi/{documentName}.yaml");
```

`{documentName}` はドキュメント名を指定

### ビルド時にOpenAPIドキュメントを生成する

```bash
dotnet build
cat obj/{ProjectName}.json
```

該当プロジェクトの `obj` フォルダ内に生成される

### 生成されたOpenAPIファイルの出力ディレクトリを変更する

`.` を指定するプロジェクトファイル (`.csproj`) と同じディレクトリにOpenAPIドキュメントが出力される

```XML:WheelTracker.Api.csproj
<PropertyGroup>
  <OpenApiDocumentsDirectory>.</OpenApiDocumentsDirectory>
</PropertyGroup>
```

### 出力ファイル名を変更する

```XML:WheelTracker.Api.csproj
<PropertyGroup>
  <OpenApiGenerateDocumentsOptions>--file-name my-open-api</OpenApiGenerateDocumentsOptions>
</PropertyGroup>
```
