"use client";

import { usePathname, useRouter } from "next/navigation";
import { motion } from "framer-motion";

import PokedexIcon from "../icons/PokedexIcon";
import QuestionMarkIcon from "../icons/QuestionMarkIcon";
import MonsterBallIcon from "../icons/MonsterBallIcon";

interface TabItem {
  id: string;
  icon: (props: { size?: number; color?: string }) => React.ReactElement;
  label: string;
  href: string;
}

const TAB_ITEMS: TabItem[] = [
  { id: "ask", label: "알려줘!", href: "/ask", icon: PokedexIcon },
  { id: "who", label: "누구게?", href: "/who", icon: QuestionMarkIcon },
  { id: "my", label: "내 정보", href: "/my", icon: MonsterBallIcon },
];

const COLOR_ACTIVE = "#f7f8fa";
const COLOR_INACTIVE = "#88051a";
const ICON_SIZE = 20;

export default function BottomTabBar() {
  const pathname = usePathname();

  return (
    <nav className="w-full h-16 bg-panel-main border-t-4 border-panel-border rounded-b-xl flex items-center justify-around px-4">
      {TAB_ITEMS.map((tab) => (
        <TabButton
          key={tab.id}
          tab={tab}
          isActive={
            pathname === tab.href || pathname.startsWith(`${tab.href}/`)
          }
        />
      ))}
    </nav>
  );
}

interface TabButtonProps {
  tab: TabItem;
  isActive: boolean;
}

function TabButton({ tab, isActive }: TabButtonProps) {
  const router = useRouter();
  const { icon: Icon, label, href } = tab;
  const color = isActive ? COLOR_ACTIVE : COLOR_INACTIVE;

  return (
    <motion.button
      onClick={() => router.replace(href)}
      className="flex flex-col items-center gap-0.5 transition-colors duration-150 cursor-pointer"
      whileHover={isActive ? {} : "bounce"}
      variants={{
        bounce: {
          y: [0, -6, 0, -4, 0],
          transition: {
            duration: 0.6,
            ease: "easeInOut",
          },
        },
      }}
    >
      <Icon size={ICON_SIZE} color={color} />
      <span className="text-label leading-none" style={{ color }}>
        {label}
      </span>
    </motion.button>
  );
}
