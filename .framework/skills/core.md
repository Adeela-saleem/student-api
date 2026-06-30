# Skill: Core

**Tier:** Foundational — loaded in every session, before any role-specific
or feature-specific file. Nothing in `agents/`, `commands/`, or any other
`skills/` file may relax a rule stated here. Other files may add stricter
constraints on top.

---

## 1. Purpose & Scope

`core.md` defines the universal baseline every contributor — human or AI
agent — operates under, regardless of role, stack, or feature. It is the
first skill file loaded after `AGENT.md` and applies unconditionally.

This file owns:
- Naming conventions (Section 2)
- Git workflow philosophy (Section 3)
- Documentation philosophy (Section 4)
- Error-handling philosophy, high-level only (Section 5)
- Security baseline (Section 6)
- Review checklist (Section 7)

This file explicitly does **not** own, and defers to the named skill file
instead:

| Concern | Owned by |
|---|---|
| Detailed error-handling mechanics (exception hierarchies, retry/backoff, error-response shapes) | `error-handling.md` |
| API contract design, versioning, request/response conventions | `api-design.md` |
| Threat modeling, auth/authz patterns, secrets handling specifics | `security.md` |
| Test strategy, coverage thresholds, test-pyramid shape | `testing.md` |
| Code review process mechanics beyond the checklist itself | `code-review.md` |
| Stack adoption, idiomatic conventions, dependency evaluation at decision time | `technology-handling.md` |
| Ongoing dependency lifecycle (updates, patching, pruning) | `dependency-management.md` |
| Performance trade-off judgment calls | `performance.md` |
| Input-language-to-output-behavior rules | `language-agnostic-behavior.md` |
| Structural/design-time decisions, module boundaries, foundational sign-off | `architecture.md` |

**Why this boundary list exists, explicitly:** `core.md` is the file every
session reads first and most often, which makes it the file most likely to
accumulate unrelated rules over time simply because it's already open —
exactly the silent-drift failure mode this framework exists to prevent
(Standing Rule: anti-hallucination/traceability). Any future addition to
this file must be checked against this table first: if it belongs in a
named skill file, it goes there, not here.

---

## 2. Naming Conventions

### Scope boundary

This section governs *what a name communicates*, not *what case style it
uses*. Case style (camelCase, snake_case, PascalCase, kebab-case for files,
etc.) is stack idiom and is owned by `technology-handling.md`, routed off
the declared stack in `PROJECT_KNOWLEDGE.md`. The principles below apply
identically whether the surrounding stack is React, Python, Rust, or
anything else — only the casing changes, never the underlying judgment.

### Principles

**2.1 — Names communicate intent, not implementation.**
A name should describe *what* a thing represents or does, not *how* it's
currently built. `userRepository` survives a swap from Postgres to Mongo;
`userPostgresTable` does not. If a name needs to change because an
implementation detail changed but the underlying concept didn't, the name
was wrong.

**2.2 — No abbreviations unless domain-standard.**
`cfg`, `tmp`, `idx` in a tight, obvious local scope (a 3-line loop) are
fine. Abbreviating a name that crosses a function boundary, gets exported,
or appears in a public interface is not — `usr`, `mgr`, `calc` as exported
identifiers force every future reader to decode them. Domain-standard
exceptions (`id`, `url`, `db`, `api`) are acceptable everywhere; invented
or team-local abbreviations are not.

**2.3 — Boolean and predicate naming uses a fixed prefix family.**
Booleans and predicate-returning functions read as a yes/no question:
`is`, `has`, `can`, `should` (e.g. `isActive`, `hasPermission`,
`canRetry`, `shouldRetry`). Avoid negative-form-only names (`isNotValid`,
`isDisabled` as the *only* form available) — prefer the positive predicate
and invert at the call site (`if (!isValid)`) so double-negatives never
appear in conditionals.

**2.4 — Avoid redundant context in nested members.**
If a name's surrounding scope already establishes context, repeating it
adds noise instead of clarity: `user.userName` inside a `User` type/class
should be `user.name`. Judge by how the name reads at its most common call
site, not in isolation.

