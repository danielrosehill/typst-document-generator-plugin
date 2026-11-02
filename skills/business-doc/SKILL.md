---
name: business-doc
description: Generate a Typst document using the user's business template (`business-doc`). Business logo in header, footer link to `{business.site}`. Use for general business documents that are not client-specific and not confidential (proposals, whitepapers, external reports). Requires profile.business to be populated.
---

# Business — General Template

Thin renderer — see `shared/workspace.md` for the data-store schema.

Uses the `business-doc` template. If the user has several businesses, each with its own template in the overlay (e.g. `acme-business-doc`), list the templates with `requires.business: true` and ask which, or hand over to `/typst-document-generator:render`.

> **Typst must be installed (`which typst`).**

## Preflight

1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh"`. If it reports `profile: missing` → tell the user to run `/typst-document-generator:onboard` and stop.
2. Load the template from `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh" template business-doc`. The user's overlay copy wins over the built-in, so use whatever it returns.
3. Load `profile.yaml` from the data dir and the template YAML. Follow the template's `notes:`.
4. `profile.business` is not null → else stop and explain (this template needs business context; re-run onboarding to add it).
5. Resolve `profile.business.logo_path` (relative paths are relative to the data dir) and check it exists → if missing, ask for a new path or skip the logo.

## Workflow

1. Ask for: title, optional subtitle, output path.
2. Ask if AI-assisted. Default placement: **footer** (less intrusive for business docs).
3. Copy `the base file (`styles.typ`; overlay `bases/` first, see `paths.sh bases`)` and the logo file next to the output `.typ`. Use a local filename (e.g. `./logo.png`) in the scaffold so the output is portable.
4. Generate the `.typ` scaffold:

   ```typst
   #import "./styles.typ": doc-base, ai-disclosure-block

   #show: doc-base.with(
     title: "{TITLE}",
     subtitle: {SUBTITLE OR none},
     author: "{author.name}",
     logo-path: "./logo.png",
     logo-width: 2.4cm,
     footer-lines: (
       link("https://{business.site}")[{business.site}],
     ),
     // optional ai-disclosure (default footer placement)
   )

   = Overview

   Business context.
   ```

5. Compile and surface errors verbatim on failure.
6. Report the PDF path.

## Style reminders

- Formal but slightly creative — don't over-correct toward bland corporate.
- Use real Typst tables for pricing, scope, or comparison matrices.
- For diagrams, use the `nano-tech-diagrams` MCP.
- No boilerplate legal text in the main body unless asked.
- For slides, structural diagrams, charts, or non-document formats, see `shared/ecosystem.md` or invoke `/typst-document-generator:use-toolkit`.
