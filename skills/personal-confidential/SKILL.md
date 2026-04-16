---
name: personal-confidential
description: Generate a Typst document using Daniel's personal-confidential template — "PRIVILEGED & CONFIDENTIAL" bold header, page number top-right, IBM Plex Sans. Use when the user is producing private personal documents (personal finance, health, legal correspondence, sensitive notes) that are for his eyes only and must not be shared.
---

# Personal Confidential Template

Use for **Daniel's own private documents that must not be shared** — personal finance records, health documentation, legal correspondence, sensitive personal notes, things he'd want marked clearly so if the PDF is ever mis-shared it's immediately obvious.

Not for DSR Holdings client work — use `dsr-client-confidential` for that.

> **Typst is already installed at `/usr/local/bin/typst` (v0.13+).** Do not check, do not try to install. Just compile.

## What this template produces

- **Header** (every page): **PRIVILEGED & CONFIDENTIAL** in bold amber top-left, page number top-right.
- **Footer** (every page): `Page N · By: Daniel Rosehill · dd-mm-yy`.
- **Cover**: title, optional subtitle, author, date, plus a prominent privilege notice block.
- **TOC**: chapter-level (depth 1).
- **Typography**: IBM Plex Sans body, IBM Plex Serif headings, teal-700 accents.

## Template scaffold

```typst
#import "./styles.typ": doc-base, ai-disclosure-block

#show: doc-base.with(
  title: "{{TITLE}}",
  subtitle: "{{OPTIONAL SUBTITLE OR none}}",
  header-left: "PRIVILEGED & CONFIDENTIAL",
  header-bold: true,
)

#block(
  fill: rgb("#FEF3C7"),
  stroke: 0.5pt + rgb("#B45309"),
  inset: 12pt,
  radius: 3pt,
  width: 100%,
)[
  #set text(size: 10pt)
  #text(weight: "bold", fill: rgb("#B45309"))[Privileged and Confidential] \
  This document contains private personal information. It is intended solely
  for Daniel Rosehill and is not to be distributed, copied, or disclosed to
  any third party without explicit authorisation.
]

= Section

Private content.
```

## Optional: AI-assistance disclosure

Personal-confidential documents rarely need AI disclosure (no external audience), but if the user wants to track it for his own records, use footer placement:

```typst
ai-disclosure: ai-disclosure-block(
  tool: "Claude Opus 4.6",
  role: "structured transcript / first-pass draft",
  human: "Daniel Rosehill — full review",
),
ai-disclosure-in-footer: true,
```

## Workflow

1. Ask the user for: title, optional subtitle, output path.
2. Ask if AI-assisted (uncommon for personal-confidential; if yes, default to footer placement).
3. Copy `shared/styles.typ` to the target directory.
4. Write the `.typ` file.
5. Compile and verify — check the PDF header shows PRIVILEGED & CONFIDENTIAL prominently in bold amber.
6. Report the PDF path.

## Style reminders

- These are **for Daniel's eyes**. Skip the outward-facing polish if he just wants the content captured — don't over-invest in cover design.
- Default output location: somewhere under `~/Documents/` or `~/personal/` (ask) — **never** commit to a public repo.
- If the document will be printed, remind the user the header/footer will appear on every printed page.
