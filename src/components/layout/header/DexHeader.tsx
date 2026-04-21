import { createClient } from "@/lib/supabase/server";
import DexHeaderClient from "./DexHeaderClient";
import type { Notification } from "@/types";

export default async function DexHeader() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  const isSocialUser = !(user?.is_anonymous ?? true);

  const { data: notifications } = isSocialUser
    ? await supabase
        .from("notifications")
        .select("*")
        .order("created_at", { ascending: false })
    : { data: [] as Notification[] };

  const unreadCount = notifications?.filter((n) => !n.is_read).length ?? 0;

  return (
    <DexHeaderClient isSocialUser={isSocialUser} unreadCount={unreadCount} />
  );
}
