# Command: review

**Activates:** `agents/reviewer.md`

---

## Trigger

This command activates the `reviewer` persona. It is triggered by:

- An explicit `/review` invocation, where the calling tool supports
  slash-style commands.
- A natural-language request to review, critique, check, or evaluate
  an existing diff, PR, or piece of code, rather than produce new
  changes.

## What Happens on Activation

1. The session-start gate (`AGENT.md` Section 1) must already be
   satisfied for this session; satisfy it first if not.
2. Load `agents/reviewer.md`.
3. `reviewer.md` Section 2 specifies which skill files to load given
   what the change under review actually touches; load those,
   including `skills/core.md` Section 7 (the checklist) and
   `skills/code-review.md` (the process) at minimum.
4. Proceed per `reviewer.md` Section 3's operating procedure, and
   report findings per Section 3.5 (blocking items first, clearly
   separated from non-blocking suggestions).

## Scope Note

If, while reviewing, the reviewer determines the change introduces an
undocumented foundational-tier decision (per `reviewer.md` Section
3.3), that is reported as a blocking finding on the review itself — it
does not trigger a separate `decide` invocation automatically, since
the appropriate next step (whether to formally raise it via `decide`)
belongs to the change's author, not the reviewer.
