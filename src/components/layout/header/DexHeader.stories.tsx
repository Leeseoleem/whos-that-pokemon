import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import DexHeader from "./DexHeader";

const meta: Meta<typeof DexHeader> = {
  title: "Layout/Header/DexHeader",
  component: DexHeader,
  tags: ["autodocs"],
  parameters: {
    layout: "fullscreen",
  },
};

export default meta;
type Story = StoryObj<typeof DexHeader>;

export const Default: Story = {};
