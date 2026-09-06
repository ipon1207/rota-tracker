using Microsoft.AspNetCore.Http.HttpResults;
using WheelTracker.Api.Data;

namespace WheelTracker.Api.Endpoints;

public static class ProjectItemsEndpoints
{
    public static void RegisterProjectItemsEndPoints(this WebApplication app)
    {
        RouteGroupBuilder projectItems = app.MapGroup("/api/projects");

        projectItems.MapGet("/", GetAllProjectsAsync);
    }

    /// <summary>
    /// 登録済みプロジェクトを全件取得
    /// </summary>
    /// <returns>
    /// プロジェクトの一覧
    /// 該当が0件の場合は空配列を返す
    /// </returns>
    static async Task<Ok<IReadOnlyList<Project>>> GetAllProjectsAsync(ProjectRepository repo) =>
        TypedResults.Ok(await repo.GetAllAsync());
}
