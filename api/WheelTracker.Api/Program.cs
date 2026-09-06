using WheelTracker.Api.Data;
using WheelTracker.Api.Endpoints;

// 列名とRecorのプロパティ名と一致させるための設定
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddSingleton<SqlConnectionFactory>();
builder.Services.AddScoped<ProjectRepository>();

WebApplication app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.RegisterProjectItemsEndPoints();

app.Run();
