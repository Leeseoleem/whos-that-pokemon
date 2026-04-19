import type { BadgeId } from "./common";

export interface Profile {
  id: string;
  nickname: string;
  avatar_url: string | null;
  bio: string | null;
  is_anonymous: boolean;
  is_admin: boolean;
  accepted_count: number;
  badge_id: BadgeId;
  last_question_at: string | null;
  last_answer_at: string | null;
  last_comment_at: string | null;
  created_at: string;
  updated_at: string;
}
