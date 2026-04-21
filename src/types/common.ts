// ── DB 컬럼 기반 타입 ──

/** questions.tab — 질문 게시판 탭 구분 */
export type QuestionTab = "ask" | "who";

/** questions.status — 질문 상태 */
export type QuestionStatus = "unsolved" | "solved" | "expired";

/** answers.status — 답변 상태 */
export type AnswerStatus = "none" | "accepted" | "wrong";

/** comments.type — 댓글 종류. comment=답변 힌트 댓글 / discussion=정답 토론 */
export type CommentType = "comment" | "discussion";

/** notifications.type — 알림 종류 */
export type NotificationType =
  | "new_answer" // 내 질문에 답변이 달림
  | "answer_accepted" // 내 답변이 채택됨
  | "new_comment"; // 내 답변에 댓글이 달림

/** reports.target_type — 신고 대상 종류 */
export type ReportTargetType = "question" | "answer" | "comment";

/** reports.reason — 신고 사유 */
export type ReportReason =
  | "spam" // 스팸 / 광고
  | "inappropriate" // 부적절한 내용 (욕설, 혐오 등)
  | "harassment" // 특정 유저 괴롭힘
  | "other"; // 기타

/** reports.status — 신고 처리 상태 */
export type ReportStatus =
  | "pending" // 접수됨, 검토 전
  | "reviewed" // 관리자 검토 완료, 조치함
  | "dismissed"; // 관리자 검토 완료, 문제없음으로 기각

// ── UI 전용 타입 ──

/** 하단 탭바 탭 구분. QuestionTab과 달리 my(마이페이지) 포함 */
export type NavTab = "ask" | "who" | "my";

// ── 확장 가능 타입 ──

/** profiles.badge_id — 장착 뱃지 번호. 뱃지 추가 시 여기에 숫자 추가 (4 | 5 | 6 ...) */
export type BadgeId = 0 | 1 | 2 | 3;
