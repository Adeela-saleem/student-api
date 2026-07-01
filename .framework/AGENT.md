# AGENT.md — Framework Bootstrap

This is the master entry point for `org-framework`. Every AI agent session
operating on a repo that has vendored this framework reads this file first,
immediately after the consumer repo's root `CLAUDE.md` pointer file, and
before producing any response, recommendation, or code in that session.

If you are an AI agent reading this for the first time in a session: stop,
finish reading this file in full, then proceed to the read order in
Section 1 before doing anything else.

---

## 1. Session-Start Gate (mandatory, non-negotiable)

This is a **session-start gate**, not a per-turn requirement. Read the
following, in this exact order, once at the start of a session — and again
if the session's context is reset or compacted — then proceed normally for
the rest of that session without re-reading on every subsequent message.

1. `.framework/AGENT.md` — this file.
2. The relevant files in `.framework/skills/` — at minimum `core.md` and
   `language-agnostic-behavior.md` always; others as routed by the work
   at hand (see Section 4, Routing).
3. The relevant file in `.framework/agents/` for the role being invoked
   (see Section 3).
4. The project's own `PROJECT_KNOWLEDGE.md` (project root, not inside
   `.framework/`).
5. The project's own `DECISIONS.md` (project root).

**Why this order:** `AGENT.md` establishes the rules for interpreting
everything that follows. Skills establish universal and topic-specific
principles before any project-specific content is read, so that
project-specific content is interpreted *through* the framework's lens,
not the reverse. `PROJECT_KNOWLEDGE.md` and `DECISIONS.md` are read last
because they are the most specific and most likely to be relevant to the
immediate task, and should be freshest in context when work begins.

**Why a gate, not a per-prompt reload:** once these files are in context
for a session, re-reading them on every single message wastes effort
without behavioral benefit. The gate exists to guarantee they are read
*at least once, always, before the first line of output* — regardless of
which developer started the session or what they asked first. It does
not exist to be re-triggered by ordinary conversation; it re-triggers only
on a genuine context reset or compaction, when the agent can no longer
assume the prior reads are still in its working context.

**What "before any response" means in practice:** no code, no
recommendation, no architectural opinion, no file edit — nothing
substantive is produced until this gate has been satisfied for the
current session. A session that begins with a trivial question
("what does this function do?") may answer informally, but the moment
the conversation moves toward producing or recommending a change, the
gate must already be satisfied.

---

## 2. Language-Agnostic Output Behavior

The full rule lives in `skills/language-agnostic-behavior.md`; it is
referenced here because it is foundational enough to call out at the
bootstrap level. In short: a developer may prompt in English, Roman
Urdu, a mix of the two, formally, casually, or in shorthand — the agent
parses *intent* from whatever language or tone arrives, but the
*output* (code structure, naming, documentation, commit messages,
architectural patterns) is always produced following this framework's
fixed conventions, regardless of the input's language or register. The
input's language/tone never changes the output's structure.

---

## 3. How Agents, Commands, and Skills Interrelate

Three layers, each with a distinct job:

- **`skills/`** — the knowledge layer. Concept-level, stack-agnostic
  principles. Skills don't act; they inform whoever is acting.
- **`agents/`** — the role layer. Each file is a persona (`builder`,
  `reviewer`, `tester`, `architect`) defining *what that role is
  responsible for* and *which skills it must apply*. A persona doesn't
  replace the skills — it tells the agent which lens to apply them
  through.
- **`commands/`** — the trigger layer. A thin shortcut that activates a
  given persona. A command file maps a user-facing trigger (e.g. typing
  `/build`, or the natural-language equivalent "let's implement this")
  to "load and behave as `agents/builder.md`, which in turn applies
  `skills/core.md` plus whatever skills that persona's file specifies."

**Relationship, concretely:** a command activates a persona; a persona
specifies which skills govern its behavior and in what priority; skills
are the actual content the agent reasons from. None of the three layers
is optional, and none substitutes for another — a command with no
persona has nothing to activate, a persona with no skills has no
content to apply, and skills with no persona/command have no defined
trigger for when they apply versus when they're just background
knowledge.

**Default persona when no command is explicit:** if a session begins
with an ambiguous or general request that doesn't map cleanly to a
single command, default to `agents/builder.md` for implementation work
unless the request is clearly a review, a test-strategy question, or a
foundational/cross-cutting decision — in which case route to `reviewer`,
`tester`, or `architect` respectively per their trigger criteria in
Section 4 below.

---

## 4. Routing

### 4.1 — Skill routing (which skills/ files apply to a given task)

`core.md` and `language-agnostic-behavior.md` apply to every task,
unconditionally. Beyond those two, route by the nature of the work:

| Task involves... | Load |
|---|---|
| Module boundaries, structural/design-time decisions, anything foundational-tier | `architecture.md` |
| Designing how failures propagate, exception/Result patterns | `error-handling.md` |
| Designing or modifying an API contract, versioning, request/response shape | `api-design.md` |
| Auth, authz, secrets, handling untrusted input beyond the Section 6 baseline in `core.md` | `security.md` |
| Writing or evaluating tests, coverage, test strategy | `testing.md` |
| The review process itself, beyond the checklist in `core.md` | `code-review.md` |
| Adopting a stack convention, evaluating a new pattern/library at decision time | `technology-handling.md` |
| Adding, updating, removing, or auditing dependencies over time | `dependency-management.md` |
| A performance trade-off judgment call | `performance.md` |

Load only what's relevant to the task at hand — loading all ten skill
files for every session is unnecessary overhead; the table above exists
so routing is deliberate rather than guessed.

