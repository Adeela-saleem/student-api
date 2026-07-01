<!--
  DECISIONS.template.md

  Instantiation instructions:
  - Copy this file to the project root as `DECISIONS.md` (outside
    `.framework/`, alongside `PROJECT_KNOWLEDGE.md`).
  - This is a single, project-root file per AGENT.md Section 4.4 —
    do not split it into per-stack files without first logging that
    split itself as a foundational-tier entry, citing the escalation
    trigger in AGENT.md Section 4.4.
  - Every entry, whether foundational or feature-level, uses the
    entry format below. Append new entries at the top (most recent
    first) so the current state of any given decision is the first
    thing a reader encounters.
  - A foundational-tier entry must exist BEFORE the decision it
    records is acted on in code, per architecture.md Section 4.2 —
    this file is not a changelog written after the fact.
-->

# Decisions Log — [Project Name]

This file is an ADR-style (Architecture Decision Record) log of
decisions made on this project, tiered as `foundational` or
`feature-level` per `AGENT.md` Section 4.3. Foundational entries are
binding until formally revisited per `architecture.md` Section 4.3 —
do not silently diverge from a logged foundational decision; raise a
new entry that explicitly supersedes it instead.

---

## Entry Format

Copy this block for each new entry:

```
### [Decision title] — [YYYY-MM-DD]

**Tier:** foundational | feature-level
**Status:** proposed | accepted | superseded | deprecated
**Decided by:** [name(s) / agent session reference]
**Supersedes:** [link/reference to a prior entry, if applicable —
  "none" otherwise]

**Context:**
[What prompted this decision — the problem or question that needed
an answer. State the actual need, not a generic justification, per
the framework's anti-hallucination/traceability standing rule.]

**Alternatives considered:**
- [Option A] — [why it was or wasn't chosen]
- [Option B] — [why it was or wasn't chosen]
- [Option C, including "do nothing / defer," if genuinely
  considered] — [why it was or wasn't chosen]

**Decision:**
[The actual decision, stated unambiguously enough that a future
reader doesn't have to infer it from the rationale.]

**Rationale:**
[Why this option won, tied explicitly to the trade-offs listed
above — not a rationale that could equally justify a different
choice.]

**Consequences / what this constrains going forward:**
[What this decision now forecloses or commits the project to —
per architecture.md Section 1's point that foundational decisions
constrain future choices, often non-obviously. State that
non-obvious constraint explicitly here so it isn't rediscovered the
hard way later.]
```

---

## Entries

*(No entries yet. The first entry in a newly instantiated project is
typically the stack declaration itself in `PROJECT_KNOWLEDGE.md`, if
establishing it required a real choice between alternatives — log it
here using the format above, tiered `foundational`, the moment that
choice is made.)*
