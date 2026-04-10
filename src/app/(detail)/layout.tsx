export default function DetailLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <main className="flex-1 flex flex-col overflow-hidden">{children}</main>
  );
}
