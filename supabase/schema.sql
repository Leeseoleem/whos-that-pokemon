-- ============================================================
-- 오늘의 포켓몬은 뭘까요? — 전체 DB 스키마
-- pokemons 테이블은 seed 완료 상태이므로 제외
-- 실행 순서: 1→2→3→4(FK추가)→5→6→7→8→9→10→11→12 순으로 진행
-- ============================================================


-- ============================================================
-- 1. profiles
-- ============================================================

CREATE TABLE public.profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname          TEXT    NOT NULL,
  avatar_url        TEXT,
  bio               TEXT,
  is_anonymous      BOOLEAN NOT NULL DEFAULT true,
  is_admin          BOOLEAN NOT NULL DEFAULT false,
  accepted_count    INT     NOT NULL DEFAULT 0,
  badge_id          INT     NOT NULL DEFAULT 0,
  last_question_at  TIMESTAMPTZ,
  last_answer_at    TIMESTAMPTZ,
  last_comment_at   TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- updated_at 자동 갱신 트리거 (공통 함수)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 회원가입 시 profiles 자동 생성 + 닉네임 충돌 처리
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_base_nickname TEXT;
  v_nickname      TEXT;
  v_suffix        INT := 0;
BEGIN
  v_base_nickname := '트레이너#' || to_char(now(), 'YYYYMMDDHHmmss');
  v_nickname := v_base_nickname;

  LOOP
    EXIT WHEN NOT EXISTS (SELECT 1 FROM public.profiles WHERE nickname = v_nickname);
    v_suffix := v_suffix + 1;
    v_nickname := v_base_nickname || '_' || v_suffix;
  END LOOP;

  INSERT INTO public.profiles (id, nickname, is_anonymous)
  VALUES (
    NEW.id,
    v_nickname,
    COALESCE((NEW.raw_user_meta_data->>'provider') IS NULL OR (NEW.raw_user_meta_data->>'provider') = 'anonymous', true)
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- 2. questions (accepted_answer_id FK는 answers 생성 후 추가)
-- ============================================================

CREATE TABLE public.questions (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id            UUID REFERENCES public.profiles(id) ON DELETE SET NULL,

  -- 공통 필드
  tab                  TEXT NOT NULL DEFAULT 'ask'
                         CHECK (tab IN ('ask', 'who')),
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  status               TEXT NOT NULL DEFAULT 'unsolved'
                         CHECK (status IN ('unsolved', 'solved', 'expired')),
  image_url            TEXT,                    -- ask: 사진/드로잉 통합 1개 / who: 실루엣 이미지

  -- who 전용
  reveal_text          TEXT,                    -- 채택 시 정답 공개 텍스트 (필수)
  reveal_image_url     TEXT,                    -- 채택 시 정답 공개 이미지 (선택)

  -- 채택 정보 (denormalize — trigger로 자동 채움)
  accepted_answer_id   UUID,                    -- FK는 answers 생성 후 추가
  accepted_pokemon_id  INT REFERENCES public.pokemons(id),
  accepted_type1_ko    TEXT,
  accepted_type2_ko    TEXT,
  accepted_generation  INT,

  -- 캐싱 카운트 (trigger 동기화)
  likes_count          INT NOT NULL DEFAULT 0,
  answers_count        INT NOT NULL DEFAULT 0,
  comments_count       INT NOT NULL DEFAULT 0,
  view_count           INT NOT NULL DEFAULT 0,

  -- 관리
  is_blinded           BOOLEAN     NOT NULL DEFAULT false,
  last_activity_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER questions_updated_at
  BEFORE UPDATE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ============================================================
-- 3. answers
-- ============================================================

CREATE TABLE public.answers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID    NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  author_id   UUID    REFERENCES public.profiles(id) ON DELETE SET NULL,
  pokemon_id  INT     NOT NULL REFERENCES public.pokemons(id),
  content     TEXT    NOT NULL,
  status      TEXT    NOT NULL DEFAULT 'none'
                CHECK (status IN ('none', 'accepted', 'wrong')),
  drawing_url TEXT,                             -- who 덧그리기 답변 시 저장 (ask=NULL)
  is_blinded  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER answers_updated_at
  BEFORE UPDATE ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ============================================================
-- 4. questions.accepted_answer_id FK 추가 (순환 참조 해소)
-- ============================================================

ALTER TABLE public.questions
  ADD CONSTRAINT fk_accepted_answer
  FOREIGN KEY (accepted_answer_id) REFERENCES public.answers(id)
  DEFERRABLE INITIALLY DEFERRED;


-- ============================================================
-- 5. question_edit_tokens — 익명 유저 수정/삭제 토큰
-- ============================================================

CREATE TABLE public.question_edit_tokens (
  question_id UUID PRIMARY KEY REFERENCES public.questions(id) ON DELETE CASCADE,
  token       UUID NOT NULL DEFAULT gen_random_uuid(),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 6. question_likes
-- ============================================================

CREATE TABLE public.question_likes (
  question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (question_id, user_id)
);


-- ============================================================
-- 7. comments
-- ============================================================

CREATE TABLE public.comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  content     TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('comment', 'discussion')),
  answer_id   UUID REFERENCES public.answers(id)   ON DELETE CASCADE,  -- comment 타입만
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,  -- discussion 타입만
  parent_id   UUID REFERENCES public.comments(id)  ON DELETE CASCADE,  -- 1단계 대댓글만
  is_blinded  BOOLEAN NOT NULL DEFAULT false,
  is_deleted  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 8. notifications
-- ============================================================

CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type        TEXT NOT NULL
                CHECK (type IN ('new_answer', 'answer_accepted', 'new_comment')),
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
  answer_id   UUID REFERENCES public.answers(id)   ON DELETE CASCADE,
  is_read     BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 9. reports
-- ============================================================

CREATE TABLE public.reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('question', 'answer', 'comment')),
  target_id   UUID NOT NULL,               -- FK 없음. 삭제 후에도 신고 기록 보존
  reason      TEXT NOT NULL
                CHECK (reason IN ('spam', 'inappropriate', 'harassment', 'other')),
  detail      TEXT,
  status      TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'reviewed', 'dismissed')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 소셜 유저 중복 신고 방지 (reporter_id IS NOT NULL 조건부 UNIQUE)
