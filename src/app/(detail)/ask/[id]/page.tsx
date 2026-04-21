import Link from "next/link";

export default function AskDetailPage() {
  return (
    <div className="p-4 flex flex-col gap-3">
      <p>알려줘 상세</p>
      <Link href="/ask" className="px-4 py-2 bg-gray-500 text-white rounded text-sm text-center">
        ← 목록으로
      </Link>
    </div>
  );
}
