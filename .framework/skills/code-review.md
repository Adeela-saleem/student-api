# Skill: Code Review

**Tier:** Feature-level process guidance, building on the checklist
already defined in `core.md` Section 7. This file governs the *process*
of reviewing — how a review is conducted and how feedback is given and
received — not the checklist *content* itself, which lives in `core.md`
so that every contributor can self-check against it without needing
this file loaded. This is the primary skill file behind the
`reviewer.md` persona and the `review` command.

---

## 1. Relationship to `core.md`'s Checklist

`core.md` Section 7 is the *what* — the concrete list every PR is
checked against. This file is the *how* — the manner in which that
checklist is applied, and how the reviewer and author interact around
it. Loading this file without `core.md`'s checklist in context produces
a review with the right tone and no actual content to check against;
load both together.

---

## 2. What a Review Is For

**2.1 — A review verifies correctness and consistency with established
conventions — it is not a venue for re-litigating already-settled
foundational decisions.**
If a PR follows an established convention the reviewer personally
disagrees with, the review is not the place to block the PR over that
disagreement — the convention was settled at the foundational tier (or
should be raised there, separately, via `decide`, as its own
discussion) and a feature-level PR correctly following it should not be
held hostage to a disagreement about the convention itself.

**2.2 — A review's job is to catch what the checklist defines as a
defect — not to impose the reviewer's personal stylistic preference
where the checklist is silent.**
Where `core.md` Section 2 (naming) and the stack's declared idiom in
`technology-handling.md` don't dictate an answer, a reviewer's
preference for one valid approach over another equally valid one is a
suggestion, not a blocking comment. Reviews that block on preference
rather than defect slow delivery without improving consistency, since
the inconsistency they're "fixing" was never actually a violation of
any stated rule.

---

## 3. How Feedback Is Given

**3.1 — Feedback distinguishes "this must change" from "consider
this."**
A reviewer marks comments clearly by severity — a checklist violation
or a genuine defect is blocking; a stylistic suggestion or an
alternative worth considering is explicitly non-blocking. An author
should never have to guess which category a given comment falls into.

**3.2 — Feedback addresses the code, not the author.**
Review comments describe what's wrong with the code and why, framed
around the change itself ("this swallows the error silently — see
`core.md` 5.1" rather than "you always forget error handling").
Specificity and a cited rule, where one exists, make feedback
actionable; characterizing the author's habits does not.

**3.3 — A blocking comment cites the specific rule or checklist item
it's enforcing.**
Per Section 2.2, a blocking comment should be traceable to something
concrete — a `core.md` checklist item, a stack convention in
`technology-handling.md`, a stated contract in the relevant skill file
— not left as an unexplained "this needs to change." If a reviewer
can't point to what's being violated, that's a signal the comment
should be reframed as a non-blocking suggestion or raised separately as
a possible gap in the framework itself.

---

## 4. How Feedback Is Received

**4.1 — A blocking comment citing an actual rule is addressed, not
argued away in the same PR.**
If a comment correctly identifies a checklist violation, the response
is to fix it. Disagreement with the *rule itself* (not its application
here) is a separate, foundational-tier conversation about the rule,
raised through `decide` — not grounds for merging the PR unchanged
while the disagreement is unresolved.

**4.2 — A non-blocking suggestion can be accepted, discussed, or
declined — and declining one is not itself a violation.**
Since Section 2.2 establishes that preference-level suggestions are
non-blocking, an author declining one (with or without a stated reason)
is a normal, acceptable outcome — review is not "won" by getting every
suggestion accepted.

---

## 5. Review Turnaround and Scope Discipline

**5.1 — Review scope matches PR scope, per `core.md` 3.4.**
A reviewer encountering a PR that's grown too large or mixed multiple
unrelated concerns should flag that directly rather than attempting a
thorough review of an unreasonably large diff — the fix is to split the
PR, not to review it less carefully to compensate for its size.

**5.2 — "Scope creep" requests in review (asking the author to fix
unrelated pre-existing issues they happened to walk past) are flagged
as separate follow-up items, not folded into the current PR.**
A reviewer noticing an unrelated existing problem in a file the PR
touches should raise it as a separate, explicitly-scoped follow-up —
not block the current, otherwise-correct PR on fixing something it
didn't introduce.

---

## 6. Applied Examples

*(No entries yet — code review process is largely stack-independent by
design, since it concerns conduct and checklist enforcement rather than
language mechanics. Entries here, if any arise, are more likely to
concern tooling conventions, e.g. how a specific platform's review-tool
features map onto Section 3's severity distinction. Populate per the
format in `skills/core.md` Section 8 if and when something genuinely
stack- or tool-specific comes up.)*
