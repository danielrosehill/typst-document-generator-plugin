---
name: dsr-client-confidential
description: Generate a Typst document using the DSR Holdings client-confidential template — "CONFIDENTIAL" bold header, client name in header, confidential notice in footer, DSR logo and link. Use when the user is producing materials for a specific DSR Holdings client that must be marked confidential.
---

# DSR Holdings — Client Confidential Template

Use for **DSR Holdings client deliverables that must be marked confidential** — proposals to a named client, technical reports, audits, prompt libraries delivered under engagement, anything with a specific client's data or requirements.

> **Typst is already installed at `/usr/local/bin/typst` (v0.13+).** Do not check, do not try to install. Just compile.

## What this template produces

- **Header** (every page): **CONFIDENTIAL** in bold amber + client name, page number top-right. DSR logo also shown (smaller, below confidential badge — or above, depending on layout preference).
- **Footer** (every page): `Page N · By: Daniel Rosehill · dd-mm-yy · dsrholdings.cloud · Confidential — {{CLIENT NAME}}`.
- **Cover**: title, subtitle, author, date, plus a prominent confidentiality notice block.
- **TOC**: chapter-level (depth 1).
- **Typography**: IBM Plex Sans body, IBM Plex Serif headings, teal-700 accents.

## Required parameter

- **Client name** — must be gathered before generating. This appears in the header, footer, and cover confidentiality notice.

## Template scaffold

```typst
#import "./styles.typ": doc-base, ai-disclosure-block

#let client = "{{CLIENT NAME}}"

#show: doc-base.with(
  title: "{{TITLE}}",
  subtitle: "{{OPTIONAL SUBTITLE OR none}}",
  header-left: "CONFIDENTIAL — " + client,
  header-bold: true,
  footer-lines: (
    link("https://dsrholdings.cloud")[dsrholdings.cloud],
    [Confidential — #client],
  ),
)

// Confidentiality notice block (after cover, before TOC)
#block(
  fill: rgb("#FEF3C7"),
  stroke: 0.5pt + rgb("#B45309"),
  inset: 12pt,
  radius: 3pt,
  width: 100%,
)[
  #set text(size: 10pt)
  #text(weight: "bold", fill: rgb("#B45309"))[Confidentiality Notice] \
  This document contains confidential and proprietary information prepared
  by DSR Holdings for #client. It may not be reproduced, distributed, or
  disclosed to third parties without written permission from DSR Holdings
  and the client.
]

= Executive Summary

Client-facing summary.

= Scope

Detail.
```

## Note on logo + confidential badge coexistence

The shared `doc-base` renders `header-left` (confidential badge) **or** `logo-path` (logo), not both by default — the top-right always stays the page number. For client-confidential docs, prioritise the **confidential badge + client name** in the header. Reference DSR branding through:

- The footer link to dsrholdings.cloud.
- A small DSR logo on the cover page (optionally — insert manually in the body if the user wants it).

If the user explicitly wants both the confidential badge **and** a small DSR logo in the header, tell them you'll need a custom header override — not supported by the default scaffold.

## Optional: AI-assistance disclosure

For client-confidential work, **always ask** whether the client is aware of AI involvement. If yes, disclose inline on cover. If the client has prohibited AI tools, advise the user this template isn't appropriate and check before proceeding.

```typst
ai-disclosure: ai-disclosure-block(
  tool: "Claude Opus 4.6",
  role: "drafting support (client-approved)",
  human: "Daniel Rosehill — scope, editorial review, technical sign-off",
),
ai-disclosure-in-footer: false,  // inline for transparency on client-facing work
```

## Workflow

1. Ask the user for: **client name** (required), title, optional subtitle, output path.
2. Ask if AI-assisted. If yes, confirm client is aware/approves.
3. Copy `shared/styles.typ` to the target directory.
4. Write the `.typ` file with client name substituted throughout.
5. Compile and verify — check the PDF's header text contains both CONFIDENTIAL and the client name.
6. Report the PDF path.

## Style reminders

- Confidential docs: prefer **explicit page breaks** (`#pagebreak()`) between major sections so that a single printed page can stand alone with the confidential header clearly visible.
- Include a `= References` or `= Sources` chapter if the doc draws on client-provided material, even if not externally published.
- Be careful about filename conventions — don't put client names in public filenames if the file will ever be synced to a public location. Default filename: `YYYY-MM-DD-{slug}-confidential.typ` without client name in the filename unless the user requests otherwise.
