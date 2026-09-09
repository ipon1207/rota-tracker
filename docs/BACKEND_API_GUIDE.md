# バックエンドAPI設計指針（HTTP契約）

関連: [コメント規約](./COMMENT_GUIDE.md) / [バックエンドコメント規約詳細](./BACKEND_COMMENT_GUIDE.md) / [バックエンドアーキテクチャ](./task/37-バックエンドアーキテクチャ.md)
対象: ASP.NET Core Minimal API / OpenAPI / System.Text.Json / openapi-typescript

## 前提

- エンドポイントは Minimal API で定義する
- APIの利用者は `web/` のみ
- 認証は当面持たない
- 契約は機械的にフロントへ伝播する

  `C#の型・XMLコメント` → `api/WheelTracker.Api/OpenAPISchema/WheelTracker.Api.json` → `web/src/lib/api/schema.gen.ts`

バックエンドで決めたプロパティ名・null許容・説明文は、そのままフロントの型とJSDocになる

### APIは不可逆な決定である

[コメント規約](./COMMENT_GUIDE.md) の MUST 1 が「外部公開APIの契約」を不可逆な決定として挙げている

エンドポイントが増えてから形を変えると、フロントの実装と生成物の両方を壊す

エンドポイントが**少ないうちに形を決める**

### 判断基準

迷ったら、この2つで判定する

1. **生成された `schema.gen.ts` を見たとき、素直に使える形か？**
2. **後から変えるとフロントが壊れるか？** → 壊れるなら、いま決める

## 1. URL とリソース設計

1. **パスは `/api/` で始め、リソース名は複数形にする**

    `/api/projects` `/api/entries` `/api/glossary-terms`

2. **小文字で書き、複数語はケバブケースにする**

    C#の識別子は PascalCase だが、URLには持ち込まない

3. **URLに動詞を入れない**

    操作は2章のHTTPメソッドで表す

4. **階層は所有関係のみとし、原則2階層までとする**

    `/api/entries/{projectId}/steps/{stepNo}` は「記録に属するステップ」なので許容する
    関連しているだけのリソースをネストしない

5. **パスパラメータは識別子に限る**

    絞り込み・並び替え・検索はクエリ文字列で受ける

### アンチパターン

| 書き方 | 何が問題か |
| --- | --- |
| `/api/getProjects` | 動詞がURLに入っている |
| `/api/project` | 単数形。1件を指すのか集合を指すのか読めない |
| `/api/projects/todo` | 状態を階層で表している |
| `/api/categories/{id}/projects/{id}/guide/steps` | 3階層になっている |

### グループとクラスの命名

`MapGroup` 1つがリソース1つに対応する（登録の書き方は [バックエンドアーキテクチャ](./task/37-バックエンドアーキテクチャ.md) を参照）

**綴りは `Endpoints` で統一する**

クラス名はOpenAPIの `tags` の既定値になるため、表記揺れが契約に漏れる

## 2. HTTP メソッドの選択

| メソッド | 使う場面 | 安全 | 冪等 |
| --- | --- | --- | --- |
| `GET` | 取得。副作用を持たせない | ○ | ○ |
| `POST` | **サーバが識別子を決める**新規作成 | × | × |
| `PUT` | 識別子が既知の作成・全体更新（upsert） | × | ○ |
| `PATCH` | 一部の項目だけの更新 | × | ○ |
| `DELETE` | 削除。2回目も同じ結果を返す | × | ○ |

### POST は識別子をサーバが決めるときだけ使う

本アプリの主キーは `project_id` のような**自然キー**で、クライアントが最初から知っている

したがって記録の保存は `POST /api/entries` ではなく **`PUT /api/entries/{projectId}` による upsert** を基本とする

`glossary_term` のように `IDENTITY` で採番される行を作る場合のみ POST を使う

### PATCH を別のエンドポイントに切る基準

**更新頻度とUXが本体の保存と違うとき**に分ける

| エンドポイント | 想定する操作 |
| --- | --- |
| `PUT /api/entries/{projectId}` | 記録フォームの保存（複数項目をまとめて送る） |
| `PATCH /api/entries/{projectId}/status` | 一覧の行クリック1発（楽観的更新を効かせる） |

前者は保存ボタンを押したときだけ、後者は一覧を触るたびに飛ぶ

同じ `PUT` にまとめると、ステータスを変えるたびにフォーム全体を送ることになる

