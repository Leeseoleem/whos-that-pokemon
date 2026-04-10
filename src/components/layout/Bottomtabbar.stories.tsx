import type { Meta, StoryObj } from "@storybook/nextjs-vite";

import BottomTabBar from "@/components/layout/BottomTabBar";

const meta = {
  title: "Layout/BottomTabBar",
  component: BottomTabBar,
  parameters: {
    layout: "fullscreen",
  },
} satisfies Meta<typeof BottomTabBar>;

export default meta;
type Story = StoryObj<typeof meta>;

/** 기본: "알려줘!" 탭 활성 */
export const AskActive: Story = {
  name: "알려줘! 탭 활성",
  parameters: {
    nextjs: {
      navigation: { pathname: "/board" },
    },
  },
};

/** "누구게?" 탭 활성 */
export const WhoActive: Story = {
  name: "누구게? 탭 활성",
  parameters: {
    nextjs: {
      navigation: { pathname: "/who" },
    },
  },
};

/** "내 정보" 탭 활성 */
export const ProfileActive: Story = {
  name: "내 정보 탭 활성",
  parameters: {
    nextjs: {
      navigation: { pathname: "/my" },
    },
  },
};
