import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import NotificationButton from "./NotificationButton";

const meta: Meta<typeof NotificationButton> = {
  title: "Layout/Header/NotificationButton",
  component: NotificationButton,
  tags: ["autodocs"],
  argTypes: {
    count: {
      control: { type: "number", min: 0 },
      description: "읽지 않은 알림 수",
    },
    isActive: {
      control: "boolean",
      description: "알림 패널 열림 여부",
    },
    onClick: { action: "clicked" },
  },
};

export default meta;
type Story = StoryObj<typeof NotificationButton>;

export const Default: Story = {
  args: {
    count: 0,
    isActive: false,
  },
};

export const HasNotification: Story = {
  args: {
    count: 3,
    isActive: false,
  },
};

export const MaxCount: Story = {
  args: {
    count: 10,
    isActive: false,
  },
};

export const Active: Story = {
  args: {
    count: 3,
    isActive: true,
  },
};
