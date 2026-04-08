import localFont from "next/font/local";

export const pretendard = localFont({
  src: "../../public/fonts/PretendardVariable.woff2",
  variable: "--font-pretendard",
  display: "swap",
  weight: "45 920",
});

export const pfStardust = localFont({
  src: [
    {
      path: "../../public/fonts/PF스타더스트_3_0.ttf",
      weight: "400",
      style: "normal",
    },
    {
      path: "../../public/fonts/PF스타더스트_3_0_Bold.ttf",
      weight: "700",
      style: "normal",
    },
    {
      path: "../../public/fonts/PF스타더스트_3_0_ExtraBold.ttf",
      weight: "800",
      style: "normal",
    },
  ],
  variable: "--font-pf-stardust",
  display: "swap",
});
