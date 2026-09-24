namespace WheelTracker.Api.Features.Projects;

/// <summary>
/// 車輪の再発明として取り組むプロジェクト（自作 ls コマンド、JSONパーサなど）
/// </summary>
/// <param name="Id">
/// プロジェクトを一意に識別するID
/// 例: cli-ls
/// </param>
/// <param name="CategoryId">
/// 所属するカテゴリのID
/// 例: cli
/// </param>
/// <param name="Title">
/// プロジェクトの名前
/// 例: 自作 ls コマンド
/// </param>
/// <param name="Difficulty">
/// 難易度
/// 1〜3の整数（1が易しい、3が難しい）
/// null は「未設定」を意味する
/// </param>
public record Project(
    string Id,
    string CategoryId,
    string Title,
    int? Difficulty
);
