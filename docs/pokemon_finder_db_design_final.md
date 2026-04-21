# 📦 오늘의 포켓몬은 뭘까요? — 데이터베이스 설계 문서

> 이 문서는 서비스에서 사용하는 데이터베이스의 구조를 설명합니다.
> 비전공자도 읽을 수 있도록 각 용어와 설정에 대한 설명을 함께 작성했습니다.

---

## 📖 읽기 전에 — 용어 설명

| 용어                 | 쉬운 설명                                                                                             |
| -------------------- | ----------------------------------------------------------------------------------------------------- |
| **테이블**           | 엑셀의 시트처럼, 같은 종류의 데이터를 모아두는 공간                                                   |
| **컬럼**             | 엑셀의 열(列)처럼, 각 데이터의 항목 이름 (예: 이름, 나이)                                             |
| **PK (Primary Key)** | 각 행을 구별하는 고유 번호. 중복 불가                                                                 |
| **FK (Foreign Key)** | 다른 테이블의 데이터를 참조하는 연결고리                                                              |
| **UUID**             | 시스템이 자동으로 생성하는 고유 식별자 (예: `a3f2-...`)                                               |
| **NULL**             | 값이 없음 (비어있음)                                                                                  |
| **NOT NULL**         | 반드시 값이 있어야 함                                                                                 |
| **DEFAULT**          | 값을 입력하지 않았을 때 자동으로 채워지는 기본값                                                      |
| **트리거**           | 특정 동작이 발생하면 자동으로 실행되는 코드                                                           |
| **RLS**              | Row Level Security. 어떤 유저가 어떤 데이터를 볼 수 있는지 제한하는 보안 설정                         |
| **인덱스**           | 데이터 검색 속도를 높이기 위한 색인. 책의 목차와 같은 역할. Supabase Database > Indexes에서 확인 가능 |
| **CASCADE**          | 참조하는 데이터가 삭제되면 관련 데이터도 함께 삭제                                                    |
| **SET NULL**         | 참조하는 데이터가 삭제되면 해당 컬럼을 빈 값(NULL)으로 변경                                           |
| **SECURITY DEFINER** | RLS를 우회해 시스템 권한으로 실행되는 함수. 내부에서 조건을 직접 검증해야 함                          |
| **소프트 삭제**      | 실제로 데이터를 지우지 않고 `is_deleted = true`로 숨기는 방식                                         |
| **Edge Function**    | Supabase에서 제공하는 서버 코드 실행 환경. JavaScript로 작성하고 배포하면 스케줄에 맞게 자동 실행됨   |

---

## 🗂️ 테이블 목록 한눈에 보기

| 테이블                 | 역할                     | 프론트 직접 접근               |
| ---------------------- | ------------------------ | ------------------------------ |
| `pokemons`             | 포켓몬 도감 데이터       | 읽기만                         |
| `profiles`             | 회원 프로필              | 읽기 + 본인만 수정             |
| `questions`            | 질문 게시글              | 읽기 + 작성 + 조건부 수정/삭제 |
| `question_edit_tokens` | 익명 유저 수정/삭제 토큰 | 직접 접근 불가. RPC만          |
| `answers`              | 답변                     | 읽기 + 작성 + 조건부 수정/삭제 |
| `question_likes`       | 질문 좋아요 (= 북마크)   | 읽기 + 작성/삭제               |
| `comments`             | 댓글 / 토론              | 읽기 + 작성 + 삭제             |
| `notifications`        | 알림                     | 읽기 + 읽음 처리               |
| `reports`              | 신고 내역                | 작성만. 조회는 관리자만        |
| `withdrawal_logs`      | 탈퇴 기록                | 직접 접근 불가. 서버만         |

---

## 1. 🐾 pokemons — 포켓몬 도감

> 서비스에서 사용하는 포켓몬 데이터를 저장하는 테이블입니다.
> PokeAPI에서 가져온 데이터를 한국어로 가공해 저장하며, **1번~1025번** 포켓몬이 모두 등록되어 있습니다.
> 이 테이블은 서비스 초기에 한 번만 채워지고, 이후 변경되지 않습니다.

| 컬럼                | 타입        | 필수 | 기본값  | 설명                                 |
| ------------------- | ----------- | ---- | ------- | ------------------------------------ |
| `id`                | INT         | ✅   | —       | 포켓몬 번호 (PK). 피카츄 = 25        |
| `name_ko`           | TEXT        | ✅   | —       | 한국어 이름 (예: 피카츄)             |
| `type1_ko`          | TEXT        | ✅   | —       | 첫 번째 타입 (예: 전기)              |
| `type2_ko`          | TEXT        | ❌   | NULL    | 두 번째 타입. 단일 타입이면 비어있음 |
| `generation`        | INT         | ✅   | —       | 세대 (1~9)                           |
| `image_url`         | TEXT        | ✅   | —       | 공식 도감 이미지 주소                |
| `height_m`          | NUMERIC     | ✅   | —       | 키 (단위: 미터)                      |
| `weight_kg`         | NUMERIC     | ✅   | —       | 몸무게 (단위: kg)                    |
| `flavor_text_ko`    | TEXT        | ✅   | —       | 한국어 도감 설명                     |
| `category_ko`       | TEXT        | ✅   | —       | 분류 (예: 쥐포켓몬)                  |
| `gender_rate`       | INT         | ✅   | —       | 성별 비율. -1이면 성별 없음          |
| `ability1_ko`       | TEXT        | ✅   | —       | 특성1 한국어 이름                    |
| `ability2_ko`       | TEXT        | ❌   | NULL    | 특성2. 없는 포켓몬도 있음            |
| `ability_hidden_ko` | TEXT        | ❌   | NULL    | 숨겨진 특성. 없는 포켓몬도 있음      |
| `created_at`        | TIMESTAMPTZ | ✅   | `now()` | 데이터 등록일                        |

### 💻 프론트 가이드

- 읽기 전용. 쓰기 작업 없음
- 포켓몬 검색/선택 시 이 테이블에서 조회
- `type2_ko`가 NULL인 경우 단일 타입으로 처리

---

## 2. 👤 profiles — 회원 프로필

> 서비스를 이용하는 모든 사용자의 정보를 저장하는 테이블입니다.
> 처음 접속하면 자동으로 **익명 계정**이 만들어지고, 이후 Google / 카카오 로그인으로 업그레이드할 수 있습니다.

| 컬럼               | 타입        | 필수 | 기본값  | 설명                                                                |
| ------------------ | ----------- | ---- | ------- | ------------------------------------------------------------------- |
| `id`               | UUID        | ✅   | —       | 회원 고유 ID (PK). Supabase 인증 시스템과 연결됨                    |
| `nickname`         | TEXT        | ✅   | —       | 닉네임. UNIQUE 제약. 2~20자. 익명이면 `트레이너#YYYYMMDDHHmmss`     |
| `avatar_url`       | TEXT        | ❌   | NULL    | 프로필 사진 주소. 없으면 기본 이미지 표시                           |
| `bio`              | TEXT        | ❌   | NULL    | 소개글. 최대 80자                                                   |
| `is_anonymous`     | BOOLEAN     | ✅   | `true`  | 익명 여부. 소셜 로그인 후 `false`로 변경됨                          |
| `is_admin`         | BOOLEAN     | ✅   | `false` | 관리자 여부. Supabase 대시보드 또는 SQL Editor에서만 변경 가능      |
| `accepted_count`   | INT         | ✅   | `0`     | 채택된 답변 수. 레벨 계산에 사용됨. 트리거로만 변경됨               |
| `badge_id`         | INT         | ✅   | `0`     | 현재 장착한 뱃지 번호. 0=몬스터볼, 1=슈퍼볼, 2=하이퍼볼, 3=마스터볼 |
| `last_question_at` | TIMESTAMPTZ | ❌   | NULL    | 마지막 질문 작성 시각. 쿨타임 체크용                                |
| `last_answer_at`   | TIMESTAMPTZ | ❌   | NULL    | 마지막 답변 작성 시각. 쿨타임 체크용                                |
| `last_comment_at`  | TIMESTAMPTZ | ❌   | NULL    | 마지막 댓글 작성 시각. 쿨타임 체크용                                |
| `created_at`       | TIMESTAMPTZ | ✅   | `now()` | 가입일                                                              |
| `updated_at`       | TIMESTAMPTZ | ✅   | `now()` | 마지막 정보 수정일. 자동 갱신됨                                     |

### ⚙️ 설정 및 제약

**보안 (RLS)**

- 누구나 다른 사람의 프로필을 **읽을 수** 있습니다
- 본인 프로필만 **수정**할 수 있습니다
- 수정 가능한 컬럼: `nickname`, `badge_id`, `avatar_url`, `bio`
- 수정 불가 컬럼: `is_admin`, `is_anonymous`, `accepted_count`, `last_*_at`

> ⚠️ UPDATE 정책에 `WITH CHECK` 조건이 적용되어 있습니다. `is_admin`, `is_anonymous`, `accepted_count`는 클라이언트를 통해 절대 변경할 수 없습니다. 관리자 지정은 반드시 Supabase 대시보드 또는 SQL Editor(service_role 권한)에서만 가능합니다.

> ⚠️ `badge_id` 역시 RLS `WITH CHECK`로 레벨 조건을 검증합니다. 현재 `accepted_count`에서 계산된 레벨 이하의 뱃지만 장착할 수 있습니다.

**뱃지 레벨 검증 조건**

| badge_id | 뱃지 이름 | 장착 가능 조건 (`accepted_count`) |
| -------- | --------- | --------------------------------- |
| 0        | 몬스터볼  | 항상 가능                         |
| 1        | 슈퍼볼    | 5회 이상                          |
| 2        | 하이퍼볼  | 15회 이상                         |
| 3        | 마스터볼  | 65회 이상                         |

**자동 처리 (트리거)**

- 최초 가입 시 `generate_anonymous_nickname()` 함수로 닉네임 자동 생성
- 닉네임 충돌 시 `트레이너#YYYYMMDDHHmmss_1`, `_2` 형태로 자동 처리
- 질문·답변·댓글 작성 시 각 `last_*_at` 컬럼 자동 갱신
- `updated_at` 수정 시 자동 갱신

**레벨 시스템**

| 레벨 | 볼 종류  | 조건 (`accepted_count`) |
| ---- | -------- | ----------------------- |
| Lv.1 | 몬스터볼 | 0 ~ 4회                 |
| Lv.2 | 슈퍼볼   | 5 ~ 14회                |
| Lv.3 | 하이퍼볼 | 15 ~ 64회               |
| Lv.4 | 마스터볼 | 65회 이상               |

> 레벨은 DB에 저장하지 않습니다. 프론트 상수 `LEVEL_THRESHOLDS = [0, 5, 15, 65]`로 관리합니다.

### 💻 프론트 가이드

- 본인 프로필 수정 시 `nickname`, `badge_id`, `avatar_url`, `bio`만 요청에 포함
- `badge_id` 변경 전 현재 `accepted_count` 기준으로 가능한 레벨인지 프론트에서도 사전 검증 권장 (DB에서도 막히지만 UX상 미리 비활성화 처리)
- `is_anonymous` 값으로 소셜 로그인 여부 판단. 기능 접근 제한에 활용
- `accepted_count` 값으로 레벨 계산: `LEVEL_THRESHOLDS = [0, 5, 15, 65]`
- 다른 유저 프로필 표시 시 `avatar_url`이 NULL이면 기본 이미지로 대체

---

## 3. ❓ questions — 질문 게시글

> **알려줘!** (이름 모르는 포켓몬 질문)와 **누구게?** (실루엣 맞히기)를 하나의 테이블로 관리합니다.
> `tab` 컬럼으로 구분합니다.

| 컬럼                  | 타입        | 필수 | 기본값       | 설명                                                |
| --------------------- | ----------- | ---- | ------------ | --------------------------------------------------- |
| `id`                  | UUID        | ✅   | 자동생성     | 질문 고유 ID (PK)                                   |
| `author_id`           | UUID        | ❌   | NULL         | 작성자 ID. `profiles`와 연결. 탈퇴 시 NULL로 변경됨 |
| `tab`                 | TEXT        | ✅   | `'ask'`      | 탭 구분. `ask` = 알려줘! / `who` = 누구게?          |
| `title`               | TEXT        | ✅   | —            | 질문 제목. 5~100자                                  |
| `description`         | TEXT        | ✅   | —            | 특징 설명. 10~1000자                                |
| `status`              | TEXT        | ✅   | `'unsolved'` | 질문 상태. `unsolved` / `solved` / `expired`        |
| `image_url`           | TEXT        | ❌   | NULL         | 첨부 사진 또는 드로잉. 최대 1개                     |
| `reveal_text`         | TEXT        | ❌   | NULL         | 누구게? 전용. 채택 시 공개하는 정답 설명            |
| `reveal_image_url`    | TEXT        | ❌   | NULL         | 누구게? 전용. 채택 시 공개하는 정답 이미지          |
| `accepted_answer_id`  | UUID        | ❌   | NULL         | 채택된 답변 ID. 채택 시 자동으로 채워짐             |
| `accepted_pokemon_id` | INT         | ❌   | NULL         | 채택된 포켓몬 번호. 필터 속도를 위해 별도 저장      |
| `accepted_type1_ko`   | TEXT        | ❌   | NULL         | 채택 포켓몬의 타입1. 타입 필터용                    |
| `accepted_type2_ko`   | TEXT        | ❌   | NULL         | 채택 포켓몬의 타입2. 타입 필터용                    |
| `accepted_generation` | INT         | ❌   | NULL         | 채택 포켓몬의 세대. 세대 필터용                     |
| `likes_count`         | INT         | ✅   | `0`          | 좋아요 수. 트리거로만 변경됨                        |
| `answers_count`       | INT         | ✅   | `0`          | 답변 수. 트리거로만 변경됨                          |
| `comments_count`      | INT         | ✅   | `0`          | 댓글/토론 수. 트리거로만 변경됨                     |
| `view_count`          | INT         | ✅   | `0`          | 조회수. RPC 함수로만 증가                           |
| `is_blinded`          | BOOLEAN     | ✅   | `false`      | 관리자 블라인드 여부                                |
| `last_activity_at`    | TIMESTAMPTZ | ✅   | `now()`      | 마지막 활동 시각. 답변·댓글이 달릴 때마다 갱신      |
| `created_at`          | TIMESTAMPTZ | ✅   | `now()`      | 질문 작성일                                         |
| `updated_at`          | TIMESTAMPTZ | ✅   | `now()`      | 질문 수정일. 자동 갱신됨                            |

> ⚠️ `edit_token`은 이 테이블에 존재하지 않습니다. 별도 `question_edit_tokens` 테이블에서 관리됩니다.
> ⚠️ `author_id`가 NULL인 경우 탈퇴한 유저입니다. 프론트에서 "알 수 없음"으로 표시합니다.

### ⚙️ 설정 및 제약

**질문 상태 (`status`) 흐름**

```
unsolved (미해결)
    │
    ├─── 답변 채택 시 ──→ solved (해결됨)
    │
    └─── 30일간 활동 없음 또는 작성 후 90일 경과 ──→ expired (기간만료) ← ask 탭만 해당
```

**탭별 기능 차이**

| 항목              | ask (알려줘!)                               | who (누구게?)     |
| ----------------- | ------------------------------------------- | ----------------- |
| 작성 권한         | 익명 + 소셜                                 | 소셜만            |
| `edit_token` 발급 | 익명 유저만 (`question_edit_tokens` 테이블) | 발급 안 함        |
| `reveal_text`     | 사용 안 함                                  | 채택 시 필수 입력 |
| 기간 만료         | 30일 비활동 또는 90일 경과 시 자동 만료     | 만료 없음         |
| 세대·타입 필터    | 해결됨 탭에서 활성화                        | 없음              |

**수정 · 삭제 정책**

| 작업 | 조건                                        |
| ---- | ------------------------------------------- |
| 수정 | `answers_count = 0`일 때만 (시간 제한 없음) |
| 삭제 | `status = 'unsolved'`일 때만                |

> ⚠️ **익명 유저 수정·삭제**는 RLS가 아닌 Route Handler에서 처리됩니다. 내부적으로 `SECURITY DEFINER` RPC 함수(`update_question_by_token`, `delete_question_by_token`)를 호출하며, 이 함수들은 내부에서 아래 조건을 직접 검증합니다.

| 함수                       | 검증 조건                                                                      |
| -------------------------- | ------------------------------------------------------------------------------ |
| `update_question_by_token` | 토큰 일치 + `is_blinded = false` + `answers_count = 0` + `status = 'unsolved'` |
| `delete_question_by_token` | 토큰 일치 + `is_blinded = false` + `status = 'unsolved'`                       |

**삭제 시 CASCADE 정책**

| 연결 테이블                     | 처리 방식                                            |
| ------------------------------- | ---------------------------------------------------- |
| `answers`                       | CASCADE 삭제                                         |
| `comments` (question 직접 연결) | CASCADE 삭제                                         |
| `comments` (answer 경유 연결)   | answers CASCADE 삭제에 의해 연쇄 삭제                |
| `question_likes`                | CASCADE 삭제                                         |
| `question_edit_tokens`          | CASCADE 삭제                                         |
| `notifications`                 | CASCADE 삭제                                         |
| `reports`                       | FK 없음. 고아 레코드로 남음 (관리자 참고용으로 보존) |

### 💻 프론트 가이드

- `author_id`가 NULL이면 작성자 표시를 "알 수 없음"으로 처리
- `is_blinded = true`이면 내용 대신 "운영 정책에 의해 숨겨진 게시물입니다" 표시
- 타입 필터 구현 시 반드시 두 컬럼 모두 확인
  ```js
  // 올바른 방법
  .or(`accepted_type1_ko.in.(${types}),accepted_type2_ko.in.(${types})`)
  ```
- 조회수는 직접 UPDATE 금지. 반드시 RPC 함수 `increment_view_count(question_id)` 호출
- `likes_count`, `answers_count`, `comments_count`는 직접 UPDATE 금지. 트리거로만 변경됨
- 익명 유저 질문 수정/삭제는 `localStorage`에서 토큰을 꺼내 Route Handler로 전달
- `who` 탭 질문 작성은 `is_anonymous = false` 유저만 허용. 접근 전 사전 체크 필요

---

## 4. 🔑 question_edit_tokens — 익명 유저 수정/삭제 토큰

> 익명 유저가 자신의 질문을 나중에 수정·삭제할 수 있도록 발급하는 비밀 코드를 저장합니다.
> 보안을 위해 `questions` 테이블에서 분리된 별도 테이블입니다.

| 컬럼          | 타입        | 필수 | 기본값   | 설명                                    |
| ------------- | ----------- | ---- | -------- | --------------------------------------- |
| `question_id` | UUID        | ✅   | —        | 연결된 질문 ID (PK + FK → questions.id) |
| `token`       | UUID        | ✅   | 자동생성 | 수정/삭제용 비밀 코드                   |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()`  | 토큰 발급 시각                          |

### ⚙️ 설정 및 제약

**보안 (RLS)**

- 모든 유저의 직접 SELECT / INSERT / UPDATE / DELETE 차단
- 토큰 검증은 `SECURITY DEFINER` 함수 내부에서만 수행
- `questions` 삭제 시 CASCADE로 함께 삭제

> ⚠️ 이 테이블을 직접 조회하거나 수정하는 코드를 작성하면 안 됩니다. 반드시 RPC 함수를 통해서만 접근하세요.

### 💻 프론트 가이드

- 이 테이블에 직접 접근하는 코드 작성 금지
- 질문 작성 완료 시 서버에서 토큰을 딱 한 번 반환함
- 반환된 토큰을 `localStorage`에 저장
  ```js
  localStorage.setItem(`edit_token_${questionId}`, token);
  ```
- 수정/삭제 요청 시 저장된 토큰을 Route Handler에 전달
- 토큰이 `localStorage`에 없으면 수정/삭제 버튼 비표시

---

## 5. 💬 answers — 답변

> 답변은 반드시 **포켓몬 선택 + 근거 텍스트** 두 가지를 함께 작성해야 합니다.

| 컬럼          | 타입        | 필수 | 기본값   | 설명                                         |
| ------------- | ----------- | ---- | -------- | -------------------------------------------- |
| `id`          | UUID        | ✅   | 자동생성 | 답변 고유 ID (PK)                            |
| `question_id` | UUID        | ✅   | —        | 이 답변이 달린 질문 ID                       |
| `author_id`   | UUID        | ❌   | NULL     | 답변 작성자 ID. 탈퇴 시 NULL로 변경됨        |
| `pokemon_id`  | INT         | ✅   | —        | 선택한 포켓몬 번호. `pokemons`와 연결        |
| `content`     | TEXT        | ✅   | —        | 근거 텍스트. 5~500자                         |
| `status`      | TEXT        | ✅   | `'none'` | 답변 상태. `none` / `accepted` / `wrong`     |
| `drawing_url` | TEXT        | ❌   | NULL     | 누구게? 전용. 실루엣 위에 덧그린 이미지 주소 |
| `is_blinded`  | BOOLEAN     | ✅   | `false`  | 관리자 블라인드 여부                         |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()`  | 답변 작성일                                  |
| `updated_at`  | TIMESTAMPTZ | ✅   | `now()`  | 답변 수정일. 수정 시 자동 갱신됨             |

> ⚠️ `author_id`가 NULL인 경우 탈퇴한 유저입니다. 프론트에서 "알 수 없음"으로 표시합니다.

### ⚙️ 설정 및 제약

**답변 상태 (`status`)**

| 값         | 의미               | 누가 변경하나 |
| ---------- | ------------------ | ------------- |
| `none`     | 일반 답변 (기본값) | —             |
| `accepted` | 채택된 답변        | 질문 작성자   |
| `wrong`    | 틀린 답변으로 표시 | 질문 작성자   |

**수정 · 삭제 정책**

| 작업 | 조건                                             |
| ---- | ------------------------------------------------ |
| 수정 | `status = 'none'` + 해당 답변에 댓글이 없을 때만 |
| 삭제 | `status != 'accepted'`일 때만                    |

**보안 (RLS)**

- 로그인한 유저만 작성 가능 (쿨타임 5분)
- **본인 질문에 본인이 답변 불가** (DB 레벨 차단)
- `status = 'accepted'`인 답변은 **아무도 수정·삭제 불가** (전면 잠금)
- `status` 변경은 **질문 작성자만** 가능

### 💻 프론트 가이드

- `author_id`가 NULL이면 "알 수 없음"으로 표시
- `is_blinded = true`이면 "운영 정책에 의해 숨겨진 게시물입니다" 표시
- `updated_at`이 `created_at`과 다르면 "(수정됨)" 표시
- 수정 버튼 노출 조건: `status === 'none'` + 댓글 수 0
- 삭제 버튼 노출 조건: `status !== 'accepted'`
- `status = 'accepted'`이면 수정/삭제 버튼 완전 숨김

---

## 6. ❤️ question_likes — 질문 좋아요 (= 북마크)

> 좋아요는 북마크 개념으로, **본인 글에도 누를 수 있습니다.**
> **소셜 로그인 유저만** 누를 수 있습니다.

| 컬럼          | 타입        | 필수 | 기본값  | 설명                                        |
| ------------- | ----------- | ---- | ------- | ------------------------------------------- |
| `question_id` | UUID        | ✅   | —       | 좋아요를 누른 질문 ID                       |
| `user_id`     | UUID        | ✅   | —       | 좋아요를 누른 유저 ID. 탈퇴 시 CASCADE 삭제 |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()` | 좋아요 누른 시각                            |

- `(question_id, user_id)` 조합 UNIQUE → 중복 좋아요 방지
- 질문 삭제 시 CASCADE 삭제
- 유저 탈퇴 시 CASCADE 삭제

### 💻 프론트 가이드

- `is_anonymous = true` 유저에게는 좋아요 버튼 비활성화 또는 숨김
- 좋아요 여부 확인: 현재 유저 ID로 해당 question_id 레코드 존재 여부 조회
- `questions.likes_count`로 좋아요 수 표시 (이 테이블 직접 카운트 불필요)
- 좋아요 취소는 레코드 DELETE

---

## 7. 🗨️ comments — 댓글 / 토론

| 컬럼          | 타입        | 필수 | 기본값   | 설명                                        |
| ------------- | ----------- | ---- | -------- | ------------------------------------------- |
| `id`          | UUID        | ✅   | 자동생성 | 댓글 고유 ID (PK)                           |
| `author_id`   | UUID        | ❌   | NULL     | 작성자 ID. 탈퇴 시 NULL로 변경됨            |
| `content`     | TEXT        | ✅   | —        | 댓글 내용. 최대 300자                       |
| `type`        | TEXT        | ✅   | —        | `comment` = 답변 댓글 / `discussion` = 토론 |
| `answer_id`   | UUID        | ❌   | NULL     | `comment` 타입일 때 연결되는 답변 ID        |
| `question_id` | UUID        | ❌   | NULL     | `discussion` 타입일 때 연결되는 질문 ID     |
| `parent_id`   | UUID        | ❌   | NULL     | 대댓글일 때 직계 부모 댓글 ID               |
| `is_blinded`  | BOOLEAN     | ✅   | `false`  | 관리자 블라인드 여부                        |
| `is_deleted`  | BOOLEAN     | ✅   | `false`  | 본인 소프트 삭제 여부                       |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()`  | 댓글 작성일                                 |

> ⚠️ `author_id`가 NULL인 경우 탈퇴한 유저입니다. 프론트에서 "알 수 없음"으로 표시합니다.

### ⚙️ 설정 및 제약

**타입별 사용 규칙**

| `type` 값    | 필수 컬럼     | NULL이어야 하는 컬럼 | 사용 위치                      |
| ------------ | ------------- | -------------------- | ------------------------------ |
| `comment`    | `answer_id`   | `question_id`        | 답변 카드 아래 힌트 댓글       |
| `discussion` | `question_id` | `answer_id`          | 해결됨 / 만료된 질문의 토론 탭 |

> ⚠️ 위 규칙은 DB CHECK 제약으로 강제됩니다.

**대댓글 작성 규칙**

클라이언트는 `parent_id`만 서버에 전달합니다. 서버(Route Handler)가 부모 댓글을 조회해서 `answer_id` 또는 `question_id`를 직접 복사해 넣습니다.

```
클라이언트 요청: { parent_id: "abc123", content: "대댓글 내용" }
          ↓
Route Handler: 부모 댓글 조회 → answer_id 확인
          ↓
DB 저장: { parent_id: "abc123", answer_id: "부모의 answer_id", content: "..." }
```

**삭제 정책**

| 상황           | 처리 방식                         | `comments_count`        |
| -------------- | --------------------------------- | ----------------------- |
| 자식 댓글 없음 | 실제 `DELETE`                     | DELETE 트리거로 자동 -1 |
| 자식 댓글 있음 | `is_deleted = true` (소프트 삭제) | UPDATE 트리거로 자동 -1 |

**보안 (RLS)**

- 댓글 **수정 기능 없음**
- `comment` 타입 대댓글: **질문 작성자만** 가능
- `discussion` 타입: 로그인한 누구나 작성 및 대댓글 가능
- `discussion` 1시간 내 5회 초과 시 차단

### 💻 프론트 가이드

- `is_deleted = true`이면 내용 대신 "삭제된 댓글입니다" 표시. 대댓글은 그대로 표시
- `is_blinded = true`이면 "운영 정책에 의해 숨겨진 게시물입니다" 표시
- `author_id`가 NULL이면 "알 수 없음"으로 표시
- 대댓글 작성 시 `parent_id`만 서버에 전달. `answer_id` / `question_id` 직접 전달 금지
- 댓글 트리 렌더링: `parent_id`를 기준으로 트리 구조 구성

---

## 8. 🔔 notifications — 알림

> 소셜 유저 전용. 익명 유저는 알림을 받지 않습니다.

| 컬럼          | 타입        | 필수 | 기본값   | 설명                                      |
| ------------- | ----------- | ---- | -------- | ----------------------------------------- |
| `id`          | UUID        | ✅   | 자동생성 | 알림 고유 ID (PK)                         |
| `user_id`     | UUID        | ✅   | —        | 알림을 받을 유저 ID. 탈퇴 시 CASCADE 삭제 |
| `type`        | TEXT        | ✅   | —        | 알림 종류                                 |
| `question_id` | UUID        | ❌   | NULL     | 관련 질문 ID                              |
| `answer_id`   | UUID        | ❌   | NULL     | 관련 답변 ID                              |
| `is_read`     | BOOLEAN     | ✅   | `false`  | 읽음 여부                                 |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()`  | 알림 생성 시각                            |

**알림 종류 (`type`)**

| 값                | 발생 시점                | 자동 생성 방식   |
| ----------------- | ------------------------ | ---------------- |
| `new_answer`      | 내 질문에 답변이 달릴 때 | 답변 등록 트리거 |
| `answer_accepted` | 내 답변이 채택될 때      | 채택 트리거      |
| `new_comment `    | 내 답변에 댓글이 달릴 때 | 댓글 등록 트리거 |

- 질문 또는 답변 삭제 시 CASCADE로 함께 삭제
- 유저 탈퇴 시 CASCADE 삭제

### 💻 프론트 가이드

- `is_anonymous = true` 유저에게는 알림 UI 표시 안 함
- 알림 읽음 처리: `is_read = true`로 UPDATE
- `question_id` 또는 `answer_id`로 해당 게시물로 이동
- 알림 뱃지: `is_read = false` 개수로 표시
- Supabase Realtime으로 실시간 알림 수신 가능 (`notifications` 테이블 구독)

---

## 9. 🚨 reports — 신고 내역

> 익명 유저도 `auth.uid()`를 `reporter_id`에 저장합니다 (신고 제한 체크용).

| 컬럼          | 타입        | 필수 | 기본값      | 설명                                                            |
| ------------- | ----------- | ---- | ----------- | --------------------------------------------------------------- |
| `id`          | UUID        | ✅   | 자동생성    | 신고 고유 ID (PK)                                               |
| `reporter_id` | UUID        | ❌   | NULL        | 신고한 유저 ID. 탈퇴 시 NULL로 자동 변경됨 (ON DELETE SET NULL) |
| `target_type` | TEXT        | ✅   | —           | `question` / `answer` / `comment`                               |
| `target_id`   | UUID        | ✅   | —           | 신고 대상의 고유 ID. FK 없음                                    |
| `reason`      | TEXT        | ✅   | —           | `spam` / `inappropriate` / `harassment` / `other`               |
| `detail`      | TEXT        | ❌   | NULL        | 상세 사유. 선택 입력                                            |
| `status`      | TEXT        | ✅   | `'pending'` | `pending` / `reviewed` / `dismissed`                            |
| `created_at`  | TIMESTAMPTZ | ✅   | `now()`     | 신고 접수 시각                                                  |

> ⚠️ `target_id`는 실제 FK 연결이 없습니다. 신고 대상 게시물이 삭제되더라도 신고 레코드는 관리자 참고용으로 보존됩니다.
> ⚠️ `reporter_id`는 `ON DELETE SET NULL`로 참조합니다. 유저가 탈퇴하면 신고 기록은 보존되고 `reporter_id`만 NULL로 자동 변경됩니다.

**신고 제한 정책**

| 대상             | 제한                                                |
| ---------------- | --------------------------------------------------- |
| 모든 유저 (공통) | 동일 target 총 신고 합계 5개 도달 시 추가 신고 차단 |
| 소셜 유저        | 동일 target에 본인이 이미 신고했으면 추가 차단      |
| 익명 유저        | 공통 제한만 적용                                    |

**신고 처리 상태 (`status`)**

| 값          | 의미                          |
| ----------- | ----------------------------- |
| `pending`   | 신고 접수됨, 검토 전 (기본값) |
| `reviewed`  | 관리자 검토 완료, 조치함      |
| `dismissed` | 관리자 검토 완료, 기각        |

> 신고가 5개 쌓여도 자동으로 블라인드 처리되지 않습니다. 반드시 관리자가 직접 검토 후 처리합니다.

**보안 (RLS)**

- `status` 변경은 **관리자(`is_admin = true`)만** 가능

### 💻 프론트 가이드

- 신고 작성만 가능. 신고 목록 조회는 관리자 전용
- 신고 전 동일 target 신고 횟수 확인 (5개 도달 시 신고 버튼 비활성화)
- 소셜 유저는 본인이 이미 신고한 target인지 확인 후 버튼 비활성화
- `reason` 선택 UI 필수. `detail`은 선택 입력

---

## 10. 👋 withdrawal_logs — 탈퇴 기록

> 탈퇴한 유저의 이메일과 시각을 기록합니다.
> 탈퇴 후 7일간 재가입을 제한하기 위한 용도입니다.

| 컬럼           | 타입        | 필수 | 기본값   | 설명                                           |
| -------------- | ----------- | ---- | -------- | ---------------------------------------------- |
| `id`           | UUID        | ✅   | 자동생성 | 고유 ID (PK)                                   |
| `user_id`      | UUID        | ✅   | —        | 탈퇴한 유저 ID. FK 없음. 계정 삭제 후에도 보존 |
| `email`        | TEXT        | ✅   | —        | 탈퇴 시점 이메일. 재가입 제한 체크용           |
| `provider`     | TEXT        | ✅   | —        | `google` / `kakao`                             |
| `withdrawn_at` | TIMESTAMPTZ | ✅   | `now()`  | 탈퇴 시각                                      |

### ⚙️ 설정 및 제약

**보안 (RLS)**

- 모든 유저의 직접 SELECT / INSERT / UPDATE / DELETE 차단
- 서버(Edge Function / Route Handler)에서 service_role로만 접근 가능

**자동 삭제**

- 매일 새벽 3시 cron에서 `withdrawn_at` 기준 7일 경과 레코드 자동 삭제

### 💻 프론트 가이드

- 이 테이블에 직접 접근하는 코드 작성 금지
- 재가입 시도 시 서버에서 차단 응답이 오면 아래 메시지 표시
  ```
  "탈퇴 후 7일이 지나야 재가입할 수 있어요."
  ```

---

## 11. 🙈 블라인드 처리 (`is_blinded`)

> 관리자가 문제 있는 게시물을 숨기는 기능. 삭제가 아니라 숨김이므로 언제든 해제 가능.

| 테이블      | 컬럼         | 기본값  |
| ----------- | ------------ | ------- |
| `questions` | `is_blinded` | `false` |
| `answers`   | `is_blinded` | `false` |
| `comments`  | `is_blinded` | `false` |

```
is_blinded = false  →  내용 정상 표시
is_blinded = true   →  "운영 정책에 의해 숨겨진 게시물입니다" 표시
```

> `is_blinded`(관리자 처리)와 `is_deleted`(본인 삭제)는 목적이 다른 별도 컬럼입니다.
> 블라인드 처리된 게시물은 익명 유저의 `edit_token`으로도 수정·삭제할 수 없습니다.

---

## 12. 🚪 탈퇴 처리 정책

> 소셜 로그인 유저 전용. 익명 유저는 세션 종료로 처리되며 탈퇴 개념이 없습니다.

**기본 방향**

- 즉시 탈퇴. 유예 기간 없음
- 탈퇴 후 7일간 같은 이메일로 재가입 불가
- 탈퇴는 되돌릴 수 없음

**탈퇴 처리 흐름**

```
탈퇴 버튼 클릭
  └─→ withdrawal_logs에 기록 저장           [서버]
  └─→ auth.admin.deleteUser() 호출          [서버]
        └─→ auth.users 삭제                 [Supabase 자동]
        └─→ profiles CASCADE 삭제           [FK 자동]
              └─→ questions / answers / comments.author_id → NULL   [FK SET NULL 자동]
              └─→ question_likes / notifications → 삭제             [FK CASCADE 자동]
              └─→ reports.reporter_id → NULL                        [FK SET NULL 자동]
```

**재가입 시도 흐름**

```
로그인 시도
  └─→ 서버에서 withdrawal_logs 이메일 조회
        └─→ withdrawn_at 기준 7일 이내
              └─→ 차단. "탈퇴 후 7일이 지나야 재가입할 수 있어요" 메시지
        └─→ 7일 경과
              └─→ 정상 가입 진행
```

**데이터 처리 요약**

| 데이터                               | 처리 방식                               |
| ------------------------------------ | --------------------------------------- |
| 계정 정보 (이메일, 소셜 연결)        | 즉시 파기                               |
| 작성한 질문 / 답변 / 댓글            | 보존. 작성자 "알 수 없음"으로 표시      |
| 좋아요 / 알림                        | 즉시 삭제                               |
| 신고 내역 (`reporter_id`)            | 신고자 정보만 NULL 처리. 신고 기록 보존 |
| 탈퇴 이메일 기록 (`withdrawal_logs`) | 7일 후 자동 삭제                        |

**탈퇴 화면 안내 문구**

```
정말 탈퇴하시겠어요?

탈퇴 전 아래 내용을 확인해주세요.

계정 정보
· 탈퇴 즉시 계정이 삭제되며 되돌릴 수 없어요.
· 탈퇴 후 7일간 같은 계정으로 재가입할 수 없어요.

작성한 게시물
· 질문 · 답변 · 댓글은 삭제되지 않고
  작성자가 "알 수 없음"으로 표시된 채 유지돼요.
· 게시물 삭제를 원하시면 탈퇴 전에 직접 삭제해주세요.

개인정보
· 이메일 등 개인정보는 탈퇴 즉시 파기돼요.
· 신고 내역은 운영 목적으로 관리자에게만 보존될 수 있어요.

                [취소]  [탈퇴하기]
```

> "탈퇴하기" 버튼은 빨간색으로 위험 동작임을 시각적으로 강조합니다.

---

## ⏱️ 쿨타임 정책

| 대상                 | 쿨타임                    | 추적 컬럼                   |
| -------------------- | ------------------------- | --------------------------- |
| 질문 작성            | 30분                      | `profiles.last_question_at` |
| 답변 작성            | 5분                       | `profiles.last_answer_at`   |
| 댓글 작성            | 1분                       | `profiles.last_comment_at`  |
| discussion 도배 방지 | 1시간 내 5회 초과 시 차단 | RLS 서브쿼리                |

---

## 🔒 수정 · 삭제 정책 요약

| 대상        | 수정 가능 조건                       | 삭제 가능 조건                                    |
| ----------- | ------------------------------------ | ------------------------------------------------- |
| `questions` | `answers_count = 0` (시간 제한 없음) | `status = 'unsolved'`                             |
| `answers`   | `status = 'none'` + 댓글 없음        | `status != 'accepted'`                            |
| `comments`  | 수정 불가                            | 본인이면 가능 (자식 유무로 소프트/실제 삭제 분기) |

---

## 🔁 자동화 전체 흐름 요약

```
유저가 질문을 작성
  └─→ questions 테이블에 행 추가
  └─→ 익명 유저라면 question_edit_tokens에 토큰 자동 생성     [트리거 또는 Route Handler]
  └─→ profiles.last_question_at 자동 갱신                     [트리거]

유저가 답변을 작성
  └─→ answers 테이블에 행 추가
  └─→ questions.answers_count 자동 +1                         [트리거]
  └─→ questions.last_activity_at 자동 갱신                    [트리거]
  └─→ profiles.last_answer_at 자동 갱신                       [트리거]
  └─→ 질문 작성자에게 new_answer 알림 발송                    [트리거, 소셜 유저만]

유저가 답변을 수정
  └─→ answers.updated_at 자동 갱신                            [트리거]

유저가 답변을 삭제
  └─→ questions.answers_count 자동 -1                         [트리거]

질문 작성자가 답변을 채택
  └─→ answers.status → 'accepted' (이후 전면 잠금)
  └─→ questions.accepted_* 컬럼 자동 채움                     [트리거]
  └─→ questions.status → 'solved'                             [트리거]
  └─→ profiles.accepted_count 자동 +1                         [트리거]
  └─→ 답변 작성자에게 answer_accepted 알림 발송               [트리거, 소셜 유저만]

유저가 댓글을 작성
  └─→ comments 테이블에 행 추가
  └─→ questions.comments_count 자동 +1                        [트리거]
  └─→ questions.last_activity_at 자동 갱신                    [트리거]
  └─→ profiles.last_comment_at 자동 갱신                      [트리거]
  └─→ answers 작성자에게 new_comment 알림 발송                [트리거, 소셜 유저만, discussion 제외]  ← 여기로 이동

매일 새벽 3시 KST (자동 실행)
  └─→ ask 탭 · unsolved · last_activity_at 30일 초과 → expired 전환    [cron]
  └─→ ask 탭 · unsolved · created_at 90일 초과 → expired 전환          [cron]
  └─→ withdrawal_logs에서 withdrawn_at 7일 초과 레코드 삭제             [cron]

유저가 대댓글을 작성
  └─→ Route Handler에서 parent_id로 부모 댓글 조회
  └─→ 부모의 answer_id (또는 question_id) 복사
  └─→ comments 테이블에 행 추가

유저가 댓글을 삭제 (자식 없음 → 실제 DELETE)
  └─→ questions.comments_count 자동 -1                        [DELETE 트리거]

유저가 댓글을 삭제 (자식 있음 → is_deleted = true)
  └─→ questions.comments_count 자동 -1                        [UPDATE 트리거, WHEN 조건으로 중복 방지]
  └─→ 프론트에서 "삭제된 댓글입니다" 표시

유저가 좋아요를 누름
  └─→ question_likes 테이블에 행 추가
  └─→ questions.likes_count 자동 +1                           [트리거]

유저가 좋아요를 취소
  └─→ question_likes 테이블에서 행 삭제
  └─→ questions.likes_count 자동 -1                           [트리거]

익명 유저가 질문을 수정·삭제
  └─→ Route Handler에서 edit_token 수신
  └─→ SECURITY DEFINER RPC 함수 호출
      └─→ 함수 내부에서 조건 직접 검증
      └─→ 조건 불충족 시 false 반환 → Route Handler에서 실패 처리

유저가 탈퇴
  └─→ withdrawal_logs에 기록 저장                             [서버]
  └─→ auth.admin.deleteUser() 호출                            [서버]
        └─→ auth.users 삭제                                   [Supabase 자동]
        └─→ profiles CASCADE 삭제                             [FK 자동]
              └─→ questions / answers / comments.author_id → NULL   [FK SET NULL 자동]
              └─→ question_likes / notifications → 삭제             [FK CASCADE 자동]
              └─→ reports.reporter_id → NULL                        [FK SET NULL 자동]

매주 일요일 새벽 4시 KST (자동 실행)
  └─→ answers_count / comments_count / likes_count 실제 값과 비교       [cron]
  └─→ 불일치 발견 시 자동 교정                                          [cron]
```

---

## 🔑 인덱스 목록

| 인덱스 이름                         | 테이블          | 대상 컬럼                                         | 목적                         |
| ----------------------------------- | --------------- | ------------------------------------------------- | ---------------------------- |
| `idx_questions_tab_status`          | `questions`     | `tab`, `status`                                   | 탭별 상태 필터 조회          |
| `idx_questions_author`              | `questions`     | `author_id`                                       | 내 질문 목록 조회            |
| `idx_questions_created`             | `questions`     | `created_at` (내림차순)                           | 최신순 정렬                  |
| `idx_questions_likes`               | `questions`     | `likes_count` (내림차순)                          | 인기순 정렬                  |
| `idx_questions_accepted_types`      | `questions`     | `accepted_type1_ko`, `accepted_type2_ko`          | 해결됨 탭 타입 필터          |
| `idx_questions_accepted_generation` | `questions`     | `accepted_generation`                             | 해결됨 탭 세대 필터          |
| `idx_questions_expiry`              | `questions`     | `tab`, `status`, `last_activity_at`, `created_at` | 만료 cron 대상 조회          |
| `idx_answers_question`              | `answers`       | `question_id`                                     | 질문에 달린 답변 조회        |
| `idx_answers_author`                | `answers`       | `author_id`                                       | 내 답변 목록 조회            |
| `idx_comments_answer`               | `comments`      | `answer_id`                                       | 답변에 달린 댓글 조회        |
| `idx_comments_question`             | `comments`      | `question_id`                                     | 토론 댓글 조회               |
| `idx_notifications_user`            | `notifications` | `user_id`, `is_read`, `created_at`                | 내 알림 목록 조회            |
| `idx_reports_status`                | `reports`       | `status`, `created_at`                            | 관리자 신고 목록 조회        |
| `idx_reports_target`                | `reports`       | `target_type`, `target_id`                        | 특정 게시물의 신고 내역 조회 |

---

## ⏰ Cron Job 목록

### 1. expire-old-questions + cleanup-withdrawal-logs (매일 KST 03:00)

| 항목          | 내용                                                                                                             |
| ------------- | ---------------------------------------------------------------------------------------------------------------- |
| **실행 주기** | 매일 UTC 18:00 (KST 03:00)                                                                                       |
| **작업 1**    | ask 탭 · unsolved · `last_activity_at` 30일 초과 또는 `created_at` 90일 초과 → `expired` 전환 + 소셜 작성자 알림 |
| **작업 2**    | `withdrawal_logs` 에서 `withdrawn_at` 7일 초과 레코드 삭제                                                       |
| **제외 대상** | `who` 탭, 이미 `solved` / `expired`인 질문                                                                       |

### 2. verify-question-counts (매주 일요일 KST 04:00)

| 항목          | 내용                                             |
| ------------- | ------------------------------------------------ |
| **실행 주기** | 매주 일요일 UTC 19:00 (KST 04:00)                |
| **대상**      | `questions` 테이블의 카운트 컬럼 3개             |
| **검증 항목** | `answers_count`, `comments_count`, `likes_count` |
| **처리 내용** | 실제 행 수와 저장된 값이 다르면 자동 교정        |

---

## ⚠️ 타입 필터 구현 주의사항

```sql
-- 올바른 방법: 두 컬럼 모두 확인
WHERE (accepted_type1_ko = ANY($types) OR accepted_type2_ko = ANY($types))

-- 잘못된 방법: 이중 타입 포켓몬 누락
WHERE accepted_type1_ko = ANY($types)
```

> 예시: 리자몽(불꽃/비행)을 비행 타입으로 필터링할 때, `type1_ko`만 확인하면 누락됩니다.
