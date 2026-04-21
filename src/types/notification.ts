import type { NotificationType } from "./common";

export interface Notification {
  id: string;
  user_id: string;
  type: NotificationType;
  question_id: string | null;
  answer_id: string | null;
  is_read: boolean;
  created_at: string;
}
