import DexHeader from "@/components/layout/header/DexHeader";

export default function DetailLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <DexHeader />
      <main className="flex-1 flex flex-col overflow-hidden">{children}</main>
    </>
  );
}
