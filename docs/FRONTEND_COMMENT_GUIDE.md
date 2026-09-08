# フロントエンドコメント規約詳細（TypeScript / React）

親規約: [コメント規約.md](./COMMENT_GUIDE.md)
対象: TypeScript / React / React Router / TanStack Query / TanStack Table / Zod / openapi-typescript / Tailwind CSS / Base UI / shadcn/ui / Oxlint / Vitest / Playwright

## TSDocの基本

### 使用するタグ

| タグ | 用途 |
| --- | --- |
| `@param` | **型から読めない情報のみ**（単位・境界・null / undefined の意味） |
| `@returns` | 戻り値（空配列の意味、順序保証の有無） |
| `@throws` | 呼び出し側が処理すべき例外 |
| `@see` | Issue / 仕様書 / `DESIGN_NOTES` への参照 |
| `@deprecated` | 非推奨（**代替手段を必ず併記する**） |
| `@example` | 引数が複雑で、使用例がないと誤用されうる場合のみ |

### 使用しないタグ

- `@type` `@typedef` などの型注釈
- `@author` `@date`

### 基本形

```ts
/**
 * カートの金額を集計し、ユーザーへ請求する最終金額を返す
 *
 * WHY: 値引き・キャンペーンは applyCampaign 側で適用済みである前提
 *      本関数は課税のみを行う
 *
 * @param cart 集計対象のカート（items が空の場合は 0 を返す）
 * @returns 請求額（税込・円・整数、端数は切り捨て）
 * @throws {TaxRateNotFoundError} 対象日の税率が未登録の場合
 */
export function calculateTotalPrice(cart: Cart): number
```

- 1行目は要約1文
- 背景（WHY）はタグの外に書く
- タグ欄は契約のみ

### アンチパターン

```ts
/**
 * カートの合計金額を計算する
 *
 * @param cart カート
 * @returns 合計金額
 */
export function calculateTotalPrice(cart: Cart): number
```

シグネチャを言い換えているだけで、コードを読めばわかる内容しかない

**書けないタグは省く**: 空欄を埋めるために引数名を日本語訳しない

## 型定義

型から読めない情報だけを書く

**単位・境界・`null` と `undefined` の意味の違い**が対象

```ts
export type Evaluation = {
  /** 評価点（0〜100の整数、境界値を含む） */
  score: number;

  /**
   * 確定日時（ISO 8601 / UTC）
   * null は「未確定」、undefined は「APIから未取得」を意味する
   */
  confirmedAt?: string | null;
};
```

### 数値として永続化される union type

不可逆な決定のため、DESIGN_NOTES への記録対象

```ts
/**
 * 評価ステータス
 *
 * 禁止: バックエンドでは int（0,1,2）として保存されるため、順序の変更・値の再割当を行わないこと
 * 新しい状態は必ず末尾に追加する
 * TypeScript上は string union のため、順序を入れ替えても型エラーにならない
 */
export type EvaluationStatus = 'notStarted' | 'inProgress' | 'submitted';
```

## React コンポーネント

- **propsの説明はProps型側に書く**
- **コンポーネント本体には「何のためのUIか」だけを書く**

両方に書くと必ず片方が腐る

```ts
type UserTableProps = {
  /** 表示対象（undefined はロード中、空配列は「該当0件」を意味する） */
  users: User[] | undefined;

  /** 行クリック時のハンドラ（未指定の場合、行は非活性で表示される） */
  onRowClick?: (user: User) => void;
};

/**
 * 評価対象者の一覧テーブル
 *
 * WHY: 管理者画面と本人画面で共用する（表示列の出し分けは呼び出し側で行う）
 */
export function UserTable({ users, onRowClick }: UserTableProps)
```

### 書くもの

- `undefined` / 空配列 / `null` の意味の違い
- 省略時のフォールバック挙動
- 呼び出し側に課す前提（Provider配下で使うこと、など）

### 書かないもの

- JSXの構造説明（`{/* ヘッダー */}` のような区切りコメント）
- Tailwindのクラスの意味
- 「〜画面で使用」（IDEの参照機能で辿れる）

## 静的解析で辿れない依存

**参照が文字列一致で繋がっている**もの、および**リネームが型エラーにならない**ものは必ず書く

