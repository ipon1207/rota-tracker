using Microsoft.Data.SqlClient;

namespace WheelTracker.Api.Data;

/// <summary>
/// SqlConnectionのファクトリクラス
/// </summary>
/// <param name="configuration">アプリケーションの設定情報</param>
public sealed class SqlConnectionFactory(IConfiguration configuration)
{
    private readonly string _connectionString =
        configuration.GetConnectionString("RotaTracker")
        ?? throw new InvalidOperationException("接続文字列 RotaTracker が設定されていません");

    /// <summary>
    /// 接続を生成する
    /// </summary>
    /// <returns>データベース接続インスタンス</returns>
    public SqlConnection Create() => new(_connectionString);
}
