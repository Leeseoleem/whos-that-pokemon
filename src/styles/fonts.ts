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
      path: "../../public/fonts/PFStardust-Regular.ttf",
      weight: "400",
      style: "normal",
    },
    {
      path: "../../public/fonts/PFStardust-Bold.ttf",
      weight: "700",
      style: "normal",
    },
    {
      path: "../../public/fonts/PFStardust-ExtraBold.ttf",
      weight: "800",
      style: "normal",
    },
  ],
  variable: "--font-pf-stardust",
  display: "swap",
});
