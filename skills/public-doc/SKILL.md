---
name: public-doc
description: Generate a Typst document using Daniel's public-facing documentation template — same base as personal-doc but adds a link to danielrosehill.com and an open-source license notice (MIT by default, configurable). Use when the user says the document is being published publicly, shared externally, or distributed with code.
---

# Public-Facing Documentation Template

Use for **documents Daniel intends to publish** — GitHub READMEs-as-PDF, open writeups, public reports, anything going out under his personal brand.

> **Typst is already installed at `/usr/local/bin/typst` (v0.13+).** Do not check, do not try to install. Just compile.

## What this template produces

- **Header** (every page): page number top-right.
- **Footer** (every page): `Page N · By: Daniel Rosehill · dd-mm-yy · danielrosehill.com · Licensed under {{LICENSE}}`.
- **Cover**: title, optional subtitle, author, date.
- **TOC**: chapter-level (depth 1).
- **Typography**: IBM Plex Sans body, IBM Plex Serif headings, teal-700 accents.

## Template scaffold

```typst
#import "./styles.typ": doc-base, ai-disclosure-block

#show: doc-base.with(
  title: "{{TITLE}}",
  subtitle: "{{OPTIONAL SUBTITLE OR none}}",
  footer-lines: (
    link("https://danielrosehill.com")[danielrosehill.com],
    [Licensed under {{LICENSE}}],
  ),
)

= Introduction

Public-facing intro. Assume the reader has no prior context.

= Section

Main body.
```

## License handling

Default to **MIT**. Accept user overrides: Apache-2.0, CC-BY-4.0, CC-BY-SA-4.0, GPL-3.0, "All rights reserved", etc. Always phrase as `Licensed under {LICENSE}` in the footer line.

If the user says the repo/doc is unlicensed or proprietary, use `Licensed under All Rights Reserved` or omit the license line entirely — ask.

## Optional: AI-assistance disclosure

For public docs, disclosure is especially important. Default to **inline** (amber block on cover) rather than footer-only when AI was involved in drafting:

```typst
#show: doc-base.with(
  title: "{{TITLE}}",
  footer-lines: (
    link("https://danielrosehill.com")[danielrosehill.com],
    [Licensed under MIT],
  ),
  ai-disclosure: ai-disclosure-block(
    tool: "Claude Opus 4.6",
    role: "research synthesis and first draft",
    human: "Daniel Rosehill — direction, editorial review, final approval",
  ),
)
```

## Workflow

1. Ask the user for: title, optional subtitle, output path, license (default MIT).
2. Ask if AI-assisted. If yes, gather tool + role + human work — recommend inline placement for public docs.
3. Copy `shared/styles.typ` to the target directory.
4. Write the `.typ` file.
5. Compile and verify.
6. Report the PDF path.

## Style reminders

- Public docs should be **self-contained**. Lead with a summary or key findings.
- Cite sources inline or in a `= References` chapter at the end.
- For technical diagrams, use the `nano-tech-diagrams` MCP (NanoBanana 2 via Fal) — consistent creative style across Daniel's public materials.
- Avoid internal shorthand, "the brief", or references to other files the reader won't have.
