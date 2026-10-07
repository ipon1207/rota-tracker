# pre-commitの設定

## dotnet CLIのソリューションファイルについて

- [【備忘録】 .NET CLIで使用する基本的なコマンドをまとめる](https://zenn.dev/minenote/articles/2588e56951edea)

基本的には `.csproj` だけでよくソリューションファイルを追加する必要はない

2つ以上のプロジェクトがある場合に `.sln` (`.slnx`) があると以下のことができるようになる

- ルートディレクトリで `dotnet build` / `dotnet test` を打つだけで全部まとめて処理できる
- 開発ツールが構成を認識してくれる
- CIで `dotnet test ~.sln` とすればファイル1個の指定で済む

※ プロジェクト間の参照は `.sln` ではなく、`.csproj` で管理される

## pre-commitとpre-push

- [git hooksについて](https://qiita.com/junya__ya/items/c67bd320bb4a9992f3a3)
- [【Git hooks】 pre-commitフック導入](https://zenn.dev/sun_asterisk/articles/97d2b4be675c06)

Git Hooksという、Gitの特定の操作時に実行されるスクリプトがある

- pre-commit: `git commit -m "~"` の実行時にコミット前に実行される
- pre-push: `git push` の実行時にpush前に実行される

## Microsoft.OpenApiパッケージの脆弱性通知

```bash
dotnet format --verbosity diagnostic

ファイル 'C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Api\WheelTracker.Api.csproj' の処理中に MSBuild が次のメッセージで失敗しました: パッケージ 'Microsoft.OpenApi' 2.0.0 に既知の 高 重大度の脆弱性があります、https://github.com/advisories/GHSA-v5pm-xwqc-g5wc
ファイル 'C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Tests\WheelTracker.Tests.csproj' の処理中に MSBuild が次のメッセージで失敗しました: パッケージ 'Microsoft.OpenApi' 2.0.0 に既知の 高 重大度の脆弱性があります、https://github.com/advisories/GHSA-v5pm-xwqc-g5wc
```

Microsot.OpenApiで、循環スキーマ参照を含む小さなOpenAPIドキュメントがスタックオーバーフローを起こし、プロセスを終了させうるという脆弱性通知

### 直す

推移的依存なのか直接的依存なのかを判別する

```bash
dotnet list package --vulnerable --include-transitive
0.4 秒後に 2 件の警告付きで成功しました を復元する
    C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Tests\WheelTracker.Tests.csproj : warning NU1903: パッケージ 'Microsoft.OpenApi' 2.0.0 に既知の 高 重大度の脆弱性があります、https://github.com/advisories/GHSA-v5pm-xwqc-g5wc
    C:\Users\miyashita\projects\rota-tracker\api\WheelTracker.Api\WheelTracker.Api.csproj : warning NU1903: パッケージ 'Microsoft.OpenApi' 2.0.0 に既知の 高 重大度の脆弱性があります、https://github.com/advisories/GHSA-v5pm-xwqc-g5wc

0.5 秒後に 2 件の警告付きで成功しました をビルド

次のソースが使用されました:
   https://api.nuget.org/v3/index.json
   C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\

プロジェクト 'WheelTracker.Api' には次の脆弱なパッケージがあります
   [net10.0]: 
   推移的なパッケージ                解決済み    重要度    アドバイザリ URL                                       
   > Microsoft.OpenApi      2.0.0   High   https://github.com/advisories/GHSA-v5pm-xwqc-g5wc

プロジェクト 'WheelTracker.Tests' には次の脆弱なパッケージがあります
   [net10.0]: 
   推移的なパッケージ                解決済み    重要度    アドバイザリ URL                                       
   > Microsoft.OpenApi      2.0.0   High   https://github.com/advisories/GHSA-v5pm-xwqc-g5wc
```

推移的依存だったのでパッチを当てる

```bash
dotnet add WheelTracker.Api package Microsoft.AspNetCore.OpenApi
```
