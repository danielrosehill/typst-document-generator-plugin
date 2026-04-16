---
name: personal-doc
description: Generate a Typst document using Daniel's personal-documentation template — IBM Plex Sans, page number in header (top right) and footer, author "By Daniel Rosehill", date dd-mm-yy. Use when the user asks for a personal document, private note, or unpublished writeup that isn't confidential or public-facing.
---

# Personal Documentation Template

Use for **Daniel's unpublished personal documents** — notes, reports, research writeups that are not public-facing and not confidential. Simplest of the five templates.

> **Typst is already installed at `/usr/local/bin/typst` (v0.13+).** Do not check, do not try to install. Just compile.

## What this template produces

- **Header** (every page): page number top-right.
- **Footer** (every page): `Page N · By: Daniel Rosehill · dd-mm-yy`.
- **Cover**: title + optional subtitle + author + date.
- **TOC**: simple, chapter-level only (depth 1).
- **Typography**: IBM Plex Sans body, IBM Plex Serif headings, teal-700 accents.

## Template scaffold

Create the new doc at the path the user specifies (or ask). The file imports the shared styles module from this plugin:

```typst
#import "@preview/typst-document-generator/shared/styles.typ": doc-base, ai-disclosure-block

#show: doc-base.with(
  title: "{{TITLE}}",
  subtitle: "{{OPTIONAL SUBTITLE OR none}}",
  // author defaults to "Daniel Rosehill"
  // date defaults to today
)

= Chapter One

Intro paragraph.

== Section

Body text. Use markdown-style tables for tabular data:

#table(
  columns: 3,
  [*Column A*], [*Column B*], [*Column C*],
  [value], [value], [value],
)

= Chapter Two

Use `pagebreak()` between chapters — they auto-break via the `= Chapter` heading.
```

Because the plugin isn't actually published as a Typst package, copy the `shared/styles.typ` from this plugin into the target directory (or a `lib/` subdir) and import it with a relative path:

```typst
#import "./styles.typ": doc-base, ai-disclosure-block
```

The skill instructions below assume you'll copy the styles file alongside the new document.

## Optional: AI-assistance disclosure

If the user says the doc was AI-assisted, add the disclosure:

```typst
#show: doc-base.with(
  title: "{{TITLE}}",
  ai-disclosure: ai-disclosure-block(
    tool: "Claude Opus 4.6",
    role: "drafted structure and initial prose",
    human: "reviewed, edited, and signed off",
  ),
  ai-disclosure-in-footer: false,  // true = footer line, false = inline amber block on cover
)
```

Ask the user whether the disclosure should render **inline** (prominent amber block on cover page) or in the **footer** (italic subtle line under the page footer). Default: inline.

## Workflow

1. Ask the user for: title, optional subtitle, output path (or propose `./{{slug}}.typ`).
2. Ask if AI-assisted. If yes, ask for tool name + role, and whether inline or footer.
3. Copy `shared/styles.typ` from this plugin's install location to the same directory as the new `.typ` file.
4. Write the `.typ` file with the scaffold above, substituting the user's values.
5. Compile: `typst compile {{path}}.typ` — verify with `pdftotext {{path}}.pdf - | head -20`.
6. Report the output PDF path.

## Style reminders

- Chapters (`=`) auto page-break. Don't over-nest — stop at `==` unless the doc is >30 pages.
- Prefer real Typst tables over ASCII for anything tabular.
- For technical diagrams, recommend the `nano-tech-diagrams` MCP (NanoBanana 2 via Fal) — the user keeps a consistent creative visual style across docs via that tool.
- Don't add per-section dates, version numbers, or revision stamps unless the user asks.
