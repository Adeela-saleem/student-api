<!--
  CLAUDE.template.md

  Instantiation instructions:
  - This file is copied to the CONSUMER REPO ROOT as `CLAUDE.md`
    (NOT inside .framework/) — sibling to PROJECT_KNOWLEDGE.md and
    DECISIONS.md.
  - It is instantiated automatically by sync.sh on a project's FIRST
    sync only. sync.sh does not overwrite an existing root CLAUDE.md
    on subsequent syncs, since a project may have added
    project-specific notes below the marker line — see that line
    below for where project-specific content may safely be added.
  - Do not edit the content above the "Project-Specific Notes" marker
    unless the framework's read-order or gate behavior itself has
    changed — that content should stay in sync with .framework/AGENT.md.
-->
# CLAUDE.md

**This is the first file any AI agent session must read in this repository, before producing any response, recommendation, or code.**

This repo has vendored `org-framework` into `.framework/`. Before doing anything else in a new session (or after a context reset/compaction), read, in order:

1. `.framework/AGENT.md`
2. The relevant skill files under `.framework/skills/` — `core.md` and `language-agnostic-behavior.md` always; others as routed by `.framework/AGENT.md` Section 4.1
3. The relevant persona file under `.framework/agents/` for the work being done
4. `PROJECT_KNOWLEDGE.md` (this directory)
5. `DECISIONS.md` (this directory)

This is a **session-start gate**, not a per-message requirement — once read, these don't need to be re-read on every turn within the same session, only at session start and after a genuine context reset. Full rationale lives in `.framework/AGENT.md` Section 1.

**This gate applies to the FIRST message of every session, with no exceptions based on message content or phrasing.** It fires unconditionally — whether the first message is a feature request, a bug report, a question, or a simple greeting. The presence of this `CLAUDE.md` at the repo root is itself the trigger; no judgment about the nature of the first message is required or permitted.

If `PROJECT_KNOWLEDGE.md` or `DECISIONS.md` do not exist yet at this repo's root, instantiate them from `.framework/templates/` before proceeding with any substantive work — an unfilled `stack:` declaration is treated as a foundational gap per `.framework/AGENT.md` Section 4.2, not a detail to defer.

This applies to every developer using an AI agent on this repository, every session, regardless of who they are or what they're building — see `.framework/AGENT.md` Section 6.

---

## Project-Specific Notes

*(Nothing added yet. Project-specific notes that don't belong in PROJECT_KNOWLEDGE.md or DECISIONS.md — e.g. local dev environment quirks an agent should know about — may be added below this line. Do not duplicate content that belongs in PROJECT_KNOWLEDGE.md.)*
