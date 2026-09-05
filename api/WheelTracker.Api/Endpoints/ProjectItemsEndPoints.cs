using Microsoft.AspNetCore.Http.HttpResults;
using WheelTracker.Api.Data;

namespace WheelTracker.Api.Endpoints;

public static class ProjectItemsEndPoints
{
    public static void RegisterProjectItemsEndPoints(this WebApplication app)
    {
        app.MapGet("/api/projects", async Task<Ok<IReadOnlyList<Project>>> (ProjectRepository repo) =>
            TypedResults.Ok(await repo.GetAllAsync())
        );
    }
}
