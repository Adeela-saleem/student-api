# Skill: API Design

**Tier:** Mixed — establishing or changing an API's foundational
contract conventions (versioning strategy, error shape, auth pattern
for the API surface) is foundational-tier; designing an individual
endpoint within those established conventions is feature-level. Load
this file whenever work involves designing, exposing, or modifying any
API contract — REST, RPC, GraphQL, or an internal service interface
between modules.

This file does not cover error-handling mechanics in general
(`error-handling.md`, though Section 4 below intersects with it
directly) or auth/authz implementation specifics (`security.md`).

---

## 1. A Contract Is a Promise, Not an Implementation Detail

**1.1 — Design the contract before the implementation, not after.**
The shape of requests and responses, the resource model, and the error
behavior should be decided based on what's useful and stable for
callers — not derived backward from whatever shape happens to fall out
of the current internal data model. An API that's a thin pass-through
of internal representation couples every internal refactor to a
breaking external change.

**1.2 — Once published, a contract is a promise to existing callers.**
Any change that alters a field's meaning, removes a field, changes a
status code's semantics, or otherwise breaks an existing caller's
reasonable assumptions is a breaking change — regardless of whether the
change "seems small." Breaking changes require the versioning approach
in Section 2, not a silent in-place modification.

---

## 2. Versioning

**2.1 — The versioning strategy is a foundational decision, made once.**
Whether the project versions via URL path, a header, content
negotiation, or another mechanism is decided once at the foundational
tier, logged in `DECISIONS.md`, and applied consistently — not chosen
per-endpoint based on whichever approach is most convenient at the
time.

**2.2 — Additive changes don't require a new version; breaking changes
always do.**
Adding a new optional field, a new endpoint, or a new optional query
parameter is additive and backward-compatible — it doesn't require a
version bump. Removing a field, changing a field's type or meaning, or
changing required-ness of an existing field is breaking and requires
either a new version or a deliberately managed deprecation path (see
2.3) under the established strategy.

**2.3 — Deprecation has a stated timeline, communicated in advance.**
A deprecated version or field is marked as such (in documentation and,
where the transport allows it, in the response itself — e.g. a
deprecation header) with a stated removal timeline, before removal —
never removed without notice on the assumption that "no one's probably
using it."

---

## 3. Request and Response Conventions

**3.1 — Resource and field naming follows `core.md` Section 2, applied
consistently across the whole API surface.**
Inconsistent naming across endpoints (one endpoint returning
`created_at`, another `createdAt`, for conceptually the same field) is
a defect at the API-design level even if each individual endpoint's
naming would pass review in isolation — the API surface is judged as a
whole, not endpoint by endpoint.

**3.2 — Pagination, filtering, and sorting follow one established
pattern, not one improvised per endpoint.**
If more than one endpoint returns a collection, the pagination
mechanism (cursor-based, offset-based, or otherwise), the filtering
syntax, and the sorting syntax are decided once and reused — introducing
a second, different pagination style elsewhere in the same API is a
foundational-tier inconsistency to flag, not a local implementation
choice.

**3.3 — Partial success is represented explicitly, never implied.**
An operation that can partially succeed (e.g. a batch endpoint where
some items succeed and others fail) must represent that outcome
explicitly in the response shape — never collapse it into a single
success/failure status that forces the caller to guess which items
actually went through.

---

## 4. Error Behavior at the API Boundary

**4.1 — The error response shape is the one established by
`error-handling.md` Section 5, with no per-endpoint deviation.**
Every error this API surfaces uses the project's single established
error response shape. An endpoint that returns errors in a different
shape "because this case is special" reintroduces exactly the
inconsistency that establishing one shape was meant to prevent.

**4.2 — Status codes (or equivalent transport-level signals) are used
for their documented meaning, not repurposed for convenience.**
A 404 means the resource doesn't exist — not "the resource exists but
you're not allowed to see it" (that's 403, or 404 deliberately, as a
considered security choice — see `security.md` on information
disclosure — but not as an accident of convenience). Status codes are
chosen for what they accurately communicate, not for whatever is
easiest to return from the current code path.

---

## 5. Idempotency and Safety

**5.1 — Read operations have no side effects, without exception.**
An operation exposed as a read (a GET, a query) must not mutate state
as a side effect, even subtly (e.g. a "GET" that also updates a
last-accessed timestamp in a way that has externally visible
consequences needs to be evaluated carefully against this rule, not
waved through because the mutation seems minor).

**5.2 — Operations with side effects that callers might reasonably
retry support idempotency.**
Any write operation a caller might retry after an ambiguous failure
(e.g. a timeout where the caller can't tell if the original request
succeeded) should support an idempotency mechanism — typically a
client-supplied idempotency key — so a retry doesn't duplicate the
effect. This is the API-design counterpart to `error-handling.md`
Section 4.3.

---

## 6. Applied Examples

*(No entries yet. API design idioms vary by transport and stack —
REST, GraphQL, gRPC, and internal RPC each express the principles above
differently, e.g. how versioning and pagination are conventionally
expressed in GraphQL versus a path-versioned REST API. Populate per the
format in `skills/core.md` Section 8 once a real project's declared
stack and API style are known.)*
