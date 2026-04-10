export interface Profile {
  id: string;
  nickname: string;
  avatar_url: string | null;
  bio: string | null;
  is_anonymous: boolean;
  accepted_count: number;
  created_at: string;
  updated_at: string;
}
