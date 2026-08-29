# Oxlint 設定メモ ─ 車輪の再発明トラッカー

フェーズ0で Lint を整えた記録。設定そのものより、
**なぜその判断になったか**と**次に同じ状況で使える一般則**を残す。

---

## 1. 設定ファイルの骨格

Oxlint の設定は4層で読む。上から順に「面」→「点」。

| 層 | 役割 | 今回の値 |
| --- | --- | --- |
| `plugins` | どのルール群を土俵に載せるか | typescript, react, import, promise, jsx-a11y, oxc |
| `categories` | 意図ごとの一括有効化 | correctness=error, suspicious=warn, perf=warn |
| `rules` | 個別の上書き・オプション指定 | 15個ほど |
| `overrides` | ファイル群ごとの例外 | shadcn / テスト / e2e / 設定ファイル |

**カテゴリで面を作り、個別ルールで点を打つ。**
最初から `rules` を100行書くのではなく、カテゴリで大枠を決めてから、
鳴りすぎたもの・鳴ってほしいものだけを名指しで調整する。

カテゴリの意味：

- `correctness` … ほぼ確実にバグ。error 一択
- `suspicious` … 怪しい書き方。warn が妥当
- `perf` … 無駄な処理
- `pedantic` / `style` / `restriction` … 好みの領域。今回は入れていない

---

## 2. 今回の主な判断

| 設定 | 理由 |
| --- | --- |
| `correctness: "error"` | 直さない理由がないものだけを error にする |
| `suspicious` / `perf` は warn | 手を止めさせない。CI では `--max-warnings=0` で締める |
| `react/exhaustive-deps: "error"` | 元アプリは `setInterval` を回す `useEffect` だらけ。依存配列が学習の中心 |
| `typescript/no-explicit-any: "error"` | TS を学ぶのが目的なので、逃げ道を塞ぐ |
| `typescript/no-non-null-assertion: "warn"` | `!` を書くたびに「本当に null にならないか」を考えさせる |
| 型を見るルール3つ | await 忘れは自力で気づけない。後述 |
| `react/react-in-jsx-scope: "off"` | 自動 JSX ランタイムでは不要。誤検知 |
| shadcn は ignore ではなく override | 自分で書き換えるコードなので correctness は残す |
| 生成型は ignore | 読まないファイル。openapi-typescript の出力 |

### warn と error の線引き

**error =「マージしてはいけない」／ warn =「見て、判断して」** と決めておくと迷わない。
CI で `--max-warnings=0` を付ければ、warn も結局は通らなくなるが、
手元で書いている最中は止まらない。この非対称が効く。

---

## 3. 型を見るルール（type-aware）

`options.typeAware: true` + `oxlint-tsgolint` の追加インストールで有効になる。
構文だけを見るルールと違い、TypeScript の型情報を使う。

```ts
function onSubmit(user) {
  saveUser(user)      // ← no-floating-promises が捕まえる
  showToast('保存しました')  // 失敗しても成功と表示される
}
```

TanStack Query の `mutateAsync` や `fetch` で必ずやるミス。
**構文だけ見るリンタでは原理的に捕まらない**ので、入れる価値がある。

構成上のポイント：

- tsgolint は **プロジェクトの `typescript` パッケージを使わない**。
  自前で typescript-go（TS7）を持っていて、それで型を解析する
- したがってプロジェクトが TS 6.x でも導入できる
- 代わりに **tsconfig を TS7 のエンジンとして解釈する**。ここが摩擦点になる
- `--type-check` は tsc の型診断そのものを出す。TS6 にいる間は使わない

---

## 4. 実際に踏んだ3つの罠

### (1) `baseUrl` で tsconfig が読めていなかった

```PlainText
× typescript(tsconfig-error): Invalid tsconfig
```

TS 6 では `ignoreDeprecations: "6.0"` で延命できていたが、
tsgolint の TS7 エンジンは受け付けない。`baseUrl` を削除して解決。
`paths` は `baseUrl` なしなら tsconfig 自身の位置が起点になる。

**このエラーの間、型を見るルールは1つも動いていなかった。**
警告は出ているので「動いている」ように見えるのが厄介。

> 一般則：**機能を有効化したら、実際に効いていることを1回確かめる。**
> 「設定を書いた」と「効いている」は別。
> 意図的に違反コードを1行書いて、鳴ることを見るのが確実。

### (2) override の glob が全部空振りしていた

設定に `web/src/components/ui/**` と書いていたが、
設定ファイル自体を `web/` の中に置いていた。glob は設定ファイルの位置が起点。

> 一般則：**パスを含む設定を書いたら、意図した対象に当たっているかを確認する。**
> 空振りは無言で起きる。エラーにならない。

### (3) 誤検知が全体の 85%

58件中50件が `react-in-jsx-scope`。
`jsx: "react-jsx"`（自動ランタイム）では React の import は不要なのに、
クラシックランタイム時代のルールが鳴っていた。

> 一般則：**大量に同じ警告が出たら、まず設定を疑う。**
> ルール名ごとに件数を数えると、コードを直す話か設定を直す話かが即分かる。
>
> ```bash
> npx oxlint 2>&1 | grep -oE '[a-z@-]+\([a-z-]+\)' | sort | uniq -c | sort -rn
> ```

---

## 5. コード側で直したもの

```tsx
// before
createRoot(document.getElementById('root')!).render(...)

// after
const rootElement = document.getElementById('root')
if (!rootElement) throw new Error('#root が見つかりません')
createRoot(rootElement).render(...)
```

`!` は**型のうえで null を消すだけで、実行時には何もしない**。
`id="root"` が消えたとき、前者は React 内部でよく分からないエラーになり、
後者は原因がそのまま出る。`no-non-null-assertion` を warn にしている理由そのもの。

---

## 6. ルールごとの「何を防ぐか」

覚えるべきは名前ではなく、防いでいるバグの形。

| ルール | 防ぐもの |
| --- | --- |
| `typescript/no-floating-promises` | await 忘れ。失敗が握り潰されて成功扱いになる |
| `typescript/no-misused-promises` | `onClick={async () => ...}` 系。例外がどこにも行かない |
| `react/exhaustive-deps` | 依存漏れ。古い値を掴んだままの effect |
| `react/rules-of-hooks` | 条件分岐の中の Hook。state が壊れる |
| `typescript/no-non-null-assertion` | 実行時に効かない安心 |
| `eslint/no-shadow` | 内外で同名の変数。どちらを触っているか読めなくなる |
| `import/no-cycle` | 循環 import。初期化順で undefined になる |
