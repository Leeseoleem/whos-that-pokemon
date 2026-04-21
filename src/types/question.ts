import type { QuestionStatus, QuestionTab } from "./common";

export interface Question {
  id: string;
  author_id: string | null;
  tab: QuestionTab;
  title: string;
  description: string;
  status: QuestionStatus;
  image_url: string | null;
  reveal_text: string | null;
  reveal_image_url: string | null;
  accepted_answer_id: string | null;
  accepted_pokemon_id: number | null;
  accepted_type1_ko: string | null;
  accepted_type2_ko: string | null;
  accepted_generation: number | null;
  likes_count: number;
  answers_count: number;
  comments_count: number;
  view_count: number;
  is_blinded: boolean;
  last_activity_at: string;
  created_at: string;
  updated_at: string;
}

export interface QuestionLike {
  question_id: string;
  user_id: string;
  created_at: string;
}
