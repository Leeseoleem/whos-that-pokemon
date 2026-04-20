import Link from "next/link";

export default function WhoPage() {
  return (
    <div className="p-4 flex flex-col gap-3">
      <p>누구게</p>
      <Link href="/who/1" className="px-4 py-2 bg-blue-500 text-white rounded text-sm text-center">
        → 상세 페이지 (id: 1)
      </Link>
      <Link href="/who/write" className="px-4 py-2 bg-green-500 text-white rounded text-sm text-center">
        → 글쓰기 페이지
      </Link>
    </div>
  );
}
