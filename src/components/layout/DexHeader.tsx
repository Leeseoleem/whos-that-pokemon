"use client";

import clsx from "clsx";
import { motion } from "framer-motion";

export default function DexHeader() {
  return (
    <header className="w-full bg-panel-main border-b-4 border-panel-border rounded-t-xl p-4 flex items-center justify-between">
      {/* 왼쪽 — 렌즈 + 로고 */}
      <div className="flex items-center gap-4">
        {/* 파란 렌즈 */}
        <div className="w-10 h-10 rounded-full bg-[radial-gradient(circle_at_35%_35%,#72D4FF,#1A88D4_50%,#0A4F90)] border-5 border-level-4-bg relative shrink-0">
          <div className="absolute top-[18%] left-[18%] w-[26%] h-[26%] rounded-full bg-white/60" />
        </div>
        <div className="flex flex-col items-baseline gap-0.5">
          <p className="text-level-1-bg text-heading2 font-pf-stardust whitespace-nowrap">
            오늘의 포켓몬은 뭘까요?
          </p>
          <p className="text-level-1-bg/70 text-label font-pf-stardust whitespace-nowrap">
            Who&apos;s That Pokémon?
          </p>
        </div>
      </div>

      {/* 오른쪽 — LED */}
      <div className="flex items-center gap-2">
        <LED color="bg-status-unsolved-main" />
        <LED color="bg-status-solved-main" delay={10} />
        <LED color="bg-status-expired-main" delay={20} />
      </div>
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
