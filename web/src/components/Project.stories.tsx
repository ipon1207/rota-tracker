import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import Project from '@/components/Project';

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
    ...ActionsData,
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
    isOpen: false,
  },
};

export const Doing: Story = {
  args: {
    project: {
      ...Default.args.project,
      state: 'DOING',
    },
    isOpen: false,
  },
};

export const Done: Story = {
  args: {
    project: {
      ...Default.args.project,
      state: 'DONE',
    },
    isOpen: false,
  },
};

export const Opened: Story = {
  args: {
    ...Default.args,
    isOpen: true,
  },
};
