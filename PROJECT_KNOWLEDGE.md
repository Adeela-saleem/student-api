<!--
  PROJECT_KNOWLEDGE.template.md

  Instantiation instructions:
  - Copy this file to the project root as `PROJECT_KNOWLEDGE.md`
    (outside `.framework/`, alongside `DECISIONS.md`).
  - Fill in every bracketed placeholder. Do not leave the `stack:`
    block partially filled — per AGENT.md Section 4.2, a missing or
    incomplete stack declaration is treated as a foundational gap,
    not a detail to fill in "later."
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

## Stack Declaration (mandatory — authoritative source of truth)

> This block is read by every agent session per `AGENT.md` Section 4.2
> and routes which stack-specific guidance and Applied Examples apply.
> File-based auto-detection (`package.json`, `requirements.txt`, etc.)
> runs only as a verification check against this block — never as the
> primary mechanism. If they disagree, that discrepancy must be
> flagged and resolved explicitly, not silently.

```
stack:
  frontend: none
  backend: java-spring-boot
  database: h2
  infra: none
  build_tool: maven
  layout_convention: standard Maven project layout (src/main/java, src/test/java)
```

If this project is a monorepo with multiple genuinely distinct
stacks per package/service, declare each distinct stack here and
state which directories each applies to. This is still a single file
per the single-root-knowledge-files rule — do not split into
per-stack files unless the escalation trigger in `AGENT.md`
Section 4.4 has been met and logged.

---

## Frontend

None — this is a backend-only project.
---

## Backend

Standard Spring Boot structure:
- Controllers: src/main/java/.../controller
- Services: src/main/java/.../service  
- Repositories: src/main/java/.../repository
- Models/Entities: src/main/java/.../model
---

## Shared / Cross-Cutting

N/A — backend only. No cross-layer contracts at this time.
---

## Known Deviations from Framework Defaults

None — project follows framework defaults.
