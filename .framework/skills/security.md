# Skill: Security

**Tier:** Mixed — establishing the auth/authz strategy or secrets-
management architecture for a project is foundational-tier; applying
already-established patterns to a new feature is feature-level. Load
this file for anything touching authentication, authorization, secrets,
or direct handling of untrusted input beyond the baseline already
stated in `core.md` Section 6, which this file extends rather than
repeats.

---

## 1. Relationship to `core.md`'s Baseline

`core.md` Section 6 states the non-negotiable floor: no secrets in
version control, all external input is untrusted until validated,
least privilege applies to every access decision, dependency
vulnerabilities are a security concern, and security-sensitive paths
require this file before being considered complete. Everything below
assumes that floor and goes further.

---

## 2. Authentication

**2.1 — The authentication mechanism is a foundational decision, made
once per project (or per clearly-scoped subsystem).**
Whether the project uses session cookies, bearer tokens, OAuth/OIDC, or
another mechanism is decided once, signed off via `architect.md` /
`decide`, and logged in `DECISIONS.md`. A second, different
authentication mechanism introduced later for convenience on a single
feature — without going through the same sign-off — is a foundational-
tier violation, not a pragmatic shortcut.

**2.2 — Credentials are never logged, even at debug level.**
Passwords, tokens, API keys, and session identifiers must never appear
in logs, including verbose/debug-level logs, error messages, or stack
traces. A logging statement that captures an entire request or
response object must explicitly redact known-sensitive fields rather
than relying on no one ever turning on verbose logging in production.

**2.3 — Failed authentication attempts don't reveal which part
failed.**
An error message distinguishing "no such user" from "wrong password"
gives an attacker a free username-enumeration oracle. Authentication
failures return a single, generic failure response regardless of
whether the username, the password, or both were wrong.

---

## 3. Authorization

**3.1 — Authorization is checked at the point of access, every time —
never cached as "already checked" from an earlier step in the same
request, and never inferred from the UI not exposing an action.**
A user being unable to *see* a button to perform an action in a client
is not an authorization control — the server-side check at the moment
the action is actually attempted is the only one that counts. Every
request that performs a privileged action re-verifies that the
requesting identity is actually permitted to perform it, regardless of
what earlier steps in the same flow already established.

**3.2 — Authorization logic lives in one place per resource type, not
duplicated across every endpoint that touches that resource.**
Permission checks for a given resource type should route through a
shared policy/check function rather than being reimplemented
ad hoc per endpoint — duplicated authorization logic is the most common
way a permission check gets forgotten on one new endpoint while being
correctly applied everywhere else.

**3.3 — Object-level authorization is checked, not just endpoint-level.**
An endpoint requiring "the caller must be logged in" is not the same as
"the caller is allowed to access *this specific* resource." Any
endpoint that takes a resource identifier must verify the caller is
authorized for that specific object, not just authorized to call the
endpoint in general — this is the single most common real-world
authorization gap (commonly called an "IDOR" — insecure direct object
reference) and must be explicitly checked, not assumed away.

---

## 4. Secrets Management

**4.1 — Secrets are sourced from a secrets manager or environment
configuration, never from a config file committed to the repo, even an
`.example` or `.local` file accidentally left populated with real
values.**
This extends `core.md` 6.1: the rule isn't just "don't commit secrets,"
it's "structure the project so committing one by accident is hard" —
e.g. `.gitignore` entries for any file pattern that's expected to hold
local secrets, and example/template config files that contain only
placeholder values, never real ones temporarily "for convenience."

**4.2 — Secrets are rotated on a defined cadence and immediately on
suspected exposure.**
A secret that may have been exposed (committed and later removed,
logged, sent in plaintext somewhere it shouldn't have been) is rotated
immediately — removing the exposed copy is not sufficient, since
anything that saw it before removal must be assumed compromised.

---

## 5. Untrusted Input, Beyond Basic Validation

**5.1 — Validation happens against an allow-list of what's acceptable,
not a deny-list of what's known-bad.**
Rejecting known-bad patterns (a deny-list) is inherently incomplete —
it only catches attack patterns someone already thought of. Defining
what *valid* input looks like and rejecting everything else (an
allow-list) is the default approach; deny-list filtering is a
supplementary defense, never the primary one.

**5.2 — Output is encoded for the context it's rendered into, every
time, not just where an injection attempt seems likely.**
Data that's user-controlled (even indirectly — a value a user entered
weeks ago, now being displayed to a different user) is encoded
appropriately for wherever it's being output (HTML-escaped for HTML
context, parameterized for SQL, escaped for shell commands if ever
passed there at all). This is applied uniformly, not selectively based
on a guess about whether a particular field is "likely" to contain
something dangerous.

**5.3 — Information disclosure is a security concern, not just a
correctness one.**
An error message, a stack trace, or a verbose API response that
reveals internal implementation detail (a file path, a database error
string, a library version) to an external caller is a security issue —
it gives an attacker reconnaissance information for free. Production-
facing error responses are deliberately generic; full detail is
reserved for internal logs.

---

## 6. Applied Examples

*(No entries yet. Security mechanics vary by stack — e.g. how CSRF
protection is conventionally implemented in a server-rendered framework
versus a token-based SPA/API split, or how a typed language's
type-level guarantees reduce (but don't eliminate) certain classes of
input-validation risk. Populate per the format in `skills/core.md`
Section 8 once a real project's stack and security requirements are
known. Note: this skill file should also be the first to get a
proper security review/audit pass from a qualified human before being
relied on for any project handling regulated or highly sensitive data —
this framework provides engineering-discipline baseline, not a
substitute for a dedicated security review.)*
