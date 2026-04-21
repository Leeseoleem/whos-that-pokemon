import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import DexHeaderClient from "./DexHeaderClient";

const meta: Meta<typeof DexHeaderClient> = {
  title: "Layout/Header/DexHeader",
  component: DexHeaderClient,
  tags: ["autodocs"],
  parameters: {
    layout: "fullscreen",
  },
};

export default meta;
type Story = StoryObj<typeof DexHeaderClient>;

export const LoggedOut: Story = {
  args: { isSocialUser: false, unreadCount: 0 },
};

export const LoggedIn: Story = {
  args: { isSocialUser: true, unreadCount: 0 },
};

export const WithNotification: Story = {
  args: { isSocialUser: true, unreadCount: 5 },
};

export const MaxNotification: Story = {
  args: { isSocialUser: true, unreadCount: 10 },
};
