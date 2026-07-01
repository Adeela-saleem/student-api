# Skill: Language-Agnostic Behavior

**Tier:** Foundational, universal — loaded in every session alongside
`core.md`, with no exceptions. This file states one rule explicitly,
because it is critical enough to the framework's purpose that it must
never be left implicit or assumed obvious: the language, tone, or
register a developer prompts in never changes the structure of the
output produced.

---

## 1. The Rule, Stated Directly

A developer may communicate with the agent in English, Roman Urdu, a
natural mix of the two, formally, casually, in shorthand, or in any
other language or register. The agent's job is to **parse intent**
from whatever arrives — and nothing about that input's language,
formality, grammar, or phrasing should change what the agent then
**produces**. Code structure, naming conventions, documentation style,
commit message format, architectural patterns, and every other
convention defined elsewhere in this framework apply identically
regardless of how the request was phrased or in what language it
arrived.

**Concretely:** a request phrased as "bhai is function ko thoda clean
kar do, error handling missing hai" and a request phrased as "Please
refactor this function to add proper error handling" must produce the
*same kind of output* — same naming conventions, same error-handling
pattern per `core.md` Section 5 and `error-handling.md`, same
documentation standard. The informality or language mix of the first
request is not a signal to relax any convention, nor is the formality
of the second a signal to apply extra rigor beyond what the framework
already specifies. The input's register carries no information about
which rules apply.

---

## 1a. Conversational Language Matching

The rule above governs *produced artifacts* (code, docs, commit
messages, architecture decisions). For *conversational back-and-forth*
— the discussion around the work, clarifying questions, progress
updates — the agent should mirror the user's natural language mix.

**The mirroring rule:**

- If the user writes mostly English with occasional Roman Urdu/Hindi-Urdu
  words, match that: respond mostly in English with natural Urdu vocabulary
  where it fits — do not force pure Roman Urdu.
- If the user writes heavier Roman Urdu or a Hinglish blend, match that
  register in conversational replies.
- If the user writes entirely in English, respond in English.

**The one hard constraint regardless of mix:** all conversational output
must stay in **Latin script only**. Never switch to Devanagari or
Perso-Arabic script, even when vocabulary includes Hindi/Urdu-origin words.
"Theek hai" is fine; switching to "ٹھیک ہے" or "ठीक है" is not, regardless
of how the user phrased their message.

**Why this is its own section and not a collapse of the main rule:**
the main rule (Section 1) is a constraint on produced artifacts — it
prevents informal phrasing from relaxing code conventions. The mirroring
rule (this section) is a positive instruction for conversational register —
it ensures the agent doesn't respond in stiff English to a user who's
writing naturally in a mixed code-switch style. The two rules operate on
different output types and do not conflict.

---

## 2. Why This Is Its Own File, Not a Note Inside `core.md`

This rule is foundational enough to warrant standing on its own rather
than being buried as a sub-point elsewhere, for a specific reason: it's
the rule most likely to be silently and unintentionally violated,
because an agent (or a human reviewer) can plausibly rationalize
relaxed output as "matching the user's casual tone" without recognizing
that as a violation in the moment. Giving it a dedicated file — and a
dedicated reference from `AGENT.md` Section 2 — makes it harder to
overlook than a clause inside a longer document would.

---

## 3. What This Rule Does and Does Not Cover

**3.1 — This governs output structure and convention, not the agent's
conversational register.**
The agent may, and should, respond *conversationally* in a register
that's natural given how it was addressed — replying in a mix of
English and Roman Urdu if that's how the conversation has been
proceeding is fine and often more natural. What this rule constrains is
specifically the *produced artifact* — code, file structure, commit
messages, documentation, architectural decisions — not the
back-and-forth conversation around producing it.

**3.2 — Parsing intent sometimes requires asking for clarification —
that's not a violation of this rule.**
If casual or shorthand phrasing leaves genuine ambiguity about what's
being asked (not about *how* to phrase the output, but about *what*
the actual request is), asking a clarifying question is correct
behavior, consistent with the framework's standing anti-hallucination
rule. This rule doesn't mean "never ask for clarification because the
phrasing was casual" — it means "once intent is clear, output the same
way regardless of how that intent was expressed."

**3.3 — This rule does not flatten genuine technical vocabulary
differences into "tone."**
If a request uses a stack- or domain-specific term incorrectly or
ambiguously (not a register difference, but an actual technical
ambiguity — e.g. unclear whether "the API" refers to an internal
service or an external one), that's a substantive clarification need
under Section 3.2, not something this rule papers over by assuming a
particular interpretation just to avoid asking.

---

## 4. Relationship to Other Skill Files

This file states the *principle*. It does not restate the conventions
themselves — those live in their respective files (`core.md` for
naming/git/docs/error-handling/security baseline, and the rest of
`skills/` for their specific domains). This file's only job is to
guarantee that whichever conventions apply, they apply uniformly,
regardless of the input's language or tone.

---

## 5. Applied Examples

*(No entries yet. Examples here would most usefully show real
before/after pairs — a casual, mixed-language prompt and a formal
English prompt requesting the same underlying change, with the
identical resulting code shown for both — once this framework is in
active use on a real project. Populate per the format in
`skills/core.md` Section 8.)*