### 状態遷移に伴う副次的な更新はサーバの責務とする

`status` を `done` にしたときの `done_date` の自動セットのような処理は、クライアントに書かせない

ルールがクライアント側に散ると、xUnitで検証する対象がなくなる

## 3. ステータスコードと戻り値の型

### `TypedResults` を必ず使う

**戻り値の型に `IResult` を書かず、`Results` クラスも使わない**

`TypedResults` と具体的な戻り値型の組み合わせでのみ、OpenAPIにレスポンスのスキーマが出力される

```csharp
// 基本形
static async Task<Ok<IReadOnlyList<Project>>> GetAllProjectsAsync(ProjectRepository repo) =>
    TypedResults.Ok(await repo.GetAllAsync());
```

```csharp
// アンチパターン
static async Task<IResult> GetAllProjectsAsync(ProjectRepository repo) =>
    Results.Ok(await repo.GetAllAsync());
```

`IResult` からは返す型が読み取れないため、OpenAPIのレスポンスが空になり、フロントの型が使いものにならなくなる

### 状況と型の対応

| 状況 | 型 | 返るコード |
| --- | --- | --- |
| 一覧を返す（0件もあり得る） | `Ok<IReadOnlyList<T>>` | 200 |
| 単一を返す（存在しないことがある） | `Results<Ok<T>, NotFound>` | 200 / 404 |
| 識別子既知の作成・更新（upsert） | `Results<Ok<T>, ValidationProblem>` | 200 / 400 |
| 一部の項目の更新 | `Results<Ok<T>, ValidationProblem, NotFound>` | 200 / 400 / 404 |
| サーバ採番の新規作成 | `Results<Created<T>, ValidationProblem>` | 201 / 400 |
| 削除 | `Results<NoContent, NotFound>` | 204 / 404 |

### 一覧が0件でも404にしない

**200 と空配列**を返す

「該当が0件」と「エンドポイントが存在しない」は別の事実で、フロント側の分岐も変わる

空配列が何を意味するかは型から読めないため、`<returns>` に書く（[バックエンドコメント規約詳細](./BACKEND_COMMENT_GUIDE.md) 3章）

### 201 を返すのは採番したときだけ

`PUT` による upsert は、作成でも更新でも **200 とリソース本体**を返す

クライアントは自分が送った識別子を既に知っているため、`Location` ヘッダに価値がない

### エンドポイントで例外を握りつぶさない

**`try/catch` して500を組み立てない**

DB接続の失敗のような障害は、5章の例外ハンドラに任せる

## 4. リクエスト / レスポンスの形

### トップレベルに配列を返してよい

**一覧を `{ items: [...] }` で包まない**

包むと生成される型が `{ items: Project[] }` になり、利用側が毎回 `.items` を剥がすことになる

ページングやメタデータが必要になった時点で、そのエンドポイントだけ形を変える

### プロパティ名は camelCase にする

`System.Text.Json` の既定に任せ、**個別に `[JsonPropertyName]` を付けない**

C#側の `CategoryId` は `categoryId` として出力され、フロントでの手動マッピングは不要になる

### レスポンス用の型を切る基準

DBの行と形が同じなら、既存の record をそのまま返す

次のいずれかに当てはまるときだけ、別の record を作る

- 複数テーブルの結果を1つにまとめる
- 内部でしか使わない列（`sort_order` など）を隠す
- 集計値のように、どのテーブルにも対応しない形になる

命名は、リクエストが `<動詞><リソース>Request`、レスポンス専用の型が `<リソース>Response` とする

### `<param>` に列名を書かない

record のXMLコメントは、OpenAPIの `description` を経て**フロントのJSDocになる**

列名の再掲は、フロントの読み手に何も伝えない

```csharp
// 基本形
/// <param name="Difficulty">
/// 難易度
/// 1〜3の整数（1が易しい）
/// null は「未設定」を意味する
/// </param>
```

```csharp
// アンチパターン
/// <param name="Difficulty">difficulty</param>
```

書く内容は [バックエンドコメント規約詳細](./BACKEND_COMMENT_GUIDE.md) 3章と同じく、**単位・境界・null の意味・不変条件**

### 日付と時刻

