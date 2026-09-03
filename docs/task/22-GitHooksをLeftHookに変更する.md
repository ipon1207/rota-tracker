# GitHooksをLeftHookに変更する

## GitHooksの参照を外す

元々、`.githooks` 内の `pre-commit` ファイルと `pre-push` ファイルを参照することで差分管理に入れる運用していたので変更する

```bash
git config --unset core.hooksPath
```

## Lefthookの設定

- [爆速 pre-commit hook の紹介＋おまけ（lefthook + safe-chain）](https://zenn.dev/nyaomaru/articles/introduce-lefthook-safe-chain)

### `parallel`

この項目を `true` にすると並列実行ができる
