# TypeScriptのstrictを有効にする

## `tsconfig.json` の `strict` 有効化

- [tsconfig.jsonのstrict](https://zenn.dev/hayato94087/articles/c0e1df5a10865d)
- [tsconfig.jsonとstrictモードの移行について](https://qiita.com/st_12/items/40aa09fc4350c48bf529)

strictモードを有効にすると、以下のオプションがすべて有効になり、厳格な型チェックが行われるようになる

### noImplicitAny

暗黙的な `any` 型を許可しない

以下のコードは弾かれる

```ts
function add(a, b) {
  return a + b;
}
```

### noImplicitThis

`this` の暗黙的な `any` 型を許可しない

以下のコードは `innerFunction()` をアロー関数ではなく通常関数で宣言することによって `this` はグローバルオブジェクトか `undefined` になるため弾かれる

```ts
const myObject = {
  property: "Hello, world!",
  showProperty() {
    function innerFunction() {
      console.log(this.property);
    }
    innerFunction();
  }
};

myObject.showProperty();
```

### strictNullChecks

`null` と `undefined` を厳格にチェックし、代入を許可しない

以下のコードは弾かれる

```ts
const date: Date = null;
const error: Error = undefined;
```

### strictFunctionTypes

関数のパラメータと戻り値の型を厳格にチェックし、引数の共変性を許可しない

> #### 型の反変性・共変性
>
> 以下のように、引数の型を広められる特性を**引数の反変性**という
>
> ```ts
> let func: (n: number | null) => any;
> func = (n: number | null | undefined) => {};
> ```
>
> 以下のように、引数の型を狭められる特性を**引数の共変性**という
>
> ```ts
> let func: (n: number | null) => any;
> func = (n: number) => {};
> ```
>
> この両特性を**引数の両変性**という

引数の双変性を許容するコードは弾かれる

```ts
let func: (n: number | null) => any;
// 共変性によって型を狭めている
func = (n: number) => n.toString();
// funcはnull型を許容するためnullを渡すことができるが、共変性による矛盾が生じて実行時エラーになる
func(null);
```

### strictPropertyInitialization

クラスのプロパティがコンストラクタで初期化されていることを保証する

以下のコードはクラスプロパティが初期化されていないためコンパイルエラーになる

```ts
class User {
  // 初期化されていないためエラー
  id: number;
  // 初期化されていないためエラー
  name: string;
  // オプショナルプロパティは初期化不要
  optionalProperty?: string;
}
```

### strictBindCallApply

`bind`, `call`, `apply` の型チェックを行い、戻り値の型は呼び出す関数の戻り値型とする

以下のコードは弾かれる

```ts
function addNumbers(x: number, y: number): number {
  return x + y;
}

// 数値型に文字列を渡しているため、警告がでる
const sum = addNumbers.call(null, 10, "30");
```

### useUnknownCatchVariables

`catch` ブロック内の例外変数の型を `any` から `unknown` 型として解釈する

```ts
try {
  throw new Error();
  // errは unknown型
} catch (err) {
  //...
}
```
