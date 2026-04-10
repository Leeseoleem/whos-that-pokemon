import type { QuestionStatus, QuestionTab } from "./common";

export interface Question {
  id: string;
  author_id: string;
  title: string;
  description: string;
  status: QuestionStatus;
  tab: QuestionTab;
  image_url: string | null;
  edit_token: string | null;
  accepted_answer_id: string | null;
  accepted_pokemon_id: number | null;
  accepted_type1_ko: string | null;
  accepted_type2_ko: string | null;
  accepted_generation: number | null;
  likes_count: number;
  answers_count: number;
  reveal_text: string | null;
  reveal_image_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface QuestionLike {
  question_id: string;
  user_id: string;
  created_at: string;
}
