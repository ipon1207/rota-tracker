# dotnet周りのバージョン固定作業

## `global.json`

- [global.json の概要](https://learn.microsoft.com/ja-jp/dotnet/core/tools/global-json)

`global.json` ファイルを作成すると、dotnet CLI コマンドを実行するときに使用する .NET SDRバージョンを定義できる

```json:global.json
{
  "sdk": {
    "version": "10.0.100",
    "rollForword": "latestFeature"
  }
}
```

上記のファイルだと、コンピュータにインストールされている .NET SDKバージョンの10.0.100以上を選択する

### バージョン番号の読み方

```PlainText
10 . 0 . 3 01
│    │   │  └─ パッチ
│    │   └──── フィーチャーバンド
│    └──────── マイナー
└───────────── メジャー
```

### `global.json` のスキーマ

#### `sdk`

選択する .NET SDKに関する情報を指定する

- `version`: 使用する .NET SDKのバージョン
- `allowPrerelease`: 使用するSDKバージョンを選択するときに、SDKリゾルバーでプレリリースバージョンを考慮するかどうか
- `rollForward`: 特定のSDKバージョンがない場合に、代わりにどのバージョンの範囲まで許容するか

##### `rollForward` の値

例）`global.json` に `10.0.100` と書いた場合

| 値 | 選ばれるバージョン |
| --- | --- |
| `disable` | `10.0.100` のみ |
| `patch` | `10.0.1xx` の中の最新 |
| `feature` | 同じバンドが無ければ次に高いバンドの最新 (`10.0.203`) |
| `latestPatch` | `10.0.1xx` の最新 |
| `latestFeature` | `10.0` 内の最新バンド (`10.0.301`) |
| `latestMinor` | メジャー `10` 内で最新 |
| `latestMajor` | なんでも最新（`11.0.x` も可） |
