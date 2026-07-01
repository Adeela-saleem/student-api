# Changelog

## v1.1.2 — Bugfix

### sync.sh — express not detected when a frontend framework is also present
- **Bug:** the express check inside `detect_stack()` was nested inside the
  condition `[[ -f "package.json" ]] && [[ "$frontend" == "none" ]]`. As soon
  as any frontend framework (react, vue, nextjs, angular, svelte) was detected,
  `$frontend` was no longer `"none"`, so the entire branch was skipped —
  leaving `backend=none` for any fullstack/monorepo project that declares both
  a frontend framework and express in the same `package.json`.
- **Fix:** the express check is now a standalone `if` block that runs after the
  main backend `elif` chain, gated only on `[[ "$backend" == "none" ]]` (no
  other backend file found yet) and `[[ -f "package.json" ]]` (the file is
  present). The `[[ "$frontend" == "none" ]]` guard is gone. A comment in the
  code explains why the guard was the bug and why it was removed.
- **Tested** against five cases:
  - react + express → `frontend=react, backend=node-express` ✓ (was the bug)
  - react only → `frontend=react, backend=node-js` ✓ (no regression)
  - express only → `frontend=node-js, backend=node-express` ✓ (no regression)
  - vue + express → `frontend=vue, backend=node-express` ✓ (new coverage)
  - pom.xml + package.json → `backend=java-spring-boot` (package.json fallback
    correctly blocked by `[[ "$backend" == "none" ]]`) ✓ (no regression)
- **Only file changed:** `sync.sh` lines 235–252. No other files touched.

## v1.1.1 — Bugfix

### sync.sh — sed delimiter crash on PROJECT_KNOWLEDGE.md auto-fill
- **Bug:** the five `sed -e` substitutions in the `PROJECT_KNOWLEDGE.md`
  auto-instantiation block used `|` as the sed delimiter, but the placeholder
  text (e.g. `[e.g. react-18 | vue-3 | none]`) itself contains literal `|`
  characters. sed treats each `|` inside the expression as a delimiter
  boundary, producing `unknown option to 's'` at char 31 and aborting with
  a non-zero exit. Every first sync of any new project would crash at this
  step, leaving `PROJECT_KNOWLEDGE.md` unwritten.
- **Fix:** changed all five sed delimiters from `|` to `@`. `@` is absent
  from all placeholder text and from all values `detect_stack()` can
  produce (verified: detected values are lowercase alphanumeric + hyphens,
  `none`, `unknown`, `N/A`, or the two known Django/FastAPI layout strings).
  A comment documenting the delimiter choice and the safety guarantee was
  added inline.
- **Tested against real template output** for: Java+Spring Boot+Postgres+Docker,
  Node+React+MongoDB+Vercel, Python+Django+Postgres+Docker, bare project
  (all none/unknown). All four cases produce clean stack blocks with no
  leftover brackets and no sed errors.
- **Only file changed:** `sync.sh` lines 307–319. No other files touched.

## v1.1.0

### 1. Stronger Auto-Trigger
- `templates/CLAUDE.template.md`: added unconditional gate paragraph stating
  the gate fires on every session's first message with no exceptions based on
  content or phrasing; presence of `CLAUDE.md` is itself the trigger.
- `AGENT.md` Section 1: rewrote trigger language — gate is now declared
  unconditional; removed the loophole that allowed trivial first messages to
  bypass substantive-output requirements. No existing rules removed or weakened.

### 2. Auto Stack Detection (priority reversal)
- `AGENT.md` Section 4.2: reversed routing priority — agent now auto-detects
  stack from project files first (`pom.xml`, `package.json`, `requirements.txt`,
  `go.mod`, etc.); declared `stack:` block is now "reference/override," not
  primary source of truth. Conflict safeguard retained: ambiguous signals → agent
  must ask, never guess.
- `templates/PROJECT_KNOWLEDGE.template.md`: updated `stack:` block heading and
  comment to reflect "reference/override" semantics.
- `sync.sh`: `detect_stack()` function added; `PROJECT_KNOWLEDGE.md` is now
  auto-instantiated on first sync with the detected stack pre-filled.

### 3. Language Matching (script consistency, not forced Roman Urdu)
- `skills/language-agnostic-behavior.md`: added Section 1a "Conversational
  Language Matching" — agent mirrors user's natural language mix in conversation;
  hard constraint: Latin script only regardless of vocabulary origin. Main rule
  (Section 1) governing produced artifacts is unchanged.

### 4. Close the student-api Gap
- `sync.sh`: added auto-instantiation of `PROJECT_KNOWLEDGE.md` and `DECISIONS.md`
  on first sync (parallel to existing `CLAUDE.md` logic); `PROJECT_KNOWLEDGE.md`
  is created with detected stack pre-filled rather than left as bare placeholders.
- `AGENT.md` Section 4.2: added "Proactive gap-fix at session start" rule — agent
  must offer to fix foundational gaps in the same turn rather than just flagging.

### 5. Native CLI / Slash Commands at Repo Root
- `templates/dot-claude-commands/build.md` (new): thin wrapper for `/build`.
- `templates/dot-claude-commands/decide.md` (new): thin wrapper for `/decide`.
- `templates/dot-claude-commands/review.md` (new): thin wrapper for `/review`.
- `templates/dot-claude-commands/test.md` (new): thin wrapper for `/test`.
- `sync.sh`: added `.claude/commands/` creation block — populates native slash
  command wrappers in the consumer repo on first sync, parallel to existing
  `.framework/commands/` (which remains unchanged and unaffected).
- `AGENT.md` Section 5: documented both command layers, wrapper format, and
  backward-compatibility guarantee for tools that don't support `.claude/commands/`.

## v1.0.0 — Initial Release

- Core framework structure established: agents/, commands/, skills/
- 11 skill files covering universal engineering principles (core, architecture,
  error-handling, api-design, security, testing, code-review,
  technology-handling, dependency-management, performance,
  language-agnostic-behavior)
- 4 agent personas: builder, reviewer, tester, architect
- 4 commands: build, review, test, decide
- PROJECT_KNOWLEDGE.md and DECISIONS.md templates
- sync.sh vendoring script for consumer repos
- AGENT.md master bootstrap file