**2.5 — Name length is proportional to scope, not personal preference.**
A loop counter spanning three lines (`i`, `j`) is appropriate because its
entire lifetime is visible at a glance. The moment a variable's scope
crosses a function boundary, gets returned, or is referenced far from its
declaration, it needs a name that stands on its own. There is no fixed
character-count rule — the test is: can a reader unfamiliar with this
function determine what this holds from the name alone, at the point they
encounter it.

**2.6 — Consistency within a scope is non-negotiable; consistency across
unrelated scopes is not.**
Within a single file, module, or feature, naming patterns must not be
mixed (don't use both `fetchUser` and `getOrder` for the same kind of
operation in the same file). Across genuinely unrelated parts of the
codebase, forcing global uniformity onto code with no shared context is
how naming bikeshedding consumes review time without improving
readability.

**2.7 — No magic literals; name the constant.**
Any literal value with implicit meaning (`if (status === 3)`,
`setTimeout(fn, 86400000)`) must be replaced with a named constant
(`STATUS_APPROVED`, `ONE_DAY_MS`) the first time it appears, not deferred
to "clean up later." An unnamed magic literal is flagged in review the
same way an unhandled error path is — as a defect, not a style nitpick.

**2.8 — Collections are pluralized; singular values are not.**
A variable holding multiple items is named in the plural (`users`,
`orders`); a variable holding one item from that collection is named in
the singular (`user`, `order`). This is the single most common source of
off-by-one and wrong-variable bugs in an unfamiliar codebase, which is why
it is stated explicitly rather than assumed obvious.

### Why these eight and not a longer list

This section stops at semantic principles that hold regardless of stack.
Anything requiring knowledge of the declared stack to state correctly
(e.g. "interfaces are prefixed with `I`," "test files end in `.spec`")
belongs in `technology-handling.md` or this skill's own Applied Examples
(Section 8) — not here. The test for inclusion in this section is "true
regardless of stack," not "related to naming in general."

---

## 3. Git Workflow Philosophy

**3.1 — Commits are atomic and self-explaining.**
One commit equals one logical change. A commit that mixes a bug fix with
an unrelated refactor or formatting pass is two commits that happened to
be written at the same time, not one commit. Commit messages use the
imperative mood ("Add retry to webhook handler," not "Added" or "Adding"),
state *what* changed in the subject line, and use the body — when the
change isn't self-evident — to explain *why*, since the diff already shows
*what*.

**3.2 — Branches are short-lived and named for what they contain.**
Feature/fix branches are cut from the trunk, named descriptively
(`fix/webhook-retry-timeout`, not `patch1` or a bare ticket number with no
context), and merged back as soon as the change is reviewable —
not held open accumulating unrelated commits. A branch that's been open
longer than the team's normal review cycle without merging is itself a
signal something's wrong (scope too large, blocked on a decision, or
abandoned) and should be flagged, not silently left open.

**3.3 — Rebase locally, never rewrite shared history.**
Cleaning up a branch's own commit history before opening a PR (squashing
fixup commits, reordering for a clean narrative) is encouraged. Force-
pushing over commits that another contributor has already pulled, or
rewriting history on a shared/trunk branch, is never acceptable —
the cost of broken local copies and lost work for collaborators always
outweighs the benefit of a cleaner log.

**3.4 — PRs are small enough to review properly.**
A PR mixing multiple unrelated concerns, or large enough that a reviewer
cannot reasonably hold the whole change in their head, is treated as a
process violation, not a productivity win. When a change is genuinely
large and indivisible, it must be flagged explicitly in the PR description
with a stated reason it couldn't be split, rather than submitted silently
at full size.

**3.5 — Foundational-tier changes carry a `DECISIONS.md` reference.**
Any commit or PR that touches a foundational-tier concern (per the tiering
system — see `architecture.md` and `AGENT.md`) must reference the
corresponding entry in `DECISIONS.md`. A foundational-tier change with no
linked decision entry is treated as incomplete, not as a fast-tracked
exception.

---

## 4. Documentation Philosophy

**4.1 — Document why, not what.**
Code already shows *what* it does to anyone willing to read it; comments
and docs exist to carry the *why* that the code cannot express on its own
— the rejected alternative, the non-obvious constraint, the business rule
behind a seemingly arbitrary number. A comment that restates the line
below it in English is noise and should be removed, not added.

