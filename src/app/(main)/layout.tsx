import BottomTabBar from "@/components/layout/BottomTabBar";

export default function MainLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <main className="flex-1 flex flex-col overflow-hidden">{children}</main>
      <BottomTabBar />
    </>
  );
}
