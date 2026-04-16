---
name: dsr-business-doc
description: Generate a Typst document using the DSR Holdings general business template — DSR logo in header, footer link to dsrholdings.cloud, IBM Plex Sans typography. Use when the user is producing general business documentation under the DSR Holdings brand (proposals, whitepapers, external reports) that is not client-confidential.
---

# DSR Holdings — General Business Template

Use for **general DSR Holdings business documents** — not client-specific, not confidential. Proposals, public-facing company whitepapers, external reports, service descriptions.

For client-confidential work, use `dsr-client-confidential` instead.

> **Typst is already installed at `/usr/local/bin/typst` (v0.13+).** Do not check, do not try to install. Just compile.

## What this template produces

- **Header** (every page): DSR Holdings logo top-left, page number top-right.
- **Footer** (every page): `Page N · By: Daniel Rosehill · dd-mm-yy · dsrholdings.cloud`.
- **Cover**: title, optional subtitle, author, date.
- **TOC**: chapter-level (depth 1).
- **Typography**: IBM Plex Sans body, IBM Plex Serif headings, teal-700 accents.

## Logo path

The DSR Holdings header logo lives at:

```
~/repos/github/my-repos/DSR-Holdings-Cloud/website/public/dsr-holdings-header-logo.png
```

Ask the user to confirm the path — they may have a newer logo or want to use a specific variant (header-logo vs circle-logo vs full logo). If no override is given, use the header-logo.png above. **Copy the logo file next to the `.typ` file** (or into a `lib/` subdir) so Typst can resolve it portably.

## Template scaffold

```typst
#import "./styles.typ": doc-base, ai-disclosure-block

#show: doc-base.with(
  title: "{{TITLE}}",
  subtitle: "{{OPTIONAL SUBTITLE OR none}}",
  logo-path: "./dsr-holdings-header-logo.png",
  logo-width: 2.4cm,
  footer-lines: (
    link("https://dsrholdings.cloud")[dsrholdings.cloud],
  ),
)

= Overview

Business context.

= Main Content

Body.
```

## Optional: AI-assistance disclosure

```typst
#show: doc-base.with(
  title: "{{TITLE}}",
  logo-path: "./dsr-holdings-header-logo.png",
  footer-lines: (link("https://dsrholdings.cloud")[dsrholdings.cloud],),
  ai-disclosure: ai-disclosure-block(
    tool: "Claude Opus 4.6",
    role: "drafting support",
    human: "DSR Holdings — scope, review, sign-off",
  ),
  ai-disclosure-in-footer: true,  // business docs: footer is usually less intrusive
)
```

For business docs, default disclosure placement to **footer** (less intrusive) unless the user prefers inline.

## Workflow

1. Ask the user for: title, optional subtitle, output path.
2. Confirm logo path (default: `~/repos/github/my-repos/DSR-Holdings-Cloud/website/public/dsr-holdings-header-logo.png`).
3. Ask if AI-assisted. Default placement: footer.
4. Copy `shared/styles.typ` and the logo PNG to the target directory.
5. Write the `.typ` file.
6. Compile and verify.
7. Report the PDF path.

## Style reminders

- Business docs are **formal but still slightly creative** — the palette/typography already covers this. Don't over-correct toward bland corporate.
- Prefer real Typst tables for any pricing, scope, or comparison matrices.
- For diagrams (architecture, workflow, system), use the `nano-tech-diagrams` MCP — the slightly creative NanoBanana 2 style fits DSR's brand voice.
- Avoid boilerplate legal text in the main body unless the user asks — no "all trademarks are property of their owners" unless requested.
