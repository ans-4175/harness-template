# PRD Template

This template matches the PRD readiness checklist in `.agents/skills/discovery-slice/references/prd-checklist.md`. A PRD written with it can be evaluated directly in Step 0 of the `discovery-slice` skill.

---

```markdown
# PRD: [Project Name]

> [One sentence: what is being built and for whom.]
> Last updated: [date]

---

## 1. Business Context

[Explain WHY this product is being built, not what the product is.
What business problem drives it? What happens if it is not built?]

**Concrete business goals:**
- [example: cut the processing time of X from Y hours to Z hours]
- [example: raise onboarding conversion from A% to B%]

**Constraints:**
- Timeline: [deadline or key milestone]
- Budget: [if relevant]
- Regulation / compliance: [if any]
- Existing integrations: [systems that must be connected]

---

## 2. User Segments

[At least two distinct segments, not a single "end user" label.
Each segment must have different needs or behaviour.]

### [Segment A]
- **Who:** [short description of role or profile]
- **Usage context:** when, where, and under what conditions they use the product
- **What matters most to them:** [one sentence]

### [Segment B]
- **Who:** [short description]
- **Usage context:** [when, where]
- **What matters most to them:** [one sentence]

---

## 3. Pain Points & JTBD

[Write from the user's point of view, not the product's.
Every pain point must be traceable to an observation or interview, not an assumption.]

### Pain Points

- **[Segment A]:** [the problem they have today - specific, not generic]
- **[Segment B]:** [the problem they have today]

### Jobs-to-be-Done

[Job story format: "When [situation], I want to [motivation], so I can [outcome]"]

**Job 1: [short name]**
> When [concrete situation], I want to [what they want to do], so I can [desired outcome - a real change in the user's behaviour or condition, not just "more efficient"].

**Job 2: [short name]**
> When [concrete situation], I want to [what they want to do], so I can [desired outcome].

[add as needed]

---

## 4. Capabilities & Requirements

[Write from the user's point of view: what the user CAN DO in the product.
Not a technical spec. Not "implement endpoint X".]

### Functional Capabilities (Must-Have)
- The user can [action] so that [result]
- The user can [action] so that [result]

### Functional Capabilities (Nice-to-Have)
- The user can [action] so that [result]

### Non-Functional Requirements
[Only if relevant: performance, security, scale, accessibility]
- [example: the main page loads in under 2 seconds]
- [example: data is encrypted at rest]

---

## 5. Flows & Behaviours

[At least one main flow. Numbered steps, prose, or a reference to a diagram.
Not a wireframe spec: the flow and the context behind each step are enough.]

### Flow 1: [Flow name]

**Entry point:** [where the user starts]
**Exit point:** [where the user ends up / what succeeded]

1. The user [does X]
2. The system [responds with Y]
3. The user [chooses Z]
4. [and so on]

**Important edge cases:**
- If [condition A]: [what happens]
- If [condition B - error / empty state]: [what happens]

### Flow 2: [Flow name]
[add as needed]

---

## Additional

[Optional. Include only information outside the 5 standard sections that matters for slicing or building.
Examples: competitive context, design decisions already made, technical integrations engineers should know, stakeholder notes.]

### [Sub-section title]
[content]
```

---

## Writing guide

**Business Context.** Do not write "build platform X to improve efficiency". Write *why* and *for whom*, and what concretely changes if the product succeeds.

**User Segments.** Do not lump all users together. If two people with different needs will use the product, that is two segments.

**Pain Points & JTBD.** Do not write "users want a notification feature". Write "users often miss important updates because nothing tells them actively". A feature is a solution; a JTBD is the problem.

**Capabilities.** Do not write "implement GET /api/deals". Write "The user can see all active deals in one view".

**Flows.** Do not attach a wireframe with no explanation. Write the context: *why* the user takes the step, not only *what* they press.

**Additional.** Use it for information that fits none of the 5 sections but matters to the team slicing or building. Do not duplicate content from the other sections.