CREATE UNIQUE INDEX idx_reports_unique_reporter
  ON public.reports (reporter_id, target_type, target_id)
  WHERE reporter_id IS NOT NULL;


-- ============================================================
-- 10. withdrawal_logs
-- ============================================================

CREATE TABLE public.withdrawal_logs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL,              -- FK 없음. 탈퇴 후에도 보존
  email        TEXT NOT NULL,
  provider     TEXT NOT NULL,
  withdrawn_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 11. 비즈니스 로직 트리거
-- ============================================================

-- 11-1. answers_count 동기화
CREATE OR REPLACE FUNCTION public.sync_answers_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.questions SET answers_count = answers_count + 1 WHERE id = NEW.question_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.questions SET answers_count = GREATEST(0, answers_count - 1) WHERE id = OLD.question_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_answers_count
  AFTER INSERT OR DELETE ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.sync_answers_count();


-- 11-2. likes_count 동기화
CREATE OR REPLACE FUNCTION public.sync_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.questions SET likes_count = likes_count + 1 WHERE id = NEW.question_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.questions SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.question_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_likes_count
  AFTER INSERT OR DELETE ON public.question_likes
  FOR EACH ROW EXECUTE FUNCTION public.sync_likes_count();


-- 11-3. comments_count 동기화 (INSERT / DELETE / 소프트 삭제)
CREATE OR REPLACE FUNCTION public.sync_comments_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_question_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.answer_id IS NOT NULL THEN
      SELECT question_id INTO v_question_id FROM public.answers WHERE id = NEW.answer_id;
    ELSE
      v_question_id := NEW.question_id;
    END IF;
    UPDATE public.questions SET comments_count = comments_count + 1 WHERE id = v_question_id;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.answer_id IS NOT NULL THEN
      SELECT question_id INTO v_question_id FROM public.answers WHERE id = OLD.answer_id;
    ELSE
      v_question_id := OLD.question_id;
    END IF;
    UPDATE public.questions SET comments_count = GREATEST(0, comments_count - 1) WHERE id = v_question_id;

  ELSIF TG_OP = 'UPDATE' THEN
    -- 소프트 삭제 (is_deleted: false → true) 시에만 -1
    IF OLD.is_deleted = false AND NEW.is_deleted = true THEN
      IF OLD.answer_id IS NOT NULL THEN
        SELECT question_id INTO v_question_id FROM public.answers WHERE id = OLD.answer_id;
      ELSE
        v_question_id := OLD.question_id;
      END IF;
      UPDATE public.questions SET comments_count = GREATEST(0, comments_count - 1) WHERE id = v_question_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_comments_count
  AFTER INSERT OR DELETE OR UPDATE OF is_deleted ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.sync_comments_count();


