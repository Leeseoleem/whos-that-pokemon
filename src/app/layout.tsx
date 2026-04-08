import type { Metadata } from "next";
import { pretendard, pfStardust } from "@/styles/fonts";
import FontInitializer from "@/components/FontInitializer";
import "@/styles/globals.css";

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
      <FontInitializer />
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
