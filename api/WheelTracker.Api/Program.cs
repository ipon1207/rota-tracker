using System.Text.Json.Serialization;
using Scalar.AspNetCore;
using WheelTracker.Api.Features.Projects;
using WheelTracker.Api.Infrastructure;

// WHY: DB側の列名が snake_case のため、PascalCase のプロパティへ自動マッピングさせる
// NOTE: アプリ全体に効くグローバル設定
//       プロパティ名を変更するとコンパイルエラーにならず、実行時に既定値が入る
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// NOTE: Scalar のページ見出しと概要になる
builder.Services.AddOpenApi(options => options.AddDocumentTransformer((document, _, _) =>
{
    document.Info.Title = "WheelTracker API";
    document.Info.Description = "車輪の再発明（既存ツールやライブラリの自作）に取り組むプロジェクトと、その進捗を記録・参照するためのAPI";
    return Task.CompletedTask;
}));

// APIが受け取るJSONの型を厳格化
builder.Services.ConfigureHttpJsonOptions(options => options.SerializerOptions.NumberHandling = JsonNumberHandling.Strict);
builder.Services.AddSingleton<SqlConnectionFactory>();
builder.Services.AddScoped<ProjectRepository>();

WebApplication app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    // NOTE: UIは /scalar で開ける（開発環境のみ）
    app.MapScalarApiReference(options => options.WithTitle("WheelTracker API"));
}

app.UseHttpsRedirection();

app.RegisterProjectItemsEndPoints();

app.Run();