| DBの型 | JSONでの形 | 対象 |
| --- | --- | --- |
| `DATE` | `yyyy-MM-dd` の文字列。タイムゾーンを持たせない | `start_date` `done_date` |
| `DATETIME2` | ISO 8601 のUTC | `updated_at` |

ローカル時刻をそのまま返さない

### null の意味を揃える

**`null` は「値がない」を意味する**

「まだ取得していない」はAPI側では表現しない。フロント側の `undefined` が担う（[フロントエンドコメント規約詳細](./FRONTEND_COMMENT_GUIDE.md) 2章）

`null` に複数の意味を持たせない。「未設定」と「対象外」を区別する必要が出たら、別のプロパティで表す

## 5. エラーの表現

### ProblemDetails に統一する

RFC 9457 の ProblemDetails を使い、`Program.cs` に次を登録する

```csharp
builder.Services.AddProblemDetails();

// app.Build() の後
app.UseExceptionHandler();
```

検証エラーは `TypedResults.ValidationProblem` を使う。項目ごとのエラーが `errors` に入る形が標準で得られる

### 業務上の失敗と障害を混ぜない

| 種類 | 例 | 返し方 |
| --- | --- | --- |
| 業務上の失敗 | 存在しない `projectId`、着手日 > 完了日 | エンドポイントが 4xx を返す |
| 障害 | DB接続の失敗、SQLの構文エラー | 例外のまま投げ、ハンドラが 500 にする |

**障害を4xxに丸めない**。異常として観測できなくなる

### エラー本文に内部情報を載せない

`detail` に書くのは、呼び出し側が次に何をすべきか判断できる情報だけとする

### メッセージの言語と責務

`title` / `detail` は日本語で書く

ただし**画面にそのまま表示する文言としては書かない**。表示文言はフロントの責務とし、APIは原因を識別できる情報を返す

## 6. OpenAPI への反映

出力は `.csproj` の `OpenApiDocumentsDirectory` と `GenerateDocumentationFile` により、ビルド時に行われる

### `.WithName()` と `.WithSummary()` を必須とする

```csharp
projects.MapGet("/", GetAllProjectsAsync)
    .WithName("GetAllProjects")
    .WithSummary("登録済みプロジェクトを全件取得");
```

- `.WithName()` が `operationId` になる。付けないと `schema.gen.ts` の `operations` が空のままになり、型をパス文字列でしか引けない
- `.WithSummary()` が operation の説明になる

**ハンドラメソッドの `<summary>` はOpenAPIに反映されない**

XMLコメントが `description` になるのは**型とプロパティ**の階層だけで、operation の階層には届かない

ハンドラに `<summary>` を書くこと自体はコメント規約が求めるが、それとは別に `.WithSummary()` が要る

### `MapGroup` に `.WithTags()` を付ける

```csharp
RouteGroupBuilder projects = app.MapGroup("/api/projects").WithTags("Projects");
```

付けないとクラス名がそのままタグ名になり、`Endpoints` のような実装都合の語が契約に漏れる

### 生成物の扱い

- **`WheelTracker.Api.json` と `schema.gen.ts` を手で編集しない**
- エンドポイントを変えたら `npm run gen:api` を実行し、**両方の差分を同じPRに含める**

PRテンプレートのセルフチェック「API を変更した → OpenAPI を出力し直し、`openapi-typescript` で型を再生成した」がこれにあたる

## 7. 強制の手段

| 対象 | 手段 | 初期設定 |
| --- | --- | --- |
| 命名・整形 | `.editorconfig` ＋ pre-commit の `dotnet format --verify-no-changes` | 警告のまま運用 |
| ドキュメントコメントの欠落 | CS1591（`GenerateDocumentationFile`） | 警告のまま運用 |
| 依存の向き | ArchUnitNET | #43 で導入予定 |
| 型の再生成漏れ | PRテンプレートのセルフチェック | 運用中 |
| URL・メソッド・ステータスコードの選択 | AIレビュー + 人間のレビュー | ― |

### AIレビューに渡す観点

- URLに動詞が入っていないか / リソース名が複数形か
- メソッドの選択が冪等性と合っているか
- 戻り値が `TypedResults` と具体型の組み合わせになっているか
- 0件を404で返していないか
- `<param>` が列名や型の日本語訳になっていないか
- `.WithName()` / `.WithSummary()` / `.WithTags()` が付いているか
- エンドポイントの変更に対して、生成物の差分が同じPRに含まれているか
