# Dapperで接続を供給するパターンについて調べる

## ASP.NET Core DI ライフタイムの違い

- [【C#】DIコンテナ（DI）のよくある誤用とライフタイム管理の落とし穴【実務向け】](https://qiita.com/polnareff/items/bc91f6e709562cd074a2)

### DIコンテナのライフタイムの基本

- **Singleton**: アプリ起動時に1回だけ生成され、アプリ終了まで使いまわされる
- **Scoped**: HTTPリクエストごとに1回生成される
- **Transient**: サービスが要求される度に毎回生成される

#### 基本的な使い方

```CSharp
services.AddSingleton<IMyService, MyService>();
services.AddScoped<IMyRepository, MyRepository>();
services.AddTransient<IMyValidator, MyValidator>();
```

## SqlConnection 接続プール

- [SQL Server の接続プーリング (ADO.NET)](https://learn.microsoft.com/ja-jp/sql/connect/ado-net/sql-server-connection-pooling?view=sql-server-ver17)

簡単に言うと、データベースとアプリケーション接続にはコスト・時間がかかるのを**接続プール**という仕組みで解決する

```C#
using (SqlConnection connection = new SqlConnection("Integrated Security=SSPI;Initial Catalog=Northwind"))
{
  connection.Open();
  // Pool A is created.
}

using (SqlConnection connection = new SqlConnection("Integrated Security=SSPI;Initial Catalog=pubs"))
{
  connection.Open();
  // Pool B is created because the connection strings differ.  
}

using (SqlConnection connection = new SqlConnection("Integrated Security=SSPI;Initial Catalog=Northwind"))
{  
  connection.Open();
  // The connection string matches pool A.  
}
```

上記のコード例のように、接続文字列をIDとして、同一のものは接続プールを使いまわす（上記の例だと接続プールAとBが存在し、3つの `using` は接続文字列が接続プールAのものと対応するため使いまわすことで新たに接続を確立しない）

接続文字列が完全一致でないと別プールになる

## Dapperの接続供給パターン

- [Registration IDbConnection to use Dapper ORM in DI container as Scoped or Transient](https://stackoverflow.com/questions/78879593/registration-idbconnection-to-use-dapper-orm-in-di-container-as-scoped-or-transi)
- [Injecting IDbConnection vs IDbConnectionFactory](https://stackoverflow.com/questions/55690339/injecting-idbconnection-vs-idbconnectionfactory)

**接続プール**の仕組み的に、SQLクエリを実行するごとに生成と破棄を行えば良さげ

```C#
public interface IUserRepository 
{
    Task<IEnumerable<User>> GetUsers();
}

public class UserRepository(DapperContext context) : IUserRepository 
{ 
    private readonly DapperContext _context = context; 

    public async Task<IEnumerable<User>> GetUsers()
    { 
        var query = "SELECT * FROM Users ORDER BY Name ASC"; 
        // using文を使用して確実にDispose・クローズを行う
        using var connection = _context.CreateConnection(); 
        var users = await connection.QueryAsync<User>(query); 
        return users.ToList();
    }
}
```

### 結論

SQLクエリごとに `using` ステートメントを利用すれば、接続プールの仕組みをうまく使えそうなので、**Singleton**ライフタイムで管理すればいいと思う

## ASP.NET Core オプションパターン

- [ASP.NET Core のオプション パターン](https://learn.microsoft.com/ja-jp/aspnet/core/fundamentals/configuration/options?view=aspnetcore-10.0)
- [.NET でのオプション パターン](https://learn.microsoft.com/ja-jp/dotnet/core/extensions/options)

`appsettings.json` のプロパティ値を専用クラスを作成して、マッピングすることで何かをするっぽい？

→ **型安全になる・設定の変更を検知できることが利点**
