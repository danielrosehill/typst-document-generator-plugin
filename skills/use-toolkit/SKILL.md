---
name: use-toolkit
description: Recommend and wire in a Typst ecosystem library for jobs this plugin's core document templates don't cover — slides (polylux, touying), vector diagrams (fletcher), scientific plots (lilaq), formal templates from the official gallery (typst/templates), or programmatic rendering from Python (typst-py). Use when the user asks for slides, a specific diagram style, charts inside a Typst doc, a non-document format (letter, CV, invoice), or wants to render Typst from a script.
---

# Typst Toolkit Picker

Reference material lives in `shared/ecosystem.md` — read it before recommending.

## When to use

Trigger when the user's need goes beyond this plugin's six document
templates:

- "I want to make slides in Typst"
- "commutative diagram", "state machine diagram", "flowchart" (in-document)
- "scatter plot", "bar chart", "histogram" (in-document)
- "formal letter template", "invoice template", "academic paper template"
- "render Typst from Python", "generate docs in a script", "batch PDF"

## Procedure

### 1. Classify the need

Map the request to one category:

| Signal | Library |
|---|---|
| slides, deck, presentation | **polylux** or **touying** — ask which, default touying |
| diagram with nodes/arrows/structure | **fletcher** |
| chart, plot, graph, figure | **lilaq** |
| letter, CV, invoice, academic paper, any non-doc form factor | **typst/templates** |
| script, pipeline, batch, Python, automation | **typst-py** |
| illustrated/organic diagram | **nano-tech-diagrams MCP** (outside Typst) — redirect |

If ambiguous (e.g. "a diagram" — fletcher or nano-tech?), ask: "structural
and exact (fletcher, renders in the PDF) or illustrative and organic
(nano-tech-diagrams, rendered to image)?"

### 2. Confirm version

The versions cited in `shared/ecosystem.md` may be stale. Before writing the
import line, verify the current version:

```bash
# Fastest check — query Typst Universe
curl -s https://typst.app/universe/package/<name> | grep -oP 'data-version="[^"]+"' | head -1
```

Or ask the user to look it up. If the user doesn't care, use the version in
`shared/ecosystem.md` as-is (newer versions usually don't break imports).

### 3. Wire it in

**For an existing Typst document** the user is already working on:

- Add the `#import` line near the top (after `#import "./styles.typ"`).
- Add a minimal usage block where the user wants it.
- Don't modify the rest of the document.

**For a brand-new document** (especially slides):

- Slides are **not** a good fit for this plugin's `doc-base` (different page
  geometry, different header/footer needs). Generate a standalone `.typ`
  file that uses polylux or touying's own shows, not `doc-base.with(...)`.
- For anything else (diagrams, charts, templates), they compose fine inside
  a `doc-base` document.

### 4. Minimal examples to emit

Copy verbatim from `shared/ecosystem.md` and substitute values the user
gave. Examples there are all tested-shape minimal starters.

### 5. Install step (typst-py only)

For typst-py, the user needs `pip install typst` — mention this once,
then proceed. All `@preview/...` packages resolve automatically on first
compile; no install step needed.

### 6. Compile and verify

Run `typst compile <path>.typ`. On error, surface verbatim and stop — the
first package fetch can take a few seconds on a cold machine, but errors
beyond that are usually genuine.

## Special handling

### Slides — polylux vs touying

Default recommend **touying** (more active, themed, supports reveals) unless
the user is already familiar with polylux or wants something dead simple.

Ask: "Any preference? Touying is the modern default; polylux is simpler and
more stable."

### typst/templates — reference, not import

The official template gallery is a **reference**, not a direct import
target. Workflow:

1. Browse <https://github.com/typst/templates> or
   <https://typst.app/universe/> filtered by category.
2. Pick a template the user likes.
3. Either:
   - Start a new doc from it (copy the `.typ` files directly), or
   - Capture it as a new template YAML under
     `~/.claude/plugins-data/typst-document-generator/templates/`
     so it's invocable via this plugin's generator skills in future.

Offer the second option proactively when the user lands on a template worth
keeping.

### fletcher + doc-base interaction

Fletcher diagrams render inline. They respect the surrounding `set text`
and `set page` rules from `doc-base`. No special handling needed — just
`#import` and use.

### lilaq + doc-base interaction

Same as fletcher — embeds cleanly. If the chart needs its own page, wrap in
`pagebreak(weak: true)` + the figure.

## Output

After wiring in, tell the user:

- Which library was added and why.
- Where the import line and minimal example were placed.
- Anything they need to run manually (e.g. `pip install typst` for
  typst-py).
- A link to the upstream repo for docs.

## Extending this skill

New library worth recommending? Add an entry to `shared/ecosystem.md` first
(that's the source of truth), then update the picker table in step 1 here.
