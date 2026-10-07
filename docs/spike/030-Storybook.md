# Storybook

## Storybookの概要

- [Storybookとは？Storybookを用いたフロント開発](https://zenn.dev/fullyou/articles/853b77a3ce9144)

Storybookは「UIカタログ」と言われ、それぞれのUIコンポーネントをブラウザで手軽にチェックすることができる

- 手軽にUIのテストができる

  仕様書を作った際やモックを作った際では想定されなかったパターンでもUIがおかしくならないか予め検証できる

- サーバー側の準備ができていなくても先にUIを作ることができる

  簡素なデモデータを用いてUIチェックを行うことができる（予めスキーマなどを共有する必要はある）

## Storybookを使った開発

コーディングしたコンポーネントをブラウザで手軽にチェックできる

→ 「story単位」でコンポーネントをブラウジングできる
→ **story**: 特定のデータを与えたコンポーネントの状態であり、1つのコンポーネントに対し複数のstoryが存在し得る

```tsx
const Button: React.FC<Props> = ({ isActive }) => (
  <button
    className={`button ${isActive ? 'active' : 'disable'}`}
    onClick={() => console.log("Clicked!")}
  >
    Button
  </button>
);
```

- 上記の例だとClickableなstoryとDisableなstoryに分けることができる
- **interestingなstory**を洗いざらい書く必要がある

  → interestingとはサービスにおいてそのコンポーネントが重要となりうる、検証する価値のあるコンポーネントの状態

- 「テキストが非常に長くなっているときのstory」や「データがnullになっているときにstory」などもinterestingなstory

## 基本的なstoryの書き方

```tsx
import React from 'react';
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  component: Button,
};
export default meta;

type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  render: () => <Button primary label="ボタン" backgroundColor="light-blue" />,
};

export const Disable: Story = {
  render: () => <Button primary label="ボタン" backgroundColor="gray" />
};
```

## 所感

- 画面が変化しやすい開発初期に導入したい
- Figmaでワイヤーフレーム・モックを作成する手間や維持するコストがリポジトリに同居するようになるのは良い

  → Storybookも運用コストはあることに注意
  
- Storybookで駆動することでコンポーネント設計が自然になる（Story単位で切り出せないコンポーネントは設計が悪い）
- 画面数が少ない開発には過剰なライブラリかもしれない

## 結論

採用は見送り
