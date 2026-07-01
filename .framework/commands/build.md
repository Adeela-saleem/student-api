# Command: build

**Activates:** `agents/builder.md`

---

## Trigger

This command activates the `builder` persona. It is triggered by:

- An explicit `/build` invocation, where the calling tool supports
  slash-style commands.
- A natural-language request to implement, write, add, fix, or
  refactor something, with no more specific command (`review`, `test`,
  `decide`) clearly indicated instead — per `AGENT.md` Section 3's
  default-persona rule.

## What Happens on Activation

1. The session-start gate (`AGENT.md` Section 1) must already be
   satisfied for this session. If it is not — e.g. this is the first
   substantive request of a fresh session — satisfy it before
   proceeding with the rest of this command.
2. Load `agents/builder.md`.
3. `builder.md` Section 2 specifies which skill files to load given
   the nature of the requested work; load those.
4. Proceed per `builder.md` Section 3's operating procedure.

## Scope Note

If, in the course of carrying out a `build` request, a foundational-
tier question surfaces (per `AGENT.md` Section 4.3), this command does
not attempt to resolve it inline. Pause, explain what's foundational
about the question, and hand off to the `decide` command before
continuing.
