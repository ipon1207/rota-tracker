# Storybookのチュートリアル

## React 向けの Storybook を構築する

- [React 向け Storybook のチュートリアル](https://storybook.js.org/tutorials/intro-to-storybook/react/ja/get-started/)

既存プロジェクトのルートディレクトリ（今回は `web/`）で以下のコマンドを実行する

利用中のビルドツール（Vite, Next.js, Webpackなど）が自動判別され、必要な設定ファイルと依存パッケージがインストールされる

```bash
npm storybook@latest init
```

npm scriptに `storybook` が追加されるため、それを実行して、動作確認

```bash
npm run storybook
```

## 単純なコンポーネントを作る

- [Build a simple component](https://storybook.js.org/tutorials/intro-to-storybook/react/en/simple-component/)

CDD（Component Driven Development：コンポーネント駆動開発）手法に沿って、UIを構築していく

CDDは最小単位のコンポーネントから始めて最終的に画面全体をくみ上げていく**ボトムアップ**のアプローチ

### Project コンポーネント

- 課題の状態 (`state`) に応じて表示が変化する
- 課題の表示状態（開 / 閉）のボタン
- 課題名

必要な Props は以下

- `title`: 課題の内容を表す文字列
- `state`: 課題が現在、「未完了」「進行中」「完了」かどうかを示すステータス

`Task` の実装を始めるにあたって、上記の項目に対応する**テスト用の状態 (Story) を定義する**

その後、Storybookを使用してモックデータとともにコンポーネントを単体で作成し、各状態での見た目を「ビジュアルテスト」しながら進める

![alt text](./project-closed.png)
![alt text](./project-opened.png)

### セットアップ

`src/components/Task.tsx` と `src/components/Task.stories.tsx` を作成する

```tsx
type ProjectData = {
  id: string;
  title: string;
  state: 'TODO' | 'DOING' | 'DONE';
  difficulty: number;
};

type ProjectProps = {
  project: ProjectData;
  isOpen: boolean;
  onChangeState: (id: string) => void;
  onSwitchProject: (id: string) => void;
};

export default function Project({
  project: { id, title, state, difficulty },
  isOpen,
  onChangeState
}: ProjectProps) {
  return (
    <div className="flex items-stretch overflow-hidden rounded-[1px] border-[#E2E2DA] border-solid bg-white">
      <button className="bg-[#F6F6F2] text-[#7B858C] cursor-pointer">未着手</button>
      <button className="bg-[#232E36] cursor-pointer flex items-center flex-1 gap-2.5 px-3 py-3.5 text-sm text-left">
        <span>{title}</span>
        <span className="flex gap-1.5 ml-auto flex-wrap">
          <span className="text-[#C98A04] border border-solid rounded-[5px] px-px py-1.75 text-[11px] font-[ui-monospace,monospace] border-[#FBF2DC] bg-[#FBF2DC] tracking-[1px]">{difficulty}</span>
        </span>
        <span className="text-[#7B858C] text-[11px] [transition:transform,0.15s,ease]" aria-hidden={true}>▾</span>
      </button>
    </div>
  )
}
```

ストーリーファイルに `Project` の3つのテスト用状態を定義する

```tsx:Project.stories.tsx
import Project from "@/components/Project";
import type { Meta, StoryObj } from "@storybook/react-vite";
import { fn } from "storybook/test";

export const ActionsData = {
  onChangeState: fn(),
  onSwitchAccordion: fn(),
};

const meta = {
  component: Project,
  title: 'Project',
  tags: ['autodocs'],
  excludeStories: /.*Data$/,
  args: {
    ...ActionsData
  },
} satisfies Meta<typeof Project>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    project: {
      id: '1',
      title: '自作 ls コマンド',
      state: 'TODO',
      difficulty: 1,
    },
    isOpen: false
  }
}

export const Doing: Story = {
  args: {
    project: {
      ...Default.args.project,
      state: 'DOING'
    },
    isOpen: false
  }
}

export const Done: Story = {
  args: {
    project: {
      ...Default.args.project,
      state: 'DONE'
    },
    isOpen: false
  }
}
```

### 原型に使われているCSSを再現するTailwind CSS

- [Tailwind CSS 日本語チートシート](https://telehakke.github.io/tailwindcss-japanese-cheat-sheet/)

#### `items-stretch` (`align-items: stretch`)

アイテムの整列を行い、**隙間を埋めるように子要素を引き延ばす**

#### 任意の色を使用する

クラス名の後ろに `[...]` を付けてカラーコードを直接渡せる

```tsx
<button className="bg-[#F6F6F2] text-[#7B858C]"></button>
<button className="bg-[#232E36]">{title}</button>
```

`px` や `vw` を指定する場合も同様

```tsx
<div className="flex items-stretch overflow-hidden rounded-[1px]">
  <button className="bg-[#F6F6F2] text-[#7B858C]"></button>
  <button className="bg-[#232E36]">{title}</button>
</div>
```

## 行の見出しをコンポーネントとして切り出す

`車輪の再発明トラッカー.jsx` は**グローバルな状態を直接読んでいる**

コンポーネントに分けるときの要点は、これらを **props に置き換えて外に依存しない形にする**

### 状態毎のラベルと色の変化

| `state` | ラベル | 背景色 | 文字色 |
| --- | --- | --- | --- |
| **`TODO`** | 未着手 | `#F6F6F2` | `#7B858C` |
| **`DOING`** | 進行中 | `#FBF2DC` | `#C98A04` |
| **`DONE`** | 完了 | `#E8EEFD` | `#2B5CE6` |

#### `Record<Keys, Type>`

プロパティのキーが `Keys` であり、プロパティの値が `Type` であるオブジェクトの型を作る

```ts
type StringNumber = Record<string, number>;
const value: StringNumber = { a: 1, b: 2, c: 3 };
```