### 4.2 — Stack routing: declared, not purely inferred

`PROJECT_KNOWLEDGE.md` contains a mandatory, explicit `stack:`
declaration block (see
`templates/PROJECT_KNOWLEDGE.template.md`). **This declaration is the
authoritative source of truth** for which stack-specific guidance,
idiomatic conventions, and Applied Examples apply.

Auto-detection from project files (`package.json`, `requirements.txt`,
`Cargo.toml`, `pom.xml`, etc.) still runs, but **only as a verification
check against the declared stack** — never as the primary routing
mechanism. If auto-detection and the declared stack disagree (e.g. the
declaration says `backend: python-fastapi` but no FastAPI dependency is
present, or a `package.json` exists alongside a declaration that
mentions no JS/TS stack at all), the agent must flag the discrepancy
explicitly to the user and ask, rather than silently trusting one source
over the other.

**A `PROJECT_KNOWLEDGE.md` with no `stack:` block declared is itself a
foundational gap.** Do not silently proceed as if a stack were obvious
from file inspection alone. Raise it, and route the project toward
filling in the declaration (via the `architect` persona / `decide`
command if establishing it for the first time is itself a foundational
decision for that project) before producing stack-flavored output.

### 4.3 — Tiering: foundational vs. feature-level

Some decisions are load-bearing and cross-cutting — auth strategy, data
model conventions, module boundary rules, naming conventions at the
project level, error-response shape across layers, anything that other
future decisions will depend on. These are **foundational-tier** and
require explicit sign-off before being acted on: route through
`agents/architect.md` via the `decide` command, and log the outcome in
`DECISIONS.md` tagged `foundational`.

Everything else — implementing a feature within existing guardrails,
fixing a bug, adding a test, refactoring within an established pattern —
is **feature-level** and can be done autonomously by any contributor
(human or agent) without requiring sign-off, though it still must follow
every applicable skill file.

**When in doubt about which tier a decision belongs to:** ask. Treating
an ambiguous decision as feature-level by default, just to move faster,
is exactly the failure mode this tiering system exists to prevent. The
cost of an unnecessary escalation is small; the cost of a foundational
decision made silently and inconsistently across a codebase is not.

### 4.4 — Single-root-knowledge-files, with a documented split trigger

`PROJECT_KNOWLEDGE.md` and `DECISIONS.md` are single files at the
project root, internally sectioned by stack (e.g. `## Frontend`,
`## Backend`, `## Shared/Cross-Cutting`) — not fragmented into
per-stack subfolders or files. This is a deliberate V1 decision:
foundational, cross-cutting concerns (how frontend and backend agree on
an error shape, how an auth token flows between layers) are inherently
cross-stack and would be poorly served by a structure that fragments
authority along stack lines.

**Documented escalation trigger — when to reconsider splitting:**
treat a single-file structure as outgrown, and raise a foundational-tier
decision via `decide` to formally split it, only when at least one of
the following becomes true, not preemptively:
- `PROJECT_KNOWLEDGE.md` or `DECISIONS.md` has grown large enough that
  finding a relevant entry routinely requires more than a quick scan or
  search (a concrete sign: contributors start asking "where's the entry
  for X" instead of finding it themselves).
- The project has split into genuinely separate teams with separate
  release cadences per stack, such that a single shared file creates
  merge contention as a routine occurrence rather than an occasional one.
- The project has become a monorepo housing what are, in practice,
  multiple independent products rather than one product with multiple
  layers.

A split, if and when it happens, must itself be logged in
`DECISIONS.md` as a foundational-tier decision before being carried out,
with the specific trigger condition cited as the rationale — never as a
silent structural drift.

---

## 5. Vendoring & Versioning

This framework is consumed by project repos via `sync.sh`, which copies
this repo's contents into a `.framework/` folder inside the consumer
repo and stamps a `VERSION` file (commit SHA + sync timestamp). See
`sync.sh` and the consumer-repo structure for details.

`.framework/` is committed to each consumer repo — it is never
gitignored or treated as a generated/ignorable artifact. A fresh clone
of any consumer repo must have this framework's guidance physically
present and readable without any extra setup step, which is the entire
reason vendoring was chosen over a submodule, package, or symlink
approach.

An agent operating in a consumer repo should check `.framework/VERSION`
if there is any reason to suspect the vendored copy may be stale (e.g.
the user mentions a recent framework update, or behavior described here
doesn't match what's actually present in `.framework/`) — but should not
treat a routine session as requiring a version check by default.

---

## 6. Universal Scope

This framework applies to **every** developer interaction with an AI
agent on a project that has vendored it — every feature, every session,
by anyone: junior or senior, new to the project or long-tenured. It is
not an onboarding aid and must not be reintroduced as one. Onboarding a
new contributor faster is one *benefit* of this framework, not its
defining purpose or primary use case.

---

## 7. Anti-Hallucination / Traceability (standing meta-rule)

This rule governs how every other rule in this framework is applied,
not just how the framework itself was authored:

- No invented requirements. If something this framework doesn't cover
  comes up, say so and ask, rather than improvising a rule and
  presenting it as if it were already established.
- Any proposed addition to the framework itself — a new skill, a new
  persona, a new template field — must be flagged explicitly as
  proposed/optional until the user confirms it, never silently treated
  as already required.
- When something is genuinely ambiguous, or a real fork in approach
  exists, ask rather than assume — especially for anything
  foundational-tier that other decisions will be built on top of later.
- This applies with the same weight to the agent's own reasoning about
  *this framework's* files as it does to reasoning about project code:
  verification and explicit confirmation are the default operating
  mode here, not an exception reserved for unusually risky changes.
