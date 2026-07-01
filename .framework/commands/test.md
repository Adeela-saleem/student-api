# Command: test

**Activates:** `agents/tester.md`

---

## Trigger

This command activates the `tester` persona. It is triggered by:

- An explicit `/test` invocation, where the calling tool supports
  slash-style commands.
- A natural-language request to write tests, evaluate test coverage,
  or decide a testing approach for a feature or change.

## What Happens on Activation

1. The session-start gate (`AGENT.md` Section 1) must already be
   satisfied for this session; satisfy it first if not.
2. Load `agents/tester.md`.
3. `tester.md` Section 2 specifies which skill files to load; load
   those, including `skills/testing.md` at minimum, and
   `skills/error-handling.md` when the work involves testing failure
   paths.
4. Proceed per `tester.md` Section 3's operating procedure.

## Scope Note

If a request frames itself as "increase coverage" without a more
specific target, `tester.md` Section 3.5 applies: the response is to
find genuinely undertested logic per `testing.md` Section 2's actual
criteria, not to add low-value tests that move the coverage number
without adding real verification.
