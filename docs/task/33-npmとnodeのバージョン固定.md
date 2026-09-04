# npmとnodeのバージョン固定

## バージョン固定の方法

- [そのプロジェクト、npmのバージョン固定できてる？](https://qiita.com/hirorock/items/3a98a43f38aec39aab4f)
- [package.jsonの中にenginesの定義によってnodeバージョンを提示](https://zenn.dev/ianchen0419/articles/9c101f03f319a4)

`package.json` の `engines` 項目でnodeバージョンとnpmバージョンを明示的に定義できる

```json:package.json
{
  "engines": {
    "node": "24.13.1",
    "npm": "11.12.1"
  }
}
```

さらに、フォルダ内に `.npmrc` を作成し、以下の内容を記述

```PlainText:.npmrc
engine-strict = true
```

### `engines` フィールドと `.npmrc` の有効範囲

- `engines` フィールドは、書いた `package.json` の範囲にしか適用されない
- `.npmrc` の `engine-strict=true` も同様

→ **`web/` ディレクトリとルートディレクトリのそれぞれで設定を記述する必要がある**
