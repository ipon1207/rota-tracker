using Dapper;
using Microsoft.Data.SqlClient;

namespace WheelTracker.Api.Data;

/// <summary>
/// projectテーブルのデータアクセスクラス
/// </summary>
/// <param name="factory">データベース接続インスタンスファクトリ</param>
public sealed class ProjectRepository(SqlConnectionFactory factory)
{
    /// <summary>
    /// 全件取得（表示順に並べて返す）
    /// </summary>
    /// <returns>projectエンティティ</returns>
    public async Task<IReadOnlyList<Project>> GetAllAsync()
    {
        const string sql = """
            SELECT
                 project.id
                ,project.category_id
                ,project.title
                ,project.difficulty
            FROM
                project
            JOIN
                category
            ON
                category.id = project.category_id
            ORDER BY
                category.sort_order, project.sort_order
        """;

        using SqlConnection connection = factory.Create();
        IEnumerable<Project> rows = await connection.QueryAsync<Project>(sql);
        return [.. rows];
    }
}
