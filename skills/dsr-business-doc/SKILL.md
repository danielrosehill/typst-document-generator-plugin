---
name: dsr-business-doc
description: Generate a Typst document using the user's business template (seeded as `dsr-business-doc.yaml` for DSR Holdings users, or `<business-slug>-business-doc.yaml` for others). Business logo in header, footer link to `{business.site}`. Use for general business documents that are not client-specific and not confidential (proposals, whitepapers, external reports). Requires profile.business to be populated.
---

# Business — General Template

Thin renderer — see `shared/workspace.md` for the data-store schema.

This skill looks for `dsr-business-doc.yaml` by default. If the user's business isn't DSR Holdings and they onboarded with a different slug, ask which template to use (listing the ones under `templates/` whose `requires.business: true` and which are not client-confidential).

> **Typst must be installed (`which typst`).**

## Preflight

1. `profile.yaml` exists → else prompt onboarding.
2. `profile.business` is not null → else stop and explain (this template needs business context; re-run onboarding to add it).
3. Verify `profile.business.logo_path` exists on disk → if missing, ask for a new path or skip the logo.
4. Load profile + template YAML.

## Workflow

1. Ask for: title, optional subtitle, output path.
2. Ask if AI-assisted. Default placement: **footer** (less intrusive for business docs).
3. Copy `${CLAUDE_PLUGIN_ROOT}/shared/styles.typ` and the logo file next to the output `.typ`. Use a local filename (e.g. `./logo.png`) in the scaffold so the output is portable.
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
