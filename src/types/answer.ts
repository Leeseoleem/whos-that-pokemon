import type { AnswerStatus } from "./common";

export interface Answer {
  id: string;
  question_id: string;
  author_id: string | null;
  pokemon_id: number;
  content: string;
  status: AnswerStatus;
  drawing_url: string | null;
  is_blinded: boolean;
  created_at: string;
  updated_at: string;
}
