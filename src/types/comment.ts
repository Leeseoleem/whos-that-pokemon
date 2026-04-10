import type { CommentType } from "./common";

// DB에서 받아오는 raw 타입
export interface CommentRow {
  id: string;
  author_id: string;
  content: string;
  type: CommentType;
  answer_id: string | null;
  question_id: string | null;
  parent_id: string | null;
  created_at: string;
}

// 프론트 전용 타입
type CommentBase = {
  id: string;
  author_id: string;
  content: string;
  parent_id: string | null;
  created_at: string;
};

export type Comment =
  | (CommentBase & { type: "comment"; answer_id: string; question_id: null })
  | (CommentBase & {
      type: "discussion";
      answer_id: null;
      question_id: string;
    });
