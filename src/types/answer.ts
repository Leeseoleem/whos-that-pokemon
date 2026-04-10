import type { AnswerStatus } from "./common";

export interface Answer {
  id: string;
  question_id: string;
  author_id: string;
  pokemon_id: number;
  content: string;
  status: AnswerStatus;
  drawing_url: string | null;
  created_at: string;
}
