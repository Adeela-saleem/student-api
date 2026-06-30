# Skill: Testing

**Tier:** Mixed — establishing the project's overall test strategy and
coverage bar is foundational-tier; writing tests for a given feature
within that established strategy is feature-level. Load this file
whenever work involves writing, evaluating, or deciding the approach
for tests. This is the primary skill file behind the `tester.md`
persona and the `test` command.

---

## 1. The Test Pyramid, as a Default Shape

**1.1 — Most tests are unit tests; fewer are integration tests; fewer
still are end-to-end tests.**
The default shape — many fast, isolated unit tests at the base; a
smaller number of integration tests verifying components work together
correctly; a small number of end-to-end tests verifying critical user
flows through the real system — exists because each layer trades speed
and isolation for realism. A test suite inverted from this shape (many
slow end-to-end tests, few unit tests) is slow to run, slow to diagnose
when it fails, and brittle to unrelated changes.

**1.2 — The pyramid is a default, not a quota.**
A project with genuinely little business logic and mostly thin
integration points may legitimately lean more heavily on integration
tests. The shape exists to make conscious deviation visible and
explainable, not to force every project into an identical ratio
regardless of what it actually does.

---

## 2. What Gets Tested

**2.1 — Business logic and decision points get unit tests; trivial
pass-through code does not need one for its own sake.**
A function containing a conditional, a calculation, a transformation,
or any branching logic needs a unit test covering its branches. A
function that purely delegates to another already-tested function with
no logic of its own does not need a redundant test whose only purpose
is satisfying a coverage number.

**2.2 — Every public interface's documented error conditions (per
`core.md` Section 4.3) are covered by a test for each condition, not
just the happy path.**
If a function's contract states it can fail in three distinct ways, the
test suite verifies all three failure paths, not only the successful
case. A test suite that only ever exercises the happy path has not
actually verified the contract — it's verified one example of it.

**2.3 — Regression tests are added for every bug fix, reproducing the
bug before the fix and passing after it.**
A bug fix without an accompanying regression test is incomplete — the
same class of bug can silently reappear later with nothing to catch it.
The regression test should fail against the pre-fix code (verified by
writing the test first, or by temporarily reverting the fix to confirm
it fails) before being committed alongside the fix.

**2.4 — Edge cases are tested deliberately, not incidentally.**
Boundary conditions (empty input, maximum size, zero, negative numbers
where unexpected, concurrent access where relevant) are tested as a
deliberate checklist item for any function handling them — not left to
be caught by accident whenever a real input happens to trigger one.

---

## 3. Coverage as a Signal, Not a Target

**3.1 — A coverage percentage is a smoke detector, not a quality
score.**
Coverage tooling tells you what code *ran* during tests, not whether
what ran was meaningfully verified. A test that executes a function
without asserting anything about its behavior inflates coverage without
adding any actual verification. Coverage numbers are useful for finding
completely untested code, not for certifying that tested code is well
tested.

**3.2 — A minimum coverage threshold, where the project sets one, is
a floor that blocks obvious gaps — not evidence the test suite is
sufficient once met.**
If a project establishes a numeric coverage threshold (a foundational-
tier decision, logged in `DECISIONS.md`), it exists to catch the case
of a large chunk of new code shipping with no tests at all — treating
"we hit the threshold" as equivalent to "this is adequately tested" is
a misuse of the number.

**3.3 — Gaming the coverage number is treated as equivalent to not
testing at all.**
A test added specifically to execute a line of code without
meaningfully asserting on its behavior, purely to satisfy a coverage
gate, provides zero actual verification value and should be flagged in
review the same way a missing test would be — the coverage number it
produces is misleading, not merely unhelpful.

---

## 4. Test Independence and Reliability

**4.1 — Tests don't depend on execution order or shared mutable state
between them.**
Any test that only passes when run after another specific test, or
that leaves state behind that a later test silently relies on, is
fragile by construction. Each test sets up its own state and cleans up
after itself (or runs in isolation, e.g. a fresh database transaction
per test), regardless of what ran before it.

**4.2 — A flaky test (one that intermittently fails with no code
change) is fixed or removed — never tolerated as "just rerun it."**
A test suite where developers have learned to ignore certain failures
because "that one's just flaky" has stopped functioning as a safety net
for everything else as well, since a real, intermittent failure can now
hide behind the assumption that any given failure is the known-flaky
one. Flaky tests are a defect with the same priority as a flaky feature
in production code.

**4.3 — Tests don't depend on external systems they don't control,
unless that's specifically what's being tested (an integration test
against a real dependency, run separately from the unit suite).**
A unit test that makes a real network call to a third-party service is
not a unit test — it's an unreliable integration test mislabeled, and
it will fail for reasons unrelated to the code being tested. External
dependencies are mocked, stubbed, or faked at the unit level; genuine
integration tests against real external systems are run as a distinct,
clearly separated suite.

---

## 5. Applied Examples

*(No entries yet. Testing mechanics vary substantially by stack — e.g.
how mocking/stubbing is conventionally done in a dynamically typed
language versus a statically typed one, or how a frontend framework's
component-testing idiom differs from a backend service's unit-testing
idiom. Populate per the format in `skills/core.md` Section 8 once a
real project's declared stack and test tooling are known.)*
