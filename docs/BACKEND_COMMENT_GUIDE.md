# バックエンドコメント規約詳細（C# / .NET）

親規約: [コメント規約.md](./COMMENT_GUIDE.md)
対象: C# / .NET / ASP.NET Core / Dapper / SQL Server / Serilog / xUnit

## XMLドキュメントコメントの基本

### 使用するタグ

| タグ | 用途 |
| --- | --- |
| `<summary>` | 何をするかを**1文**で |
| `<remarks>` | 背景（WHY）、前提、注意事項 |
| `<param>` | **型から読めない情報のみ**（単位・境界・null の意味） |
| `<returns>` | 戻り値（順序保証の有無、空の場合の挙動） |
| `<exception>` | 呼び出し側がcatchすべき例外 |
| `<see cref=""/>` / `<see href=""/>` | 型・メンバー参照 / 外部リンク |
| `<inheritdoc/>` | インターフェース・基底クラスから継承 |

### 使用しないタグ

- `<author>` `<date>` `<version>`
- `<c>` `<code>`

### 基本形

```csharp
/// <summary>
/// 指定した評価期間の未提出者を取得
/// </summary>
/// <remarks>
/// WHY: 締切当日の督促メール用に追加（締切を過ぎた期間に対しても呼び出せる）
/// 対象は在籍中の社員のみで、退職者は除外される
/// </remarks>
/// <param name="periodId">
/// 評価期間ID
/// 存在しない場合は空のリストを返す</param>
/// <returns>
/// 未提出者の一覧
/// 順序は保証しない
/// </returns>
/// <exception cref="SqlException">DB接続に失敗した場合</exception>
public async Task<IReadOnlyList<Employee>> GetUnsubmittedAsync(int periodId)
```

### アンチパターン

```csharp
/// <summary>
/// 未提出者を取得する
/// </summary>
/// <param name="periodId">評価期間ID</param>
/// <returns>未提出者のリスト</returns>
public async Task<IReadOnlyList<Employee>> GetUnsubmittedAsync(int periodId)
```

シグネチャを言い換えているだけで、コードを読めばわかる内容しかない

**書けないタグは省く**: 空欄を埋めるために型を日本語訳しない

## `<inheritdoc/>` を基本とする

インターフェース側に契約を書き、実装クラスは1行で継承する

```csharp
public interface IEvaluationRepository
{
    /// <summary>指定した評価期間の未提出者を取得する</summary>
    /// <param name="periodId">
    /// 評価期間ID
    /// 存在しない場合は空のリストを返す
    /// </param>
    /// <returns>
    /// 未提出者の一覧
    /// 順序は保証しない
    /// </returns>
    Task<IReadOnlyList<Employee>> GetUnsubmittedAsync(int periodId);
}

public sealed class EvaluationRepository : IEvaluationRepository
{
    /// <inheritdoc/>
    /// <remarks>
    /// NOTE: 1クエリで全件取得するため、対象者が数万件規模になるとメモリを圧迫する
    /// 現行の想定は最大3,000件
    /// </remarks>
    public async Task<IReadOnlyList<Employee>> GetUnsubmittedAsync(int periodId)
}
```

- 実装固有の注意がある場合のみ、`<inheritdoc/>` に続けて `<remarks>` を足す
- `<summary>` を実装側で書き直さない（修正はインターフェース側で行う）

## DTO / レコード / エンティティ

プロパティ単位に `<summary>` を書く

**単位と null の意味は型から読めないため必須**とする

```csharp
public sealed record EvaluationScore
{
    /// <summary>
    /// 評価点
    /// 0〜100の整数
    /// 境界値を含む
    /// </summary>
    public int Score { get; init; }

    /// <summary>
    /// 確定日時（UTC）
    /// null は「未確定」を意味する
    /// 対象外は <see cref="IsExcluded"/> で表現する
    /// </summary>
    public DateTime? ConfirmedAt { get; init; }
}
```

必ず書く項目:

- **単位**（円 / 秒 / パーセント / UTCかローカルか）
- **境界**（包含か排他か）
- **null の意味**（未設定 / 対象外 / 未取得 のどれか）
- **不変条件**（「このリストは必ず1件以上」など）

## 静的解析で辿れない依存

**Find All References が0件に見えるが実際は使われている**もの、および**リネームがコンパイルエラーにならない**ものは必ず書く

### Dapper でマップされるクラス

