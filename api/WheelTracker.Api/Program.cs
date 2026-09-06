using WheelTracker.Api.Data;
using WheelTracker.Api.Endpoints;

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
}

app.UseHttpsRedirection();

app.RegisterProjectItemsEndPoints();

app.Run();
