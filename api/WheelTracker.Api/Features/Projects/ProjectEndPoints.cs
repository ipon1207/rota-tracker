using Microsoft.AspNetCore.Http.HttpResults;

namespace WheelTracker.Api.Features.Projects;

public static class ProjectEndpoints
{
    public static void RegisterProjectItemsEndPoints(this WebApplication app)
    {
        // NOTE: WithTags はScalarのサイドバーでのグループ名になる（未指定だとクラス名が使われる）
        RouteGroupBuilder projectItems = app.MapGroup("/api/projects")
            .WithTags("Projects");

        // WHY: メソッドグループ渡しのハンドラはXMLコメントがOpenAPIに反映されないため、明示的に指定する
        projectItems.MapGet("/", GetAllProjectsAsync)
            .WithName("GetAllProjects")
            .WithSummary("プロジェクト一覧の取得")
            .WithDescription("登録済みプロジェクトをカテゴリ・プロジェクトの表示順で全件返す。該当が0件の場合は空配列を返す。");
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
