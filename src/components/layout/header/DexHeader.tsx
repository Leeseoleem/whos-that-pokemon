"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
// --- design ---
import clsx from "clsx";
import { motion } from "framer-motion";
// --- components ---
import NotificationButton from "./NotificationButton";
// --- types ---
import type { Notification } from "@/types";

export default function DexHeader() {
  const [showNoti, setShowNoti] = useState(false);
  const [isLoggedIn] = useState(true); // TODO: Supabase auth 연결 시 교체
  const unreadCount = 0; // TODO: notifications fetch 후 is_read=false 카운트로 교체

  // TODO: DB 연결 시 아래 주석 해제
  // const supabase = createClient();
  // const [isLoggedIn, setIsLoggedIn] = useState(false);
  // const [notifications, setNotifications] = useState<Notification[]>([]);
  // const unreadCount = notifications.filter((n) => !n.is_read).length;

  // 소셜 로그인 여부 확인
  // useEffect(() => {
  //   supabase.auth.getUser().then(({ data }) => {
  //     const user = data.user;
  //     const isAnon = user?.is_anonymous ?? true;
  //     setIsLoggedIn(!isAnon);
  //   });
  // }, []);

  // 알림 fetch (소셜 유저만)
  // useEffect(() => {
  //   if (!isLoggedIn) return;
  //   supabase
  //     .from("notifications")
  //     .select("*")
  //     .order("created_at", { ascending: false })
  //     .then(({ data }) => {
  //       if (data) setNotifications(data);
  //     });
  // }, [isLoggedIn]);

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

      {isLoggedIn && (
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
