import type { ReportReason, ReportStatus, ReportTargetType } from "./common";

export interface Report {
  id: string;
  reporter_id: string | null;
  target_type: ReportTargetType;
  target_id: string;
  reason: ReportReason;
  detail: string | null;
  status: ReportStatus;
  created_at: string;
}
