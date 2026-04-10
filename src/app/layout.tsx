import type { Metadata } from "next";

import "@/styles/globals.css";
import { pretendard, pfStardust } from "@/styles/fonts";

import FontInitializer from "@/components/FontInitializer";
import DexHeader from "@/components/layout/DexHeader";
import BottomTabBar from "@/components/layout/BottomTabBar";

export const metadata: Metadata = {
  title: "오늘의 포켓몬은 뭘까요?",
  description: "오늘의 포켓몬을 맞혀보세요!",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="ko"
      className={`${pretendard.variable} ${pfStardust.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col items-center">
        <FontInitializer />
        <div className="w-full max-w-3xl min-h-full flex flex-col flex-1 relative">
          <DexHeader />
          {children}
          <BottomTabBar />
        </div>
      </body>
    </html>
  );
}
