namespace WheelTracker.Api.Data;

/// <summary>
/// Projectテーブルのレコード構造
/// </summary>
/// <param name="Id">id</param>
/// <param name="CategoryId">category_id</param>
/// <param name="Title">title</param>
/// <param name="Difficulty">difficulty</param>
public record Project(
    string Id,
    string CategoryId,
    string Title,
    int? Difficulty
);
