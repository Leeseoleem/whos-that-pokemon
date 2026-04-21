import { createClient } from "@/lib/supabase/server";

export default async function MyPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const isAnonymous = !user || user.is_anonymous;

  if (isAnonymous) {
    return <div>로그인이 필요합니다</div>;
  }

  return <div>내 정보: {user.email}</div>;
}
