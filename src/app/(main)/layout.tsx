import DexHeader from "@/components/layout/DexHeader";
import BottomTabBar from "@/components/layout/BottomTabBar";

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <DexHeader />
      <main className="flex-1 flex flex-col overflow-hidden">{children}</main>
      <BottomTabBar />
    </>
  );
}
