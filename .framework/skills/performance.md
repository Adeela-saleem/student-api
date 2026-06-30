# Skill: Performance

**Tier:** Feature-level judgment call, made on nearly every piece of
code regardless of the project's architecture. This file is distinct
from `architecture.md`: architecture is structural/design-time;
performance is the ongoing judgment of whether a specific piece of code
is "fast enough," made repeatedly as code is written, not just at
design time. Load this file whenever a change's performance
characteristics are genuinely in question — which, per Section 1, is
less often than intuition suggests.

---

## 1. Avoiding Premature Optimization

**1.1 — Correctness and clarity come first; optimize only what's
actually measured to matter.**
Code is written to be correct and readable first. Optimizing a piece
of code before establishing that it's actually a performance problem —
based on a guess about what's "probably slow" rather than a
measurement — routinely makes code harder to read and maintain in
exchange for a speed gain that may not even exist, or may not matter
even if it does.

**1.2 — "This might be slow" is not sufficient justification to
sacrifice clarity. "This is measured to be slow, and the cost is
material" is.**
Before trading readability or simplicity for performance, there should
be an actual measurement (a profiler, a benchmark, a production metric)
showing the current approach is a genuine bottleneck, and a reasoned
case that the cost of that bottleneck (latency, resource cost, user-
visible delay) is material enough to justify the trade-off.

**1.3 — Optimizing the wrong thing wastes the same effort as not
optimizing at all.**
Intuition about what's slow in a system is frequently wrong — the
actual bottleneck is often somewhere unexpected. Optimization effort
should follow measurement (profiling, tracing) to the place that's
actually costly, not whichever piece of code looks complicated or
"feels" like it should be slow.

---

## 2. When Performance Is a Standing Concern, Not an Afterthought

This file exists specifically because performance judgment is easy to
silently skip by default (per the framework's own stated rationale for
giving it an explicit skill file) — the following are cases where
performance must be considered as a standing part of the design, not
deferred until something is measured slow in production:

**2.1 — Anything operating on a collection of unbounded or
user-controlled size.**
A loop, query, or transformation whose cost scales with the size of an
input that a user or external system controls (not a fixed, small,
internally-controlled size) needs its scaling behavior considered up
front — not because it must be maximally optimized, but because an
unbounded-size assumption that holds in testing with small data can
fail catastrophically in production with real data.

**2.2 — Database access patterns, specifically N+1 query patterns.**
A loop that issues one database query per iteration, where a single
batched query could fetch the same data, is flagged in review every
time it appears — this specific pattern is common enough, and
expensive enough at scale, to warrant being checked explicitly rather
than only caught when it's already causing a measured problem.

**2.3 — Anything in a hot path — code that runs on every request, in a
tight loop, or at high frequency.**
Code identified (by actual traffic patterns, not assumption) as running
far more often than most other code in the system warrants more
careful performance consideration up front, because even a small
per-call cost compounds at that frequency in a way it wouldn't
elsewhere.

**2.4 — Synchronous operations that block on I/O in a context where
blocking has a multiplying cost (e.g. blocking the main thread in a
UI, or blocking a worker that could otherwise be serving other
requests).**
Where the stack and runtime model make blocking I/O costly beyond the
operation's own latency (it also blocks other unrelated work from
proceeding), that cost is considered explicitly when choosing between a
blocking and non-blocking approach — this is a case where "premature"
optimization concerns in Section 1 don't apply, because the cost model
is already known structurally, not merely guessed at.

---

## 3. Making the Trade-off Explicit

**3.1 — When clarity is deliberately sacrificed for measured
performance, that trade-off is documented at the point it's made.**
Per `core.md` 4.1 (document why, not what), a piece of code that looks
more complex than the problem seems to warrant, because it was
optimized in response to a measured bottleneck, should say so in a
comment or commit message — citing the measurement, not just asserting
"this is the fast version" — so a future reader doesn't simplify it
back into the slow version without realizing why it wasn't simple to
begin with.

**3.2 — A performance optimization that measurably matters and changes
how a whole subsystem is structured is foundational-tier; one localized
to a single function's implementation is feature-level.**
Per `architecture.md` Section 1's general test, a performance-driven
change is foundational only when it's expensive to reverse or
establishes a pattern (e.g. introducing a caching layer that other
features will come to depend on). A localized algorithmic improvement
inside one function, with no broader structural implication, is
feature-level and doesn't require sign-off — though Section 3.1's
documentation requirement still applies.

---

## 4. Applied Examples

*(No entries yet. Concrete performance idioms — what a caching layer
looks like, what "the standard way to batch queries" means — are
heavily stack- and tooling-dependent. Populate per the format in
`skills/core.md` Section 8 once a real project's stack, data layer, and
actual measured bottlenecks are known — entries here should ideally
cite a real measurement from a real case, per Section 3.1's own
discipline, rather than a hypothetical.)*
