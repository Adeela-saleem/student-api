# Skill: Dependency Management

**Tier:** Feature-level lifecycle concern, distinct from the
decision-time evaluation in `technology-handling.md`. This file governs
what happens to a dependency *after* it's been adopted: updates,
security patching, removal of unused dependencies, and pinning
strategy. Load this file for any work involving changing dependency
versions, auditing what's installed, or removing something no longer
used.

---

## 1. Why This Is Separate from `technology-handling.md`

`technology-handling.md` answers "should we adopt this dependency at
all" — a decision made once, at the point of adoption.
`dependency-management.md` answers "how do we keep what we've already
adopted healthy over time" — an ongoing concern that applies regardless
of how carefully the original adoption decision was made. A dependency
correctly adopted under `technology-handling.md`'s criteria can still
become a liability later if its lifecycle isn't actively managed —
which is exactly the silently-skipped concern this file exists to give
explicit ownership to.

---

## 2. Lock-File Discipline

**2.1 — A lock file (or stack equivalent) is committed and treated as
authoritative for exact installed versions.**
Wherever the stack's tooling produces a lock file, it is committed to
version control and treated as the source of truth for exactly which
versions are installed — not regenerated casually or ignored in favor
of trusting whatever a loose version range happens to resolve to at
install time.

**2.2 — Lock-file changes are reviewed with the same scrutiny as code
changes, not waved through as noise.**
A PR that updates the lock file is changing what code actually runs in
production, even though the diff looks like generated noise. At
minimum, the reviewer confirms the lock-file change matches an intended
dependency change stated in the PR — an unexplained, unrelated lock-
file diff accompanying an otherwise-unrelated change is a signal
something is off (a stale branch, an unintended `install` side effect)
and should be questioned, not merged silently.

---

## 3. Update Cadence

**3.1 — Dependency updates happen on a regular cadence, not only when
something breaks or a security issue forces the question.**
Letting dependencies drift indefinitely behind their latest stable
versions accumulates risk silently — each version behind makes the
eventual update larger, riskier, and more likely to bundle several
breaking changes at once instead of one at a time. A project should
have a stated, even if informal, cadence for routine update passes
(e.g. monthly), distinct from the urgent, out-of-cadence patching in
Section 4.

**3.2 — Routine updates are batched and tested together; major-version
upgrades are handled individually.**
Minor/patch-level updates across many dependencies can reasonably be
batched into one PR and tested as a group. A major-version upgrade of
any single dependency — which may carry breaking changes — is handled
as its own change, tested in isolation, so that if something breaks,
the cause is unambiguous.

---

## 4. Security Patching

**4.1 — A known vulnerability in a dependency is patched on an urgency
basis tied to its severity, not folded into the routine cadence in
Section 3.**
This extends `core.md` 6.4 and `security.md`: a critical or high-
severity vulnerability with an available fix is patched immediately,
out of cycle, ahead of the routine update cadence — not deferred to the
next scheduled pass.

**4.2 — Vulnerability scanning runs as a standing, automated check, not
a manual occasional audit.**
Wherever tooling exists for the stack (automated dependency-scanning in
CI, a registry's built-in advisory system), it is wired into the
project's standard pipeline so new vulnerabilities are surfaced
automatically as they're disclosed — relying on someone remembering to
check periodically is treated as inadequate coverage.

**4.3 — When no fix is yet available for a known vulnerability, the
exposure is assessed and explicitly documented (in `DECISIONS.md` if
the assessment concludes continued use is acceptable for now), not
silently ignored.**
"There's no patched version yet" is not the same as "there's nothing to
do" — at minimum, the actual exposure (is the vulnerable code path even
reachable in this project's usage) is assessed and the decision to
continue using the dependency in the meantime is recorded, with a
trigger condition for revisiting it (e.g. "revisit when a patch ships,
or by [date], whichever is first").

---

## 5. Pinning Strategy

**5.1 — The pinning strategy (exact version, caret/tilde ranges, or
another approach) is a foundational decision, made once and applied
consistently.**
Whether dependencies are pinned to exact versions or allowed to float
within a range is decided at the project level — logged in
`DECISIONS.md` — and applied uniformly, not chosen ad hoc per
dependency based on whoever added it.

**5.2 — Looser ranges are bounded by the lock file (Section 2), not
left to mean "whatever resolves at install time, indefinitely."**
A project using version ranges rather than exact pins relies on the
lock file to guarantee reproducible installs between machines and over
time — the range expresses what's *acceptable* on a deliberate update,
not what's *installed* on every fresh `install`.

---

## 6. Removing Unused Dependencies

**6.1 — A dependency with no remaining usage in the codebase is removed
as part of the change that removed its last usage, not left installed
"in case it's needed again."**
An unused dependency still carries its full footprint — install size,
attack surface, future update burden — for zero ongoing benefit. The
change that removes the last call site of a dependency removes the
dependency itself in the same PR.

**6.2 — A periodic audit checks for dependencies with no remaining
usage that were missed at removal time (e.g. a dependency only used in
code later deleted by a different change).**
Since usage can be removed without anyone explicitly checking whether
the dependency itself is now orphaned, a periodic audit (tooling-
assisted where available) catches drift that 6.1 alone won't, since 6.1
only covers the case where removal and last-usage-removal happen in the
same change.

---

## 7. Applied Examples

*(No entries yet. Tooling for lock files, vulnerability scanning, and
update automation (e.g. Dependabot/Renovate-equivalents) varies
significantly by ecosystem. Populate per the format in `skills/core.md`
Section 8 once a real project's stack and dependency tooling are
known.)*
