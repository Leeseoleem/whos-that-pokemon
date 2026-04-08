-- ============================================================
-- 오늘의 포켓몬은 뭘까요? — 전체 DB 스키마
-- pokemons 테이블은 seed 완료 상태이므로 제외
-- 실행 순서: 1→2→3→4(FK추가)→5→6→7→8→9 순으로 진행
-- ============================================================


-- ============================================================
-- 1. profiles
-- ============================================================

CREATE TABLE public.profiles (
  id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname       TEXT NOT NULL,
  avatar_url     TEXT,
  bio            TEXT,
  is_anonymous   BOOLEAN NOT NULL DEFAULT true,
  accepted_count INT     NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
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

-- 회원가입 시 profiles 자동 생성 트리거
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, is_anonymous)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '트레이너#' || floor(random() * 90000 + 10000)::TEXT),
    (NEW.raw_user_meta_data->>'provider' IS NULL OR NEW.raw_user_meta_data->>'provider' = 'anonymous')
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
  author_id            UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- 공통 필드
  tab                  TEXT NOT NULL DEFAULT 'ask'
                         CHECK (tab IN ('ask', 'who')),
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  status               TEXT NOT NULL DEFAULT 'unsolved'
                         CHECK (status IN ('unsolved', 'solved', 'expired')),
  image_url            TEXT,                    -- ask: 사진/드로잉 통합 1개 / who: 실루엣 이미지

  -- ask 전용
  edit_token           UUID,                    -- 익명 유저 수정용 토큰 (소셜=NULL)

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
  question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  author_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  pokemon_id  INT  NOT NULL REFERENCES public.pokemons(id),
  content     TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'none'
                CHECK (status IN ('none', 'accepted', 'wrong')),
  drawing_url TEXT,                             -- who 덧그리기 답변 시 저장 (ask=NULL)
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 4. questions.accepted_answer_id FK 추가 (순환 참조 해소)
-- ============================================================

ALTER TABLE public.questions
  ADD CONSTRAINT fk_accepted_answer
  FOREIGN KEY (accepted_answer_id) REFERENCES public.answers(id)
  DEFERRABLE INITIALLY DEFERRED;


-- ============================================================
-- 5. question_likes
-- ============================================================

CREATE TABLE public.question_likes (
  question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (question_id, user_id)
);


-- ============================================================
-- 6. comments
-- ============================================================

CREATE TABLE public.comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('comment', 'discussion')),
  answer_id   UUID REFERENCES public.answers(id)   ON DELETE CASCADE,  -- comment 타입만
  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,  -- discussion 타입만
  parent_id   UUID REFERENCES public.comments(id)  ON DELETE CASCADE,  -- 1단계 대댓글만
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 7. 비즈니스 로직 트리거
-- ============================================================

-- 7-1. answers_count 동기화
CREATE OR REPLACE FUNCTION public.sync_answers_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.questions SET answers_count = answers_count + 1 WHERE id = NEW.question_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.questions SET answers_count = answers_count - 1 WHERE id = OLD.question_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_answers_count
  AFTER INSERT OR DELETE ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.sync_answers_count();


-- 7-2. likes_count 동기화
CREATE OR REPLACE FUNCTION public.sync_likes_count()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.questions SET likes_count = likes_count + 1 WHERE id = NEW.question_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.questions SET likes_count = likes_count - 1 WHERE id = OLD.question_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_likes_count
  AFTER INSERT OR DELETE ON public.question_likes
  FOR EACH ROW EXECUTE FUNCTION public.sync_likes_count();


-- 7-3. 채택 시 questions denormalize + profiles.accepted_count 증가
CREATE OR REPLACE FUNCTION public.handle_answer_accepted()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_pokemon public.pokemons%ROWTYPE;
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

    UPDATE public.profiles SET accepted_count = accepted_count + 1
    WHERE id = NEW.author_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_answer_accepted
  AFTER UPDATE OF status ON public.answers
  FOR EACH ROW EXECUTE FUNCTION public.handle_answer_accepted();


-- ============================================================
-- 8. RLS (Row Level Security)
-- ============================================================

ALTER TABLE public.profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_likes  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments        ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY "profiles_select_all"   ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_self"  ON public.profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "profiles_update_self"  ON public.profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "profiles_delete_self"  ON public.profiles FOR DELETE USING (id = auth.uid());

-- questions
CREATE POLICY "questions_select_all"  ON public.questions FOR SELECT USING (true);
CREATE POLICY "questions_insert_auth" ON public.questions FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "questions_update_own"  ON public.questions FOR UPDATE
  USING (author_id = auth.uid());
CREATE POLICY "questions_delete_own"  ON public.questions FOR DELETE
  USING (author_id = auth.uid());

-- answers
CREATE POLICY "answers_select_all"    ON public.answers FOR SELECT USING (true);
CREATE POLICY "answers_insert_auth"   ON public.answers FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "answers_update_own"    ON public.answers FOR UPDATE
  USING (author_id = auth.uid());
CREATE POLICY "answers_delete_own"    ON public.answers FOR DELETE
  USING (author_id = auth.uid());

-- question_likes: 익명 유저 INSERT 차단
CREATE POLICY "likes_select_all"      ON public.question_likes FOR SELECT USING (true);
CREATE POLICY "likes_insert_social"   ON public.question_likes FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid() AND is_anonymous = false
    )
  );
CREATE POLICY "likes_delete_own"      ON public.question_likes FOR DELETE
  USING (user_id = auth.uid());

-- comments
CREATE POLICY "comments_select_all"   ON public.comments FOR SELECT USING (true);
CREATE POLICY "comments_insert_auth"  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "comments_delete_own"   ON public.comments FOR DELETE
  USING (author_id = auth.uid());


-- ============================================================
-- 9. 인덱스
-- ============================================================

CREATE INDEX idx_questions_tab_status  ON public.questions(tab, status);
CREATE INDEX idx_questions_author      ON public.questions(author_id);
CREATE INDEX idx_questions_created     ON public.questions(created_at DESC);
CREATE INDEX idx_questions_likes       ON public.questions(likes_count DESC);
CREATE INDEX idx_answers_question      ON public.answers(question_id);
CREATE INDEX idx_answers_author        ON public.answers(author_id);
CREATE INDEX idx_comments_answer       ON public.comments(answer_id);
CREATE INDEX idx_comments_question     ON public.comments(question_id);


-- ============================================================
-- 10. Cron Job — unsolved → expired 자동 전환 (ask 탭만)
-- pg_cron 확장 활성화 후 별도 실행:
-- Supabase 대시보드 > Database > Extensions > pg_cron 활성화
-- ============================================================

-- SELECT cron.schedule(
--   'expire-ask-questions',
--   '0 3 * * *',
--   $$
--     UPDATE public.questions
--     SET status = 'expired'
--     WHERE tab = 'ask'
--       AND status = 'unsolved'
--       AND created_at < now() - INTERVAL '30 days';
--   $$
-- );