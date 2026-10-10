# PRD Readiness Checklist

Use this to decide whether a PRD is ready to be sliced. A PRD is ready when an agent can extract clear JTBDs, understand who the users are, and know what "done" looks like for the first phase, without guessing.

## Checklist per section

### Business Context
- [ ] Explains *why* the product is being built, not just what it is
- [ ] Has a concrete business goal (for example, reduce process X time, raise Y conversion)
- [ ] Constraints mentioned: timeline, budget, regulation, existing integrations

### User Segments
- [ ] Segments are differentiated, not a single "end user" label
- [ ] Each segment has distinct needs or behaviours
- [ ] Usage context described: when, where, and under what conditions

### Pain Points & JTBD
- [ ] Problems are written from the user's perspective, not the product's
- [ ] Each pain point is traceable to research or observation, not assumed
- [ ] JTBDs are framed as user goals, not feature requests
- [ ] At least one job story in this format: *"When [situation], I want to [motivation], so I can [outcome]"*
- [ ] The `so I can [outcome]` is specific and observable: a real behavioural change, not a vague improvement like "be more efficient"

### Capabilities & Requirements
- [ ] Functional capabilities are listed as what users *can do*, not implementation details
- [ ] Non-functional requirements mentioned if relevant (performance, security, scale)
- [ ] Priority indicated: must-have vs nice-to-have

### Flows & Behaviours
- [ ] At least one flow described: screen flow, user flow, or step-by-step narrative
- [ ] Entry point and exit point of each flow are clear
- [ ] Key edge cases mentioned: error states, empty states, boundary conditions

---

## Scoring guide

**Ready to slice**: all sections present, no critical gaps. Go to Step 1.

**Slice with caution**: 1-2 sections are thin but enough to start. Show the gaps to the human, get explicit acknowledgment, then continue. Flag the gaps as assumptions in the Phase Map.

**Needs rewrite first**: Business Context, User Segments, or Pain Points/JTBD are missing or too vague. Slicing now means building on assumptions that are expensive to fix mid-sprint. Stop and request a PRD revision.

---

## Common rewrite signals

| What is in the PRD | What is missing | Why it matters |
|---|---|---|
| "Build a platform to improve efficiency" | Why, for whom, what efficiency | The primary JTBD cannot be determined |
| Only one user segment ("admin") | Distinct user types and needs | Slices will be too broad |
| A feature list without pain points | Why users need these features | Risk of building the wrong thing |
| "User wants a notification feature" | What problem triggers the need | Slice thickness cannot be determined |
| Wireframes without a flow explanation | The context behind each step | Acceptance criteria will be ambiguous |
