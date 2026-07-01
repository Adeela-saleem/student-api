# Command: decide

**Activates:** `agents/architect.md`

---

## Trigger

This command activates the `architect` persona. It is triggered by:

- An explicit `/decide` invocation, where the calling tool supports
  slash-style commands.
- Any point — within a `build`, `review`, or `test` session, or as a
  standalone request — where a question is identified as
  foundational-tier per `AGENT.md` Section 4.3 and
  `architecture.md` Section 1.
- A direct request to establish, document, or revisit a foundational
  convention (e.g. "what should our error response shape be," "should
  we adopt this auth pattern project-wide").

## What Happens on Activation

1. The session-start gate (`AGENT.md` Section 1) must already be
   satisfied for this session; satisfy it first if not.
2. Load `agents/architect.md`.
3. `architect.md` Section 2 specifies which skill files to load,
   always including `skills/architecture.md`, plus whichever
   domain-specific skill file the actual decision concerns.
4. Proceed per `architect.md` Section 3's operating procedure:
   confirm the question is genuinely foundational-tier, surface real
   alternatives, state the rationale, and produce a `DECISIONS.md`
   entry via `templates/DECISIONS.template.md` before any
   implementation proceeds.

## Handoff

Once a decision is signed off and logged, control returns to whichever
persona/command initiated the question (typically `build`) to carry
out the implementation. The `architect` persona itself does not
implement.

## Scope Note

If, on inspection, the question turns out not to meet the
foundational-tier bar after all, `architect.md` Section 3.1 applies:
say so explicitly and hand back to `build` rather than running the
full sign-off process on something that didn't need it.