```csharp
/// <summary>
/// 未提出者一覧のクエリ結果
/// </summary>
/// <remarks>
/// NOTE: Dapper が SQL の列名とプロパティ名で自動マッピングする
/// プロパティ名の変更はコンパイルエラーにならず、実行時に既定値が入る
/// 変更する場合は GetUnsubmitted.sql の SELECT 句も同時に修正すること
/// </remarks>
public sealed class UnsubmittedRow
```

### DI コンテナ経由でのみ解決される型

```csharp
/// <remarks>
/// NOTE: Program.cs で IEvaluationRepository として登録される
/// 直接 new される箇所はない
/// </remarks>
```

### リフレクション / シリアライザ経由で使われるメンバー

未使用に見えるコンストラクタ・プロパティ・setterには、誰が使っているかを書く

### 数値として永続化される列挙型

不可逆な決定のため、DESIGN_NOTES への記録対象

```csharp
/// <summary>
/// 評価ステータス
/// </summary>
/// <remarks>
/// 禁止: DBに int として保存されるため、順序の変更・値の再割当を行わないこと
/// 新しい状態は必ず末尾に追加する
/// 既存コードに status >= InProgress の数値比較への依存がある
/// 詳細は docs/DESIGN_NOTES.md「EvaluationStatus」を参照
/// </remarks>
public enum EvaluationStatus
{
    NotStarted = 0,
    InProgress = 1,
    Submitted = 2,
}
```

## 抑止コメント

`#pragma warning disable` / `#nullable disable` / `[SuppressMessage]` には、**理由と解除条件**を併記する

```csharp
// HACK: 旧システムから移行した列が nullable のままのため、一時的に警告を抑止する
// 解除条件: マイグレーション #456 完了後
#pragma warning disable CS8618
```

- 抑止範囲は必要最小限にし、`#pragma warning restore` で必ず閉じる
- ファイル冒頭や `.csproj` 全体での抑止は原則禁止。行う場合は、抑止箇所に理由と解除条件を書く

## 領域別の指針

### エンドポイント

- 認可要件、想定ステータスコード、冪等性の有無を `<remarks>` に書く
- リクエスト・レスポンスの形は型とOpenAPIスキーマが持つため、繰り返さない

```csharp
/// <summary>評価を提出する</summary>
/// <remarks>
/// 認可: 本人のみ（管理者による代理提出は別エンドポイント）
/// 二重POSTで提出履歴が2件作られるため、UI側で多重送信を防ぐこと
/// </remarks>
```

### 6.2 SQL / クエリ

- SQLファイルまたはクエリ文字列の直前に、**なぜこの書き方なのか**を書く
- インデックスヒント、`WITH (NOLOCK)`、`OPTION (RECOMPILE)` などは理由の記載を必須とする
- クエリの内容そのものを日本語訳しない

```csharp
// WHY: パラメータスニッフィングにより期間IDによって実行プランが極端に劣化するため、
//      OPTION (RECOMPILE) を付与している
```

### 6.3 トランザクション境界

呼び出し側との契約になるため、**誰がトランザクションを開始し、誰がロールバックするか**を書く

```csharp
/// <remarks>
/// 前提: 呼び出し側がトランザクションを開始していること
/// 本メソッドは Commit / Rollback を行わない
/// 例外は上位レイヤーで処理される
/// </remarks>
```

### 6.4 ログ（Serilog）

- ログメッセージ自体が「何が起きたか」を説明しているため、その横に同じ内容のコメントを書かない
- 構造化ログのプロパティ名を外部の監視基盤やアラート定義が参照している場合のみ書く

```csharp
// NOTE: プロパティ名 "EvaluationPeriodId" は監視ダッシュボードのクエリで参照している
//       変更する場合はダッシュボード定義も更新する
```

### 6.5 テスト（xUnit）

- テストメソッド名で What を表現し、`<summary>` は原則不要
- **書くべきは「なぜこのケースを守る必要があるか」**

```csharp
// WHY: 締切時刻ちょうどの提出が弾かれる不具合
// 境界は「以下」で包含
[Fact]
public async Task 締切時刻ちょうどの提出は受理される()
```

- モックが必要な理由が自明でない場合は書く（外部課金が発生する、など）
- `Skip` を指定する場合は、理由と解除条件を必須とする

```csharp
[Fact(Skip = "CI環境にSQL Serverが未構築のため")]
```
