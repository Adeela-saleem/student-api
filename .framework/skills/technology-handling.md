# Skill: Technology Handling

**Tier:** Decision-time concern. This file governs how the agent
follows the conventions of whatever stack a project has declared,
respects existing codebase patterns, and evaluates adopting something
new. Adopting a new stack, framework, or fundamentally new pattern for
a project is foundational-tier (route through `architecture.md` /
`decide`); following the already-declared stack's standard conventions
on a day-to-day basis is feature-level and is this file's main
concern.

This file is distinct from `dependency-management.md`: this file
governs the *decision* of whether to adopt a library, pattern, or
convention at all; `dependency-management.md` governs the *ongoing
lifecycle* of dependencies already adopted (updates, patching,
removal). A new dependency passes through this file first, then is
governed by `dependency-management.md` for the rest of its life in the
project.

---

## 1. Stack Routing — Declared, Not Inferred

This file's guidance routes off the `stack:` declaration in
`PROJECT_KNOWLEDGE.md`, per `AGENT.md` Section 4.2. Auto-detection from
project files runs only as a verification check against that
declaration — never as the primary mechanism. If this file's guidance
ever needs to determine "what stack is this," the declared value is
authoritative; a discrepancy with file-based detection is flagged and
asked about, not silently resolved.

---

## 2. Following Official/Standard Stack Conventions

**2.1 — Default to the stack's own official style guide and idiomatic
patterns, not a different stack's habits carried over by familiarity.**
A contributor more comfortable in one language should still write
idiomatic code in whatever language the project actually uses — e.g.
not writing Java-style verbose getter/setter boilerplate in a Python
codebase that idiomatically uses plain attributes, or not writing
deeply nested callback-style JavaScript in a codebase that's
standardized on `async`/`await`. Where the stack has an official or
de facto community style guide, that guide is the default, not a
suggestion to deviate from based on personal preference.

**2.2 — Idiomatic naming and folder conventions follow the stack's
norms, layered on top of (never contradicting) `core.md` Section 2's
semantic principles.**
`core.md` governs *what a name communicates*; this file governs *what
case style and file/folder convention the declared stack expects*
(e.g. `snake_case.py` filenames and modules in Python, PascalCase
component files in many React conventions, `kebab-case` route files in
others). Where the stack convention and a contributor's personal
preference differ, the stack convention wins, without exception, since
consistency across the codebase outweighs any individual's preference.

**2.3 — Where a stack offers more than one valid convention (e.g.
Django-style versus FastAPI-style Python project layout), the project
declares which one it follows, and that declaration — not the
language's general reputation — is authoritative.**
This is recorded in `PROJECT_KNOWLEDGE.md` alongside the `stack:`
block, since "the stack is Python" is not specific enough to determine
folder layout or idiomatic patterns on its own.

---

## 3. Respecting Existing Codebase Patterns

**3.1 — When an established pattern already exists in the codebase for
a given kind of problem, follow it rather than introducing a second,
different pattern for the same problem — even if a contributor
believes the new pattern is objectively better.**
Introducing a second pattern for something the codebase already has an
established way of doing is itself a foundational-tier decision (a new
standing convention), not a feature-level implementation choice — it
must go through `decide`, with the existing pattern's shortcomings and
the proposed alternative's benefits stated explicitly, rather than
being introduced silently inside an unrelated feature PR.

**3.2 — "The existing pattern is outdated" is a reason to propose a
foundational-tier change, not a license to deviate locally.**
If a contributor believes an established pattern should change, the
correct path is raising it as a proposed foundational decision — not
implementing a different approach in their own feature and leaving the
inconsistency for someone else to notice and reconcile later.

---

## 4. Evaluating New Dependencies/Libraries (Decision-Time)

**4.1 — A new dependency is evaluated against the problem it solves
versus what's already available, before being added.**
Before adding a library, confirm the problem isn't already solvable
with what the stack's standard library or an already-adopted dependency
provides. Adding a new dependency for something one line of existing
code could already do is unjustified weight on the project.

**4.2 — Evaluation criteria, applied deliberately rather than going
with whatever shows up first in a search:**
- **Maintenance status** — is it actively maintained, or effectively
  abandoned (no meaningful commits/releases in a long time, open
  security issues with no response)?
- **Community/ecosystem support** — is it widely adopted enough that
  documentation, examples, and help exist when something goes wrong, or
  is it obscure enough that the team would be largely on its own?
- **License compatibility** — is its license compatible with the
  project's own licensing and distribution model?
- **Footprint** — what does it add in terms of bundle size, install
  size, or transitive dependency count, relative to the problem it
  solves?
- **Version compatibility** — does it support the project's already-
  declared language/runtime version, and does adopting it constrain
  future upgrades of that runtime?

**4.3 — Adding a dependency that becomes load-bearing across multiple
modules is foundational-tier; adding one scoped to a single,
contained feature is feature-level.**
A new logging library used project-wide, or a new HTTP client adopted
as the project's standard, is foundational — it establishes a
convention others will be expected to follow. A library pulled in to
solve one contained, local problem inside a single feature, with no
expectation that other code will adopt it, is feature-level, though it
still must pass the evaluation in 4.2.

---

## 5. Applied Examples

*(No entries yet — this file is, by design, the one most directly
populated by stack-specific content over time, since "what is the
official style guide" and "what's the standard layout convention" are
inherently stack-specific questions. Populate per the format in
`skills/core.md` Section 8 as soon as a real project declares a stack
in `PROJECT_KNOWLEDGE.md` — e.g. a short entry noting that a Python/
FastAPI project follows PEP 8 plus the project's chosen layout
convention, with a link or citation to the specific style guide
adopted.)*