**4.2 — Documentation is written with the change, not deferred.**
Documentation debt is treated the same as test debt or any other form of
incomplete work — a PR that changes behavior and leaves the relevant doc,
README, or interface comment stale or absent is not done, regardless of
whether the code itself is correct.

**4.3 — Public interfaces document their contract, not their internals.**
Any exported function, public class, or API endpoint carries a doc
comment describing: what it does, its inputs and outputs, the error
conditions a caller must handle, and any side effects (writes, network
calls, mutation of shared state). Internal/private implementation details
do not need the same treatment — comment density should track how far a
piece of code's audience extends beyond its author.

**4.4 — Decisions are logged, not just remembered.**
Any decision with foundational-tier weight gets an entry in
`DECISIONS.md` (see the template for required fields) at the time it's
made — not reconstructed later from memory, a Slack thread, or a PR
description that will eventually be buried in history. A decision that
exists only in someone's head or a closed conversation is, for the
purposes of this framework, treated as not having been made at all.

**4.5 — Stale documentation is worse than no documentation, and is a
defect.**
A doc, comment, or README that no longer matches the code it describes
actively misleads the next reader — worse than the gap left by no
documentation at all, since a missing doc at least prompts the reader to
go check the code. Any change that makes existing documentation inaccurate
must update that documentation in the same PR, not file a follow-up ticket
for "later."

---

## 5. Error-Handling Philosophy (High-Level)

This section states the *philosophy*. The *mechanics* — exception
hierarchies, `Result<T, E>` patterns, retry/backoff specifics, error
response shapes — are owned by `error-handling.md` and that file's
stack-specific Applied Examples, since those mechanics genuinely differ
by language and runtime.

**5.1 — Fail loud and fail fast at boundaries.**
An error that occurs at a system boundary (an external API call, a
database write, user input validation, a file read) must surface
immediately and explicitly. Swallowing an error silently — an empty
`catch` block, a logged-and-ignored failure, a default value substituted
without the caller's knowledge — is never acceptable, because it converts
a detectable failure into an undetectable one that surfaces later, further
from its cause, and harder to diagnose.

**5.2 — Errors are part of the interface contract.**
What can go wrong calling a function is not an implementation detail to
discover by accident — it is part of that function's public contract, on
equal footing with its return type. Wherever the language's type system
can express this (checked exceptions, `Result`/`Either` types, typed
error unions), it should. Where it can't, the documented contract
(Section 4.3) must state it explicitly.

**5.3 — Distinguish recoverable from unrecoverable errors as a concept.**
A recoverable error (a validation failure, a transient network timeout
worth retrying, a missing-but-creatable resource) is handled at the
appropriate layer and the caller is given a path forward. An unrecoverable
error (a violated invariant, a programmer error, corrupted state) should
not be caught-and-papered-over to keep the program limping along in an
inconsistent state — it should propagate to a point where it can be
logged with full context and the operation aborted cleanly.

**5.4 — Errors are never used for normal control flow.**
Throwing or returning an error to express an expected, non-exceptional
outcome (e.g. "item not found" in a lookup that's expected to sometimes
miss) is a misuse of the mechanism. Expected outcomes — including "not
found," "empty," or "no match" — are represented in the return type
itself (an optional/nullable value, an empty collection), reserving the
error path for things that are genuinely exceptional.

---

## 6. Security Baseline

This is the non-negotiable minimum that applies regardless of stack,
feature, or role. Everything beyond this baseline — threat modeling,
auth/authz pattern selection, secrets-management architecture — is owned
by `security.md`.

**6.1 — No secrets in version control, ever.**
Credentials, API keys, tokens, connection strings, or any other secret
value are never committed to git, in any commit, on any branch, including
ones intended to be squashed or deleted later — once written to a repo's
history, a secret must be treated as compromised even if the commit is
later removed. Secrets are sourced from environment variables or a secrets
manager, never hardcoded.

