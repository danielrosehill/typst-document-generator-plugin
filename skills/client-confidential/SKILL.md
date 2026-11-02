---
name: client-confidential
description: Generate a Typst document using the user's `client-confidential` template. Bold "CONFIDENTIAL — {client}" header, confidentiality notice on the cover, "Confidential — {client}" in the footer, business site link. Use for client deliverables that must be marked confidential. Requires profile.business and a client name at invocation.
---

# Client Confidential Template

Thin renderer — see `shared/workspace.md` for the data-store schema.

Uses the `client-confidential` template. If the overlay has more than one client-confidential variant (one per business), ask which.

> **Typst must be installed (`which typst`).**

## Preflight

1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh"`. If it reports `profile: missing` → tell the user to run `/typst-document-generator:onboard` and stop.
2. Load the template from `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh" template client-confidential`. The user's overlay copy wins over the built-in, so use whatever it returns.
3. Load `profile.yaml` from the data dir and the template YAML. Follow the template's `notes:`.
4. `profile.business` is not null → else stop (needs business context).

## Workflow

1. Gather the **required** `client` variable (the client's name).
2. Ask for: title, optional subtitle, output path. Default filename: `YYYY-MM-DD-{slug}-confidential.typ` — do NOT include the client name in the filename unless the user asks.
3. Ask if AI-assisted. If yes, **confirm the client is aware/approves** AI involvement before proceeding. If the client has prohibited AI tools, stop and tell the user this template isn't appropriate.
4. Copy the base file (`styles.typ`; overlay `bases/` first, see `paths.sh bases`) next to the output `.typ`.
5. Generate the `.typ` scaffold:

   ```typst
   #import "./styles.typ": doc-base, ai-disclosure-block

   #let client = "{CLIENT}"

   #show: doc-base.with(
     title: "{TITLE}",
     subtitle: {SUBTITLE OR none},
     author: "{author.name}",
     header-left: "CONFIDENTIAL — " + client,
     header-bold: true,
     footer-lines: (
       link("https://{business.site}")[{business.site}],
       [Confidential — #client],
     ),
     // optional ai-disclosure (default inline)
   )

   // Confidentiality block (after cover, before TOC)
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
     by {business.name} for #client. It may not be reproduced, distributed, or
     disclosed to third parties without written permission from {business.name}
     and the client.
   ]

   = Executive Summary
   ```

6. Compile. Verify the rendered PDF's first-page header text contains both "CONFIDENTIAL" and the client name (use `pdftotext {path}.pdf - | head -5`).
7. Report the PDF path.

## Notes

- **Logo + confidential badge**: `doc-base` uses the top-left slot for either the header-left text OR the logo, not both. Confidentiality badge wins. If the user wants the business logo too, insert it manually on the cover page.
- Prefer **explicit page breaks** (`#pagebreak()`) between major sections so a printed page can stand alone with the confidential header clearly visible.
- Include a `= References` or `= Sources` chapter if the doc draws on client-provided material.
- For slides, structural diagrams, charts, or non-document formats, see `shared/ecosystem.md` or invoke `/typst-document-generator:use-toolkit`.