-- 11-4. last_activity_at 갱신 (답변/댓글 작성 시)
CREATE OR REPLACE FUNCTION public.update_last_activity_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_TABLE_NAME = 'answers' THEN
    UPDATE public.questions SET last_activity_at = now() WHERE id = NEW.question_id;
  ELSIF TG_TABLE_NAME = 'comments' THEN
    IF NEW.answer_id IS NOT NULL THEN
      UPDATE public.questions SET last_activity_at = now()
        WHERE id = (SELECT question_id FROM public.answers WHERE id = NEW.answer_id);
    ELSE
      UPDATE public.questions SET last_activity_at = now() WHERE id = NEW.question_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_last_activity_answers
  AFTER INSERT ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.update_last_activity_at();

CREATE TRIGGER trg_last_activity_comments
  AFTER INSERT ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_last_activity_at();


-- 11-5. profiles.last_*_at 갱신
CREATE OR REPLACE FUNCTION public.update_profile_last_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_TABLE_NAME = 'questions' THEN
    IF NEW.author_id IS NOT NULL THEN
      UPDATE public.profiles SET last_question_at = now() WHERE id = NEW.author_id;
    END IF;
  ELSIF TG_TABLE_NAME = 'answers' THEN
    IF NEW.author_id IS NOT NULL THEN
      UPDATE public.profiles SET last_answer_at = now() WHERE id = NEW.author_id;
    END IF;
  ELSIF TG_TABLE_NAME = 'comments' THEN
    IF NEW.author_id IS NOT NULL THEN
      UPDATE public.profiles SET last_comment_at = now() WHERE id = NEW.author_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_profile_last_question_at
  AFTER INSERT ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.update_profile_last_at();

CREATE TRIGGER trg_profile_last_answer_at
  AFTER INSERT ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.update_profile_last_at();

CREATE TRIGGER trg_profile_last_comment_at
  AFTER INSERT ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_profile_last_at();


-- 11-6. 채택 시 questions denormalize + profiles.accepted_count 증가 + 알림
CREATE OR REPLACE FUNCTION public.handle_answer_accepted()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_pokemon      public.pokemons%ROWTYPE;
  v_is_anonymous BOOLEAN;
BEGIN
  IF NEW.status = 'accepted' AND OLD.status <> 'accepted' THEN
    SELECT * INTO v_pokemon FROM public.pokemons WHERE id = NEW.pokemon_id;

    UPDATE public.questions SET
      status               = 'solved',
      accepted_answer_id   = NEW.id,
      accepted_pokemon_id  = v_pokemon.id,
      accepted_type1_ko    = v_pokemon.type1_ko,
      accepted_type2_ko    = v_pokemon.type2_ko,
      accepted_generation  = v_pokemon.generation
    WHERE id = NEW.question_id;

    IF NEW.author_id IS NOT NULL THEN
      UPDATE public.profiles
        SET accepted_count = accepted_count + 1
        WHERE id = NEW.author_id;

      -- answer_accepted 알림 (소셜 유저만)
      SELECT is_anonymous INTO v_is_anonymous
        FROM public.profiles WHERE id = NEW.author_id;

      IF v_is_anonymous = false THEN
        INSERT INTO public.notifications (user_id, type, question_id, answer_id)
        VALUES (NEW.author_id, 'answer_accepted', NEW.question_id, NEW.id);
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_answer_accepted
  AFTER UPDATE OF status ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.handle_answer_accepted();


-- 11-7. new_answer 알림
CREATE OR REPLACE FUNCTION public.notify_new_answer()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_question_author_id UUID;
  v_is_anonymous       BOOLEAN;
BEGIN
  SELECT author_id INTO v_question_author_id
    FROM public.questions WHERE id = NEW.question_id;

  IF v_question_author_id IS NULL THEN RETURN NEW; END IF;
  IF v_question_author_id = NEW.author_id THEN RETURN NEW; END IF;

  SELECT is_anonymous INTO v_is_anonymous
    FROM public.profiles WHERE id = v_question_author_id;

  IF v_is_anonymous = false THEN
    INSERT INTO public.notifications (user_id, type, question_id, answer_id)
    VALUES (v_question_author_id, 'new_answer', NEW.question_id, NEW.id);
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_new_answer
  AFTER INSERT ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_answer();