**6.2 — All external input is untrusted until validated.**
Any data originating outside the boundary of the code currently executing
— user input, a third-party API response, a file upload, a query
parameter, a webhook payload — is validated and sanitized at the point it
enters the system, before it is used in any logic, stored, or passed
downstream. "It's an internal tool" or "this endpoint isn't public" is
never a justification for skipping validation.

**6.3 — Principle of least privilege applies to every access decision.**
Any code, service account, API key, or role is granted the minimum access
required to perform its function — never broad access "in case it's
needed later." Expanding access later, when a genuine need arises, is
always preferable to narrowing access after the fact, because the latter
requires first discovering that excess access existed.

**6.4 — Dependency vulnerabilities are a security concern, not just a
hygiene concern.**
A known vulnerability in a dependency is treated with the same urgency as
a vulnerability in first-party code. The detailed lifecycle (scanning
cadence, patching SLAs, version pinning strategy) is owned by
`dependency-management.md`; this baseline only states that the concern
exists and cannot be deprioritized as routine maintenance.

**6.5 — Security-sensitive code paths require the relevant detailed
skill before proceeding.**
Any change touching authentication, authorization, secrets handling, or
direct processing of external/untrusted input must be evaluated against
`security.md` before being considered complete — this baseline section is
a floor, not a substitute for that review.

---

## 7. Review Checklist

This checklist is applied systematically by the `reviewer.md` persona
(via the `review` command) and is also the standard any contributor should
self-check against before requesting review. An item failing this
checklist is a defect to fix, not a stylistic suggestion to consider.

- [ ] **Naming** follows Section 2 (intent-revealing, no unjustified
      abbreviations, correct singular/plural usage, no magic literals).
- [ ] **Error handling** is present at every boundary the change touches,
      with no silently-swallowed failures (Section 5).
- [ ] **No secrets** (keys, tokens, credentials) introduced anywhere in
      the diff, including in test fixtures or example config (Section 6).
- [ ] **External input is validated** at the point it enters the change's
      code path, if the change touches a boundary (Section 6.2).
- [ ] **Public interfaces are documented** per Section 4.3 if the change
      adds or modifies one.
- [ ] **Stale documentation is updated**, not left inconsistent with the
      new behavior (Section 4.5).
- [ ] **Tests are added or updated** to cover the behavior change —
      see `testing.md` for the applicable bar.
- [ ] **No unaddressed `TODO`/`FIXME`** without a linked ticket or
      tracking reference.
- [ ] **New dependencies, if any, are justified** per
      `technology-handling.md` and `dependency-management.md` —
      not added without evaluation.
- [ ] **Foundational-tier changes have a corresponding `DECISIONS.md`
      entry** (Section 3.5) — feature-level changes do not require one.
- [ ] **Commit history is clean and atomic** (Section 3.1) — squash
      stray fixup commits before requesting review if the branch
      accumulated any.
- [ ] **Stack-declared conventions are followed**, verified against
      `PROJECT_KNOWLEDGE.md`'s `stack:` block and `technology-handling.md`.

---

## 8. Applied Examples

This subsection is intentionally **not pre-written**. Per the framework's
generic-skills standing rule, `core.md`'s main body (Sections 1–7) is pure,
stack-agnostic principle. Stack-specific flavor — a concrete example of how
a given principle in this file plays out in a particular language or
framework — is added here incrementally, only as the framework is actually
used on real projects with real stacks declared in their
`PROJECT_KNOWLEDGE.md`.

**How entries get added:** when a contributor (human or agent) encounters
a genuinely useful, non-obvious instance of applying one of the principles
above in a specific stack, it is added below as a short, dated entry —
never as a rewrite of the principle itself, and never speculatively for a
stack not actually in use on a project consuming this framework.

**Format for new entries:**

```
### <Principle reference, e.g. "2.3 — Boolean naming"> — <Stack, e.g. "Python/FastAPI">
<2–4 sentences showing the concrete application, with a short code
fragment if it clarifies more than prose alone would.>
<Date added, and which project/PR prompted it, for traceability.>
```

*(No entries yet — this framework has not been applied to a live project
with a declared stack. First entries should be added as soon as a
consumer repo runs `sync.sh` and a real `stack:` declaration exists in
that project's `PROJECT_KNOWLEDGE.md`.)*
