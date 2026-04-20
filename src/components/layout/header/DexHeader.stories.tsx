import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import DexHeader from "./DexHeader";

const meta: Meta<typeof DexHeader> = {
  title: "Layout/DexHeader",
  component: DexHeader,
  tags: ["autodocs"],
  parameters: {
    layout: "fullscreen",
  },
};

export default meta;
type Story = StoryObj<typeof DexHeader>;

export const Default: Story = {};

export const DotFont: Story = {
  name: "PF Stardust 폰트",
  decorators: [
    (Story) => (
      <div data-font="dot">
        <Story />
      </div>
    ),
  ],
};