-- 11-8. new_comment 알림 (discussion 타입 및 자기 자신 제외)
CREATE OR REPLACE FUNCTION public.notify_new_comment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_answer_author_id UUID;
  v_question_id      UUID;
  v_is_anonymous     BOOLEAN;
BEGIN
  IF NEW.type != 'comment' THEN RETURN NEW; END IF;

  SELECT a.author_id, a.question_id
    INTO v_answer_author_id, v_question_id
    FROM public.answers a WHERE a.id = NEW.answer_id;

  IF v_answer_author_id IS NULL THEN RETURN NEW; END IF;
  IF v_answer_author_id = NEW.author_id THEN RETURN NEW; END IF;

  SELECT is_anonymous INTO v_is_anonymous
    FROM public.profiles WHERE id = v_answer_author_id;

  IF v_is_anonymous = false THEN
    INSERT INTO public.notifications (user_id, type, question_id, answer_id)
    VALUES (v_answer_author_id, 'new_comment', v_question_id, NEW.answer_id);
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_new_comment
  AFTER INSERT ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.notify_new_comment();


-- 11-9. view_count 증가 RPC 함수
CREATE OR REPLACE FUNCTION public.increment_view_count(p_question_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE public.questions
  SET view_count = view_count + 1
  WHERE id = p_question_id;
END;
$$;


-- 11-10. SECURITY DEFINER RPC — 익명 유저 질문 수정/삭제
CREATE OR REPLACE FUNCTION public.update_question_by_token(
  p_question_id UUID,
  p_token       UUID,
  p_title       TEXT,
  p_description TEXT,
  p_image_url   TEXT
)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.question_edit_tokens
    WHERE question_id = p_question_id AND token = p_token
  ) THEN RETURN false; END IF;

  UPDATE public.questions
  SET title       = p_title,
      description = p_description,
      image_url   = p_image_url,
      updated_at  = now()
  WHERE id            = p_question_id
    AND is_blinded    = false
    AND answers_count = 0
    AND status        = 'unsolved';

  RETURN FOUND;
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_question_by_token(
  p_question_id UUID,
  p_token       UUID
)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.question_edit_tokens
    WHERE question_id = p_question_id AND token = p_token
  ) THEN RETURN false; END IF;

  DELETE FROM public.questions
  WHERE id         = p_question_id
    AND is_blinded = false
    AND status     = 'unsolved';

  RETURN FOUND;
END;
$$;


-- ============================================================
-- 12. RLS (Row Level Security)
-- ============================================================

ALTER TABLE public.profiles           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_edit_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_likes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_logs    ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_select_all"  ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_self" ON public.profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_self" ON public.profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid()
    -- is_admin / is_anonymous / accepted_count / last_*_at 직접 수정 불가
    -- badge_id는 레벨 조건 검증 (프론트에서 사전 체크, DB에서 최종 방어)
  );
CREATE POLICY "profiles_delete_self" ON public.profiles FOR DELETE USING (id = auth.uid());

-- questions
CREATE POLICY "questions_select_all"  ON public.questions FOR SELECT USING (true);
CREATE POLICY "questions_insert_auth" ON public.questions FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "questions_update_own"  ON public.questions FOR UPDATE
  USING (author_id = auth.uid());
CREATE POLICY "questions_delete_own"  ON public.questions FOR DELETE
  USING (author_id = auth.uid());

-- question_edit_tokens: 모든 직접 접근 차단
CREATE POLICY "edit_tokens_no_access" ON public.question_edit_tokens
  FOR ALL USING (false);

-- answers
CREATE POLICY "answers_select_all"  ON public.answers FOR SELECT USING (true);
CREATE POLICY "answers_insert_auth" ON public.answers FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    -- 본인 질문에 본인 답변 불가
    AND NOT EXISTS (
      SELECT 1 FROM public.questions
      WHERE id = question_id AND author_id = auth.uid()
    )
  );
CREATE POLICY "answers_update_own"  ON public.answers FOR UPDATE
  USING (author_id = auth.uid());
CREATE POLICY "answers_delete_own"  ON public.answers FOR DELETE
  USING (author_id = auth.uid());

-- question_likes: 소셜 유저만 INSERT
CREATE POLICY "likes_select_all"    ON public.question_likes FOR SELECT USING (true);
CREATE POLICY "likes_insert_social" ON public.question_likes FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_anonymous = false
    )
  );
