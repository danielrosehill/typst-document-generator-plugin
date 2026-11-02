---
name: personal-confidential
description: Generate a Typst document using the user's `personal-confidential` template — bold "PRIVILEGED & CONFIDENTIAL" header, page number top-right, confidentiality notice on the cover naming the user. Use for private personal documents (personal finance, health, legal correspondence, sensitive notes) that are for the user's eyes only and must not be shared. Not for business-client work.
---

# Personal Confidential Template

Thin renderer — see `shared/workspace.md` for the data-store schema.

> **Typst must be installed (`which typst`).**

## Preflight

1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh"`. If it reports `profile: missing` → tell the user to run `/typst-document-generator:onboard` and stop.
2. Load the template from `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh" template personal-confidential`. The user's overlay copy wins over the built-in, so use whatever it returns.
3. Load `profile.yaml` from the data dir and the template YAML. Follow the template's `notes:`.

## Workflow

1. Ask for: title, optional subtitle, output path.
2. Default output location: under `~/Documents/` or `~/personal/` (ask which). **Never** a public repo or any synced folder that might be shared.
3. Ask if AI-assisted. Uncommon for personal-confidential; if yes, default placement: **footer**.
4. Copy the base file (`styles.typ`; overlay `bases/` first, see `paths.sh bases`) next to the output `.typ`.
5. Generate the `.typ` scaffold:

   ```typst
   #import "./styles.typ": doc-base, ai-disclosure-block

   #show: doc-base.with(
     title: "{TITLE}",
     subtitle: {SUBTITLE OR none},
     author: "{author.name}",
     header-left: "PRIVILEGED & CONFIDENTIAL",
     header-bold: true,
     // optional ai-disclosure (default footer placement)
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
     for {author.name} and is not to be distributed, copied, or disclosed to
     any third party without explicit authorisation.
   ]

   = Section
   ```

6. Compile and surface errors verbatim on failure.
7. Report the PDF path.

## Style reminders

- For the user's eyes — skip outward-facing polish if they just want the content captured. Don't over-invest in cover design.
- If the document will be printed, remind the user the header/footer will appear on every printed page.
- For slides, structural diagrams, charts, or non-document formats, see `shared/ecosystem.md` or invoke `/typst-document-generator:use-toolkit`.
