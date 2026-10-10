# Discovery materials

Drop discovery materials here before running the `brief-to-prd` skill: briefs, meeting notes,
research, deck exports, and Figma flow descriptions. The agent reads this folder recursively,
subfolders included. Source files are never edited.

| Format | Use |
|--------|-----|
| `.md`, `.txt` | Notes, briefs, anything exported as text |
| `.pdf` | Exports from documents or slides |
| `.png`, `.jpg` | Screenshots of whiteboards, slides, or designs |

**Figma:** write the flows as numbered text in a `.md` file (a link alone is not enough; the
text is what the PRD is drafted from).

`synthesis.md` is created by the agent after the first ingest. Do not edit it by hand, except to
add context that exists in no other file.

The PRD (`docs/plans/prd.md`) and the Phase Map (`docs/plans/phase-map.md`) are created by the
skills when first needed. This folder can stay empty until a project has discovery work.
