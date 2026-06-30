# Skill: Architecture

**Tier:** Foundational-tier concern. This file governs structural,
design-time decisions — the decisions other decisions get built on top
of. It is loaded whenever work touches module boundaries, system
structure, or any decision the tiering system in `AGENT.md` Section 4.3
would classify as foundational. It is the primary skill file behind the
`architect.md` persona and the `decide` command.

This file does not cover: API contract specifics (`api-design.md`),
error-handling mechanics (`error-handling.md`), or performance
trade-offs in isolation (`performance.md`) — though all three frequently
intersect with architectural decisions and should be consulted alongside
this file rather than instead of it.

---

## 1. What Counts as Architectural (and Therefore Foundational-Tier)

A decision is architectural — and therefore foundational-tier, requiring
sign-off per `AGENT.md` Section 4.3 — if it has any of these properties:

- **It's expensive to reverse.** Changing it later requires touching
  many files across module boundaries, not a localized edit.
- **Other decisions will be built on top of it.** A module boundary, a
  data model convention, or an auth strategy becomes load-bearing the
  moment a second feature depends on it existing a particular way.
- **It constrains future choices in ways that aren't obvious from the
  decision itself.** Picking a synchronous request/response pattern
  today quietly forecloses an event-driven approach later without that
  trade-off being stated anywhere.
- **Getting it wrong is silent until it isn't.** Inconsistent module
  boundaries or a missing convention for cross-layer error shape don't
  fail loudly when first introduced — they fail later, as accumulated
  inconsistency, which is exactly why this framework treats them as
  requiring sign-off rather than ad hoc judgment.

A decision is feature-level — and does **not** require sign-off — when
it's localized, reversible without touching code outside the feature
being built, and doesn't establish a pattern other work is expected to
follow.

**When genuinely unsure which side a decision falls on:** treat it as
foundational and ask, rather than defaulting to feature-level to avoid
the overhead of escalation. See `AGENT.md` Section 4.3 for the
reasoning behind this default.

---

## 2. Module Boundaries

**2.1 — A module's boundary is defined by what it owns, not by file
location.**
Grouping code into a folder doesn't make it a module with a real
boundary; a module exists where there's a clear, single owner of a piece
of domain logic or data, and everything outside that module talks to it
only through an explicit interface — never by reaching into its internal
state or implementation directly.

**2.2 — Dependencies between modules flow in one direction, declared
explicitly.**
Circular dependencies between modules (A depends on B which depends on
A) are a structural defect, not a style preference, because they make
it impossible to reason about or test either module in isolation. If two
modules appear to need each other, the actual shared concept usually
belongs in a third module both depend on, or the boundary itself was
drawn in the wrong place.

**2.3 — A new module boundary is itself a foundational decision.**
Introducing a new top-level module, service, or clearly separated layer
is foundational-tier — it changes where future code is expected to live,
which is exactly the kind of decision other people's future choices get
built on. Reorganizing *within* an existing module's already-established
boundary, without changing what crosses that boundary, is feature-level.

---

## 3. Data Model Conventions

**3.1 — A shared data shape crossing a module or service boundary is
foundational.**
The shape of data passed between layers (e.g. the fields and types in a
domain entity, the shape of an event payload, the contract of a shared
record) is foundational the moment more than one module or service
consumes it, because every consumer is now implicitly depending on that
shape staying consistent.

**3.2 — Don't duplicate the same concept with different shapes.**
If the same underlying concept (a "user," an "order," a "transaction")
ends up represented with different field names or structures in
different parts of the system without a deliberate, documented reason,
that's drift, not legitimate variation — and it's exactly the kind of
inconsistency the sign-off gate exists to catch before it spreads
further.

**3.3 — Nullability and optionality are part of the model, not an
afterthought.**
Whether a field can be absent, and what absence means (genuinely
unknown, intentionally empty, not-yet-set) is a modeling decision with
the same weight as the field's type, and should be made deliberately —
not left to whatever the underlying database or serialization format
happens to default to.

---

## 4. Foundational Sign-Off Process

**4.1 — How a foundational decision gets made.**
A foundational-tier decision is routed through the `architect` persona
via the `decide` command (see `commands/decide.md` and
`agents/architect.md` for the procedural detail). At minimum, the
process must produce: the decision itself, the alternatives that were
genuinely considered, the rationale for the choice made, and an entry in
`DECISIONS.md` tagged `foundational` before the decision is acted on in
code.

**4.2 — Sign-off precedes implementation, not the reverse.**
Building the implementation first and writing up the decision
afterward as documentation defeats the purpose of the gate — the value
of sign-off is in surfacing disagreement or overlooked alternatives
*before* code is built on top of the decision, not in producing a
record after the fact. If implementation has already begun before the
foundational nature of a decision becomes apparent, pause and run the
sign-off process before continuing, rather than finishing first.

**4.3 — A foundational decision, once made, is binding until
deliberately revisited.**
A signed-off foundational decision is not silently re-decided by a
later contributor or session who happens to disagree or simply didn't
know it existed. Revisiting one requires going through the same
sign-off process again, explicitly citing the prior decision and stating
why it's being reconsidered — never a quiet divergence introduced
without acknowledgment.

---

## 5. Applied Examples

*(No entries yet. Architectural patterns vary significantly by stack —
e.g. how module boundaries are expressed in a monolith versus a
microservice topology, or how a typed language enforces a data model
contract that a dynamic one can only document. Entries should be added
per the format in `skills/core.md` Section 8 once this framework has
been applied to a real project with foundational decisions actually
made and logged.)*
