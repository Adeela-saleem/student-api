# org-framework

A central, reusable AI agent framework: a generic, stack-agnostic
engineering "constitution" vendored into every project repo across an
organization so that an AI coding agent (or a human contributor)
behaves consistently regardless of who's prompting it, what they're
building, what language/tone they prompt in, or which technology stack
the underlying project uses.

This repo is not a single project — it's the source of truth that
other project repos pull from via `sync.sh`.

---

## What problem this solves

Even with skilled engineers, every contributor — human or AI — tends to
implicitly make their own calls on naming, error-handling style,
logging format, folder structure, dependency choices, and so on.
Without an enforced single source of truth, codebases drift
inconsistent over time, onboarding is slow because conventions live
only in people's heads, and AI coding agents specifically re-litigate
"how do we do this here" every single session, because they have no
persistent memory of it unless it's fed to them deliberately.

`org-framework` encodes "how we do things here" as a portable,
version-controlled scaffold that any AI agent or human reads — once,
at the start of every session — before producing any output.

---

## Repo structure

```
org-framework/
├── AGENT.md              ← master bootstrap file, read first by any
│                             agent session, every time
├── agents/                ← role-based personas (builder, reviewer,
│                             tester, architect)
├── commands/              ← triggers that activate a given persona
│                             (build, review, test, decide)
├── skills/                 ← concept-level, stack-agnostic knowledge
│                              (core, language-agnostic-behavior,
│                              architecture, error-handling, api-design,
│                              security, testing, code-review,
│                              technology-handling,
│                              dependency-management, performance)
├── templates/              ← PROJECT_KNOWLEDGE.template.md and
│                              DECISIONS.template.md, instantiated by
│                              each consumer project
└── sync.sh                 ← the vendoring script
```

A root `VERSION` file (this repo's own version pin) is optional and
not yet created — `sync.sh` reads it if present (to label the synced
copy, e.g. `framework@v1.0.0`) and falls back to `unversioned`
otherwise. Add one whenever this repo's first real release/tag is
cut; it isn't required for `sync.sh` or any other part of the
framework to function.

See `AGENT.md` for the full read order, routing rules, and the tiering
system (foundational vs. feature-level decisions) that governs how
this framework is actually applied.

---

## How a project consumes this framework

From the root of a consumer project repo:

```bash
curl -O https://raw.githubusercontent.com/<org>/org-framework/main/sync.sh
chmod +x sync.sh
./sync.sh --repo https://github.com/<org>/org-framework.git --branch main
```

(Or, more simply, once `sync.sh` is already vendored from a prior
sync: just re-run `.framework's` own copy of it.)

This fetches the framework and writes it into a `.framework/` folder
inside the consumer repo, stamping `.framework/VERSION` with the exact
commit synced and the timestamp. `.framework/` is committed to the
consumer repo — it is never gitignored — so that a fresh clone has the
framework's guidance physically present and readable with zero extra
setup.

On a **first** sync, also copy the two templates from
`.framework/templates/` to the consumer repo's root and fill them in:

```bash
cp .framework/templates/PROJECT_KNOWLEDGE.template.md ./PROJECT_KNOWLEDGE.md
cp .framework/templates/DECISIONS.template.md ./DECISIONS.md
```

`PROJECT_KNOWLEDGE.md` must have its `stack:` declaration block filled
in before an agent session can route any stack-specific guidance — see
`AGENT.md` Section 4.2.

---

## Updating an existing consumer repo to a newer framework version

Re-run `sync.sh` from the consumer repo's root. It replaces
`.framework/`'s contents with the latest fetch and re-stamps `VERSION`.
Review the resulting diff under `.framework/` like any other change
before committing it — a framework update is a normal, reviewable code
change in the consuming repo, not a silent background update.

---

## Contributing to this framework itself

Changes to this repo's `skills/`, `agents/`, or `commands/` files are,
by their nature, foundational-tier for every project that consumes
them — they should go through the same deliberate, alternatives-
considered discipline this framework asks of every consumer project's
own foundational decisions (see `architecture.md` Section 4 and the
`decide` command/`architect` persona for the pattern to follow).

`skills/*.md` files' "Applied Examples" sections are the one part of
this repo meant to grow incrementally and continuously, populated from
real usage across real consumer projects — see `skills/core.md`
Section 8 for the format. Contributions there are welcome at any time
and don't require the same foundational-tier process as changes to a
file's main principle body.
