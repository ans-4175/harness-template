---
name: brief-to-prd
description: "Turn discovery materials (briefs, meeting notes, research, decks, Figma flow descriptions) into a structured PRD ready for slicing. Use when there are discovery files to ingest, a PRD needs drafting, or research notes need synthesizing. Triggers: 'new brief', 'draft a PRD', 'write the PRD', 'process discovery', 'synthesize these notes', 'ingest discovery', 'we have meeting notes'."
---

# Brief to PRD

Discovery materials go into `docs/discovery/`. Read everything first, then ask only for what is missing.

Supported formats: `.md`, `.txt`, `.pdf`, images (PNG/JPG). Decks: export to PDF or copy the key text into `.md`. Figma: a `.md` file with the URL plus the flows written out as text.

If a file is a format you cannot read directly (Word, PowerPoint, Excel), ask the user to export it to PDF or `.md`, or to paste the relevant text.

---

## Step 0 - Inventory and intent

List every file under `docs/discovery/`, subfolders included. Exclude `README.md` and `synthesis.md`.

```bash
find docs/discovery -type f | sort
```

Group what you find:

- **Brief**: client brief, project scope document
- **Meeting notes**: co-creation and stakeholder sessions
- **Research**: user interviews, surveys, observations
- **Deck / slides**: presentation exports
- **Figma**: link files with flow descriptions
- **Other**

Report what is present per group and which group looks missing. Then ask: "Is there anything not dropped in yet, or context that is easier to give verbally?"

If `docs/discovery/synthesis.md` exists, read it first. A previous session already ran, so process only new or changed files.

**Intent.** Read the user's opening message to decide the scope:

- **Synthesis only** ("process the notes", "synthesize", "summarize the materials"): run Steps 1-2, then stop and ask.
- **Full flow** ("draft a PRD", "write the PRD", "we have a new brief"): run Steps 1-4.
- **Ambiguous**: default to the full flow, but after Step 2 show the synthesis and confirm before Step 3.

If the user named things to capture (for example "also capture the competitive landscape"), treat them as custom capture targets for Step 2.

## Step 1 - Ingest and extract

Read each file one by one, following the full paths from `find`. Extract only what is relevant to these sections:

- **Business context**: why it is built, goals, constraints, success metrics
- **User segments**: who uses it, distinct needs per segment, usage context
- **Pain points**: problems from the user's perspective, traceable to an observation. Also look for success signals, where users describe what a better outcome looks like. These become the `so I can [outcome]` in job stories.
- **Solution direction**: what the client envisions or what the research points toward
- **Flows and behaviours**: how users move through the product, edge cases mentioned. Extract only flows written as text (numbered steps or prose). A Figma link or image with no text narration is a **gap**: note it, do not infer a flow from visuals alone.
- **Custom capture targets**: anything the user asked for, and notable patterns that fit nowhere else

Stay close to the source. Do not editorialize or infer beyond the file.

## Step 2 - Synthesize

Write (or update) `docs/discovery/synthesis.md`.

**Required sections** (always present):

```markdown
# Discovery Synthesis

> Last updated: [date]
> Sources: [file names]

## Business Context
[synthesized content]

## User Segments
[synthesized content]

## Pain Points & JTBD Candidates
[synthesized content. Use job story format where possible:
"When [situation], I want to [motivation], so I can [outcome - a real behavioral change, not a vague improvement]"]

## Solution Direction
[what the client or research points toward - direction, not a spec]

## Constraints
[timeline, budget, tech, regulatory, integration]

## Flows & Behaviours
[journeys, flows, and edge cases mentioned in the materials]

## Open Questions / Gaps
[what is missing or unclear - addressed in Step 3]
```

**Flexible sections**, added after the required ones when relevant:

- Each custom capture target the user asked for becomes a named section.
- Notable patterns that fit no required section (competitive context, team dynamics, prior failed attempts) go under `## Other Findings`, with a sub-heading per topic.

If a synthesis already exists, update only the sections that have new information and add the new sources to the list.

**After writing the synthesis, always ask before continuing**, whatever the intent:

> "Synthesis is done. Continue to the gap check to prepare the PRD draft?"

Wait for an explicit yes before Step 3.

## Step 3 - Gap check

Compare the synthesis against the PRD checklist in `.agents/skills/discovery-slice/references/prd-checklist.md`. Find which of the five sections are missing or too thin to pass the readiness check.

Order by criticality: the most ambiguous or blocking gaps first. Ask **at most 5** numbered questions, most critical first:

```
A few things need answers before the PRD draft. Most critical first:

1. ⚠️ Pain points: the ones in the synthesis still read like assumptions. Did any come directly from a user in an interview?
2. Business context: what is the concrete success metric? (for example, processing time down X%, conversion up Y%)
3. User segments: besides [segment A], is there another segment with different needs?
```

Wait for the answers, then ask:

> "The gaps are filled. Ready to start the PRD draft?"

Wait for an explicit yes before Step 4.

## Step 4 - Draft the PRD

From `docs/discovery/synthesis.md` plus the answers from Step 3, draft `docs/plans/prd.md` (create the folder if missing). Use `references/prd-template.md`. Write section by section, and after each section show it and ask for confirmation before the next.

The structure is fixed: 5 standard sections plus 1 optional Additional section. Extra context stays in the synthesis; the PRD is the clean document used for slicing.

Style:

- A short narrative per section, not a wall of bullets
- JTBD as job stories: *"When [situation], I want to [motivation], so I can [outcome]"*
- Capabilities from the user's point of view, not a technical spec
- Flows as numbered steps or prose, not a wireframe spec

When every section is confirmed, the PRD is ready for the `discovery-slice` skill.

---

## Human collaboration points

- **Step 0**: after the inventory, confirm all files are present or get verbal context
- **Step 2**: after the synthesis, explicit confirmation before the gap check
- **Step 3**: answer the targeted questions (max 5), then explicit confirmation before the draft
- **Step 4**: confirm each PRD section before the next
