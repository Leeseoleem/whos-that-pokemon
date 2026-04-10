import type { CommentType } from "./common";

export interface Comment {
  id: string;
  author_id: string;
  content: string;
  type: CommentType;
  answer_id: string | null;
  question_id: string | null;
  parent_id: string | null;
  created_at: string;
}
