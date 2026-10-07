# VSCodeの設定を整備する

## AIに生成させた `settings.json` の中身

- [setting.json](../../.vscode/extensions.json)
- [.editorconfig](../../.editorconfig)
- [.oxfmtrc.json](../../web/.oxfmtrc.json)

### TypeScript関連

- `js/ts.tsdk.path`:「エディタが使うTypeScriptを、VS Code同梱版ではなくプロジェクトの `node_modules` のものにする」設定
- `js/ts.tsdk.promptToUseWorkspaceVersion`: 上記の設定を切り替えるためのプロンプトを出力するための設定
- `js/ts.preferences.importModulesSpecifier: non-relative`: 自動importが `../../components/ui/button` のような相対パス指定ではなく `@/components/ui/button` になる設定

### 改行コード・空白

`.editorconfig` と `.oxfmtrc.json` に書いた内容を書いている

※ 重複箇所が3カ所あるため、修正の際にコストがかかる

### Tailwind

- Tailwind CSS v4は `tailwind.config.js` を持たずにCSSに設定を書く方式のため、拡張機能にそれを伝える必要がある
- `css.lint.unknownAtRules: "ignore"`: VS Code標準のCSS機能がv4の `@Theme` や `@Custom-variant` を知らないための対処

### .NET

- `dotnet.defaultSolution`: ソリューションが `api/` 配下にあるため明示している
