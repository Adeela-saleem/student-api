# Skill: Error Handling

**Tier:** Feature-level mechanics, building on the foundational
philosophy stated in `core.md` Section 5. Load this file whenever work
involves designing or implementing how failures propagate, get
represented, or get recovered from. The decision to *introduce a new,
project-wide error-handling pattern* (e.g. adopting a new error response
shape across all API layers) is itself foundational-tier and routes
through `architecture.md` / `decide` — this file governs the mechanics
once such a pattern exists, or governs day-to-day implementation within
an already-established pattern.

---

## 1. Relationship to `core.md`

`core.md` Section 5 states four philosophy-level rules: fail loud and
fast at boundaries, errors are part of the interface contract,
recoverable and unrecoverable errors are distinguished, and errors are
never used for normal control flow. This file assumes those four rules
as given and addresses the *how*.

---

## 2. Error Representation

**2.1 — Prefer the strongest error representation the language offers.**
Where the language/runtime supports it, errors are expressed in the
type system itself — a typed exception hierarchy, a `Result<T, E>` or
`Either` return type, a typed error union — rather than relying on
untyped exceptions, string messages, or magic sentinel values (`-1`,
`null` used to mean "failed" rather than "absent"). The specific
mechanism is stack-dependent (see Applied Examples); the principle —
make the failure mode visible at the type level wherever possible — is
not.

**2.2 — An error carries enough context to act on, not just to log.**
An error value or exception includes what's needed for the catching
code (or a human reading a log) to understand what failed and why —
not just a generic message. At minimum: what operation was being
attempted, what input or state led to the failure, and whether the
failure is the kind that's safe to retry. A bare `"Something went
wrong"` with no further context is treated as an incomplete
implementation, not an acceptable fallback.

**2.3 — Don't collapse distinct failure modes into one error type
unless callers genuinely treat them the same way.**
If a caller needs to react differently to "the resource doesn't exist"
versus "the resource exists but access is denied" versus "the
downstream service is unavailable," those need to be distinguishable in
the error representation — not merged into a single generic
`OperationFailedError` that forces every caller to parse a message
string to figure out which case actually occurred.

---

## 3. Exception Hierarchies (where the language uses exceptions)

**3.1 — A project-level base error type, with specific subtypes for
distinct failure categories.**
Rather than throwing the language's bare built-in exception/error type
everywhere, define a small hierarchy rooted in a project- or
domain-specific base type, with subtypes for the failure categories
that actually recur (validation failure, not-found, permission-denied,
upstream-unavailable, etc.). This lets calling code catch at whatever
level of specificity it actually needs, and lets a top-level handler
catch the base type as a safety net without needing to enumerate every
subtype.

**3.2 — Don't create a new exception subtype for every individual
function — model failure categories, not call sites.**
The hierarchy should reflect the *kinds* of things that can go wrong
across the system, not be expanded ad hoc per function as a substitute
for thinking about which existing category a new failure actually
belongs to.

---

## 4. Retry and Backoff

**4.1 — Only retry what's genuinely retryable.**
A transient failure (a network timeout, a momentary rate limit, a
deadlock detected by a database) is a candidate for retry. A failure
caused by invalid input, a programmer error, or a permanently denied
permission is not — retrying it wastes time and resources reproducing
the same failure, and can mask the real problem by making it look
intermittent.

**4.2 — Retries use backoff, and a defined ceiling.**
A retry loop without backoff (immediate, repeated retry) can turn a
brief downstream blip into a self-inflicted load spike. Use exponential
or otherwise increasing backoff between attempts, and a maximum number
of attempts (or maximum total elapsed time) after which the operation
gives up and surfaces the failure rather than retrying indefinitely.

**4.3 — Retries are idempotent-safe, or not attempted at all.**
Before retrying an operation that has side effects (a write, a payment,
a message send), confirm the operation is safe to attempt more than
once — either because it's naturally idempotent or because an
idempotency mechanism (a request ID, a deduplication key) is in place.
An operation with side effects that is retried without this guarantee
risks duplicating the very effect it was trying to ensure happened.

---

## 5. Error Response Shapes (cross-layer / API-facing)

**5.1 — One consistent error response shape per project, established
as a foundational decision.**
Every error surfaced across a layer boundary the project controls
(e.g. an API error response, an event payload's error field) follows
one consistent shape, decided once at the foundational tier and
referenced from `api-design.md` and the project's `DECISIONS.md` —
not re-decided inconsistently endpoint by endpoint.

**5.2 — The shape distinguishes machine-readable detail from
human-readable detail.**
A well-formed error response gives calling code something stable to
branch on programmatically (an error code or type, not a free-text
message that might be reworded later) separately from a human-readable
message intended for logs or end-user display. Code that branches on
the exact wording of an error message is a defect waiting to surface
the next time that wording is tidied up.

---

## 6. Applied Examples

*(No entries yet. This is one of the skill files most likely to need
early Applied Examples once a stack is declared, since exception-based
error handling, `Result`-style handling, and the idioms for each differ
substantially across languages. Populate per the format in
`skills/core.md` Section 8 as real cases come up — e.g. how a typed
backend's exception hierarchy maps to this file's Section 3 versus how
a `Result<T, E>`-based language expresses the same hierarchy as a sum
type instead.)*
