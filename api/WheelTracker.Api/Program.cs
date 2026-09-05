using Microsoft.AspNetCore.Http.HttpResults;
using WheelTracker.Api.Data;

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

app.MapGet("/api/projects", async Task<Results<Ok<Project>, NotFound>> (ProjectRepository repo) =>
    await repo.GetAllAsync()
        is Project project
            ? TypedResults.Ok(project)
            : TypedResults.NotFound()
);

app.Run();
