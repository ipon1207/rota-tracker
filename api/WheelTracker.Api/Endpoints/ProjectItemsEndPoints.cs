using Microsoft.AspNetCore.Http.HttpResults;
using WheelTracker.Api.Data;

namespace WheelTracker.Api.Endpoints;

public static class ProjectItemsEndPoints
{
    public static void RegisterProjectItemsEndPoints(this WebApplication app)
    {
        RouteGroupBuilder projectsItems = app.MapGroup("/api/projects");

        projectsItems.MapGet("/", GetAllProjectsAsync);
    }

    static async Task<Ok<IReadOnlyList<Project>>> GetAllProjectsAsync(ProjectRepository repo) =>
        TypedResults.Ok(await repo.GetAllAsync());
}