### TanStack Query の queryKey

```ts
/**
 * 評価一覧を取得する
 *
 * NOTE: queryKey は ['evaluations', periodId]
 * useSubmitEvaluation の成功時に同じキーで invalidate される
 * キーを変更する場合は useSubmitEvaluation 側も同時に修正すること
 */
```

- `staleTime` / `gcTime` に既定値以外を指定した場合は理由を書く

```ts
// WHY: 評価期間マスタは日次でしか更新されないため、長めにキャッシュする
staleTime: 1000 * 60 * 60,
```

### TanStack Table の accessorKey

`accessorKey` がAPIレスポンスのキーと文字列一致に依存する場合、その旨を書く（リネームが実行時まで検出されない）

- 各列の見出しの意味は `header` が持つため、繰り返さない

### openapi-typescript の生成コード

- **生成ファイルにはコメントを書かない**（再生成で消える）
- 生成物を手で補正しているラッパー側に理由を書く

```ts
// WHY: 生成された型では confirmedAt が string | null だが、実運用では
//      未取得時に undefined も返るため、ここで吸収している
```

### shadcn/ui の改変箇所

コードをリポジトリに取り込む方式のため、**公式実装から変更した箇所には必ず理由を書く**

```ts
// HACK: 公式実装から変更
//       IME入力中に Enter でダイアログが閉じる不具合の回避
//       アップストリーム追従時は要再確認
```

## 抑止コメント

### lint

Oxlint は `eslint-disable` 系のディレクティブを解釈する（対象ルールはプロジェクト設定で確認する）

```ts
// HACK: 外部ライブラリの型定義が any を返すため
// eslint-disable-next-line @typescript-eslint/no-explicit-any
```

- **ファイル単位の抑止（`/* eslint-disable */`）は原則禁止**
  
  `-next-line` で範囲を最小化する

- 理由と、可能なら解除条件を併記する

### 型

- **`@ts-ignore` は使わず、`@ts-expect-error` を使う**（エラーが解消された際に不要な抑止として検出できる）

```ts
// @ts-expect-error 外部ライブラリの型定義が v3 系のため、v4 更新で解消予定
```

## 領域別の指針

### Zod スキーマ

- バリデーション条件そのものはスキーマが仕様であるため、繰り返さない
- 書くのは**なぜその制約なのか**（外部APIの制限、DBの列長、業務ルール）

```ts
export const commentSchema = z.object({
  // WHY: DB側の nvarchar(500) に合わせている
  //      変更する場合はマイグレーションが必要
  body: z.string().max(500),
});
```

### useEffect / 依存配列

**依存配列から意図的に除外した値**がある場合は理由を必須とする（無限ループ・古い値の参照の温床になるため）

```ts
// WHY: onChange を依存に入れると親の再レンダリングごとに再実行されるため除外
//      onChange は最新参照を ref で保持済み
// eslint-disable-next-line react-hooks/exhaustive-deps
}, [periodId]);
```

### React Router

- loader / action で行っているリダイレクトや認可判定の前提を書く
- ルートパスの文字列を他所と共有している場合、その対応関係を書く

### テスト（Vitest / Playwright）

- テスト名で What を表現し、TSDocは原則不要
- **書くべきは「なぜこのケースを守る必要があるか」**

```ts
// WHY: 締切時刻ちょうどの提出が弾かれる不具合
//      境界は「以下」で包含
it('締切時刻ちょうどの提出は受理される', () => {
```

- モックが必要な理由が自明でない場合は書く
- `it.skip` / `it.todo` には理由と解除条件を必須とする
- **固定待ち・リトライには理由を必須とする**（将来削除できるかの判断材料になる）

```ts
// FIXME: アニメーション完了を待つための暫定対応
//        Base UI 側で完了イベントが公開されたら waitForEvent に置き換える
await page.waitForTimeout(300);
```

## 強制手段

| 対象 | 手段 |
| --- | --- |
| TSDoc形式の統一 | Oxlint の jsdoc 系ルールの対応状況を確認のうえ導入 |
| 抑止コメントの理由 | レビュー + AIレビュー（自動検出は困難） |
| 内容の質 | AIレビュー + 人間のレビュー |
