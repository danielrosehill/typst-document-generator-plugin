---
name: public-doc
description: Generate a Typst document using the user's `public-doc` template — same base as personal-doc but adds a footer link to `{author.personal_site}` and an open-source license notice (defaults to `profile.default_license`, overridable per-invocation). Use when the user says the document is being published publicly, shared externally, or distributed with code.
---

# Public-Facing Documentation Template

Thin renderer — see `shared/workspace.md` for the data-store schema.

> **Typst must be installed (`which typst`). Do not try to install automatically.**

## Preflight

1. `~/.claude/plugins-data/typst-document-generator/profile.yaml` exists → else prompt onboarding.
2. `templates/public-doc.yaml` exists → else offer to re-seed.
3. Load profile + template YAML.
4. If `profile.author.personal_site` is empty, tell the user the public-doc footer will look wrong and ask whether to continue or edit profile first.

## Workflow

1. Ask for: title, optional subtitle, output path.
2. Resolve `license` variable:
   - Default: `profile.default_license` (usually `MIT`).
   - Accept user overrides: `Apache-2.0`, `CC-BY-4.0`, `CC-BY-SA-4.0`, `GPL-3.0`, `All Rights Reserved`, etc.
   - If the user says proprietary/unlicensed, use `All Rights Reserved` or omit the license line — ask which.
3. Ask if AI-assisted. Strongly prefer **inline** placement for public docs (transparency).
4. Copy `${CLAUDE_PLUGIN_ROOT}/shared/styles.typ` next to the output `.typ`.
5. Generate the `.typ` scaffold:

   ```typst
   #import "./styles.typ": doc-base, ai-disclosure-block

   #show: doc-base.with(
     title: "{TITLE}",
     subtitle: {SUBTITLE OR none},
     author: "{author.name}",
     footer-lines: (
       link("https://{author.personal_site}")[{author.personal_site}],
       [Licensed under {LICENSE}],
     ),
     // optional ai-disclosure
   )

   = Introduction

   Public-facing intro. Assume the reader has no prior context.
   ```

6. Compile and surface errors verbatim on failure.
7. Report the PDF path.

## Style reminders

- Public docs should be **self-contained** — lead with a summary or key findings.
- Cite sources inline or in a `= References` chapter.
- For technical diagrams, use the `nano-tech-diagrams` MCP (NanoBanana 2 via Fal).
- Avoid internal shorthand, "the brief", or references to files the reader won't have.
