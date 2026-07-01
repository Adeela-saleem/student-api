<!--
  PROJECT_KNOWLEDGE.template.md

  Instantiation instructions:
  - Copy this file to the project root as `PROJECT_KNOWLEDGE.md`
    (outside `.framework/`, alongside `DECISIONS.md`).
  - The `stack:` block below is a reference/override, not a mandatory
    first fill. The agent auto-detects stack from project files at
    session start (per AGENT.md Section 4.2) and uses this block to
    add specificity or override detected values. Fill it in when the
    auto-detected stack needs clarification, version-pinning, or when
    you want to explicitly record architectural choices that project
    files alone cannot express.
  - Per AGENT.md Section 4.2, a missing or empty `stack:` block is
    a foundational gap the agent will proactively offer to fill from
    its detection — it is not a blocker on starting work.
  - This file is a single, project-root file per AGENT.md Section 4.4
    — do not split it into per-stack files or subfolders without
    first logging that split as a foundational-tier decision in
    DECISIONS.md, citing the escalation trigger from AGENT.md
    Section 4.4 that justifies it.
-->

# Project Knowledge — [Project Name]

**Framework version in use:** see `.framework/VERSION`
**Last updated:** [YYYY-MM-DD]
**Last updated by:** [name / agent session reference]

---

## Stack Declaration (reference/override — auto-detection runs first)

> The agent auto-detects stack from project files (`pom.xml`,
> `package.json`, `requirements.txt`, `go.mod`, etc.) at session start
> per `AGENT.md` Section 4.2. This block is the **reference and override**:
> use it to add specificity the files can't express (version pins, layout
> conventions, explicit architectural choices), to record the canonical
> agreed stack, or to override detection when detection would be wrong.
> A missing block is not a blocker — the agent will offer to fill it from
> detection. A block that conflicts with project files will be flagged for
> resolution rather than silently trusted.

```
stack:
  frontend: [e.g. react-18 | vue-3 | none]
  backend: [e.g. python-fastapi | node-express | java-spring-boot | none]
  database: [e.g. postgres-15 | mongodb | none]
  infra: [e.g. aws-ecs | vercel | self-hosted-docker]
  layout_convention: [e.g. "Django-style app layout" | "FastAPI-style routers" | "N/A"]
```

If this project is a monorepo with multiple genuinely distinct
stacks per package/service, declare each distinct stack here and
state which directories each applies to. This is still a single file
per the single-root-knowledge-files rule — do not split into
per-stack files unless the escalation trigger in `AGENT.md`
Section 4.4 has been met and logged.

---

## Frontend

[Frontend-specific conventions not already covered by the generic
skill files plus `technology-handling.md`'s stack routing — e.g.
component file organization specific to this project, state-
management approach, any deliberate deviation from the stack's
default convention and why. Leave explicitly empty with "Nothing
project-specific beyond the declared stack's standard conventions"
if there is nothing to add — do not pad this section to seem
complete.]

---

## Backend

[Backend-specific conventions not already covered by the generic
skill files plus `technology-handling.md`'s stack routing — e.g.
service layer organization, specific to this project's domain
boundaries, any deliberate deviation from the stack's default
convention and why.]

---

## Shared / Cross-Cutting

[Conventions that apply across both frontend and backend (or across
whatever the project's layers are) — e.g. the agreed error response
shape referenced from `error-handling.md` Section 5.1, the
authentication mechanism referenced from `security.md` Section 2.1,
shared data model conventions referenced from `architecture.md`
Section 3. Most entries here should reference a `DECISIONS.md` entry
rather than restating the rationale inline — this section records
*what's currently true*, `DECISIONS.md` records *why and when it was
decided*.]

---

## Known Deviations from Framework Defaults

[Any place this project deliberately deviates from a default stated
in the framework's skill files, with a one-line reason and a
`DECISIONS.md` reference if the deviation is foundational-tier. A
project with no deviations should state that explicitly rather than
leaving this section blank, so a reader knows the absence was
confirmed, not overlooked.]