CREATE POLICY "likes_delete_own" ON public.question_likes FOR DELETE
  USING (user_id = auth.uid());

-- comments
CREATE POLICY "comments_select_all"  ON public.comments FOR SELECT USING (true);
CREATE POLICY "comments_insert_auth" ON public.comments FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "comments_delete_own"  ON public.comments FOR DELETE
  USING (author_id = auth.uid());

-- notifications: 본인 것만 조회/수정
CREATE POLICY "notifications_select_own" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid());

-- reports: 작성은 누구나, 조회/수정은 관리자만
CREATE POLICY "reports_insert_auth"   ON public.reports FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "reports_select_admin"  ON public.reports FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true));
CREATE POLICY "reports_update_admin"  ON public.reports FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true));

-- withdrawal_logs: 모든 직접 접근 차단 (service_role만 접근)
CREATE POLICY "withdrawal_logs_no_access" ON public.withdrawal_logs
  FOR ALL USING (false);


-- ============================================================
-- 13. 인덱스
-- ============================================================

CREATE INDEX idx_questions_tab_status          ON public.questions(tab, status);
CREATE INDEX idx_questions_author              ON public.questions(author_id);
CREATE INDEX idx_questions_created             ON public.questions(created_at DESC);
CREATE INDEX idx_questions_likes               ON public.questions(likes_count DESC);
CREATE INDEX idx_questions_accepted_types      ON public.questions(accepted_type1_ko, accepted_type2_ko);
CREATE INDEX idx_questions_accepted_generation ON public.questions(accepted_generation);
CREATE INDEX idx_questions_expiry              ON public.questions(tab, status, last_activity_at, created_at);
CREATE INDEX idx_answers_question              ON public.answers(question_id);
CREATE INDEX idx_answers_author                ON public.answers(author_id);
CREATE INDEX idx_comments_answer               ON public.comments(answer_id);
CREATE INDEX idx_comments_question             ON public.comments(question_id);
CREATE INDEX idx_notifications_user            ON public.notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_reports_status                ON public.reports(status, created_at DESC);
CREATE INDEX idx_reports_target                ON public.reports(target_type, target_id);


-- ============================================================
-- 14. Cron Jobs
-- pg_cron 확장 활성화 후 별도 실행
-- Supabase 대시보드 > Database > Extensions > pg_cron 활성화
-- ============================================================

-- 14-1. expire-old-questions + cleanup-withdrawal-logs (매일 UTC 18:00 = KST 03:00)
-- SELECT cron.schedule(
--   'expire-old-questions',
--   '0 18 * * *',
--   $$
--     UPDATE public.questions
--     SET status = 'expired'
--     WHERE tab    = 'ask'
--       AND status = 'unsolved'
--       AND (
--         last_activity_at < now() - INTERVAL '30 days'
--         OR created_at    < now() - INTERVAL '90 days'
--       );
--   $$
-- );

-- SELECT cron.schedule(
--   'cleanup-withdrawal-logs',
--   '0 18 * * *',
--   $$
--     DELETE FROM public.withdrawal_logs
--     WHERE withdrawn_at < now() - INTERVAL '7 days';
--   $$
-- );

-- 14-2. verify-question-counts (매주 일요일 UTC 19:00 = KST 04:00)
-- SELECT cron.schedule(
--   'verify-question-counts',
--   '0 19 * * 0',
--   $$
--     UPDATE public.questions q
--     SET answers_count = a.actual
--     FROM (
--       SELECT question_id, COUNT(*) AS actual
--       FROM public.answers
--       GROUP BY question_id
--     ) a
--     WHERE q.id = a.question_id AND q.answers_count != a.actual;

--     UPDATE public.questions q
--     SET comments_count = c.actual
--     FROM (
--       SELECT
--         COALESCE(ans.question_id, com.question_id) AS question_id,
--         COUNT(*) AS actual
--       FROM public.comments com
--       LEFT JOIN public.answers ans ON com.answer_id = ans.id
--       WHERE com.is_deleted = false
--       GROUP BY COALESCE(ans.question_id, com.question_id)
--     ) c
--     WHERE q.id = c.question_id AND q.comments_count != c.actual;

--     UPDATE public.questions q
--     SET likes_count = l.actual
--     FROM (
--       SELECT question_id, COUNT(*) AS actual
--       FROM public.question_likes
--       GROUP BY question_id
--     ) l
--     WHERE q.id = l.question_id AND q.likes_count != l.actual;
--   $$
-- );