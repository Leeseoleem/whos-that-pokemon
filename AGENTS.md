<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

<!-- BEGIN:token-efficiency -->
# Response Rules

- No preamble, no "Sure!", no closing summary. Lead with the change.
- Read the file before editing it. Never propose changes to code you haven't seen.
- Make surgical edits. Prefer Edit over Write. Never rewrite a file to change 3 lines.
- No speculative abstractions. Solve what was asked, nothing more.
- No added comments, docstrings, or type annotations on code you didn't change.
- No error handling for impossible cases. Trust framework guarantees.
- Test the assumption before declaring it fixed.
<!-- END:token-efficiency -->

<!-- BEGIN:project-context -->
# Stack (do not re-read package.json)

- **Framework**: Next.js 15 App Router, React 19, TypeScript 5
- **Styling**: Tailwind CSS v4 — syntax differs from v3, check docs before using
- **DB / Auth**: Supabase (`@supabase/supabase-js`, `@supabase/ssr`)
- **State**: Zustand 5
- **Forms**: react-hook-form 7
- **Deploy**: Cloudflare via `@opennextjs/cloudflare`
- **Package manager**: pnpm
- **Testing**: Vitest + Storybook (vitest browser mode)
<!-- END:project-context -->

<!-- BEGIN:file-conventions -->
# Before Creating Files

1. Search for an existing file that already does the job.
2. Prefer editing over creating. Three similar lines beats a premature abstraction.
3. New components go in `src/components/`, pages in `src/app/`.
<!-- END:file-conventions -->
