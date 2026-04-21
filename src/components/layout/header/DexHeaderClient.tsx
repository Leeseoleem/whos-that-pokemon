"use client";

import { useState } from "react";
import clsx from "clsx";
import { motion } from "framer-motion";
import NotificationButton from "./NotificationButton";

interface DexHeaderClientProps {
  isSocialUser: boolean;
  unreadCount: number;
}

export default function DexHeaderClient({
  isSocialUser,
  unreadCount,
}: DexHeaderClientProps) {
  const [showNoti, setShowNoti] = useState(false);

  return (
    <header
      data-font="dot"
      className="w-full bg-panel-main border-b-4 border-panel-border rounded-t-xl p-4 flex items-center justify-between"
    >
      <div className="flex items-start gap-4">
        <div className="w-10 h-10 rounded-full bg-[radial-gradient(circle_at_35%_35%,#72D4FF,#1A88D4_50%,#0A4F90)] border-5 border-level-4-bg relative shrink-0">
          <div className="absolute top-[18%] left-[18%] w-[26%] h-[26%] rounded-full bg-white/60" />
        </div>
        <div className="flex items-center gap-2 mt-2">
          <LED color="bg-status-unsolved-main" />
          <LED color="bg-status-solved-main" delay={10} />
          <LED color="bg-status-expired-main" delay={20} />
        </div>
      </div>

      {isSocialUser && (
        <NotificationButton
          count={unreadCount}
          isActive={showNoti}
          onClick={() => setShowNoti((v) => !v)}
        />
      )}
    </header>
  );
}

function LED({ color, delay = 0 }: { color: string; delay?: number }) {
  return (
    <motion.div
      className={clsx("w-2.5 h-2.5 rounded-full border border-black/40", color)}
      animate={{ opacity: [1, 0.15, 1, 0.15, 1] }}
      transition={{
        duration: 0.4,
        repeat: Infinity,
        repeatDelay: 30,
        delay,
      }}
    />
  );
}
