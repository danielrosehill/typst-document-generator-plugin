---
name: personal-doc
description: Generate a Typst document using the user's `personal-doc` template from their template library. Renders with IBM Plex Sans body/headings, page number in header and footer, "By: {author.name}" footer, date in profile's format. Use for unpublished personal documents, private notes, or writeups that are not public-facing and not confidential.
---

# Personal Documentation Template

Thin renderer — all identity and template shape live in the user's data
store. See `shared/workspace.md` for the full schema.

> **Typst must be installed at a resolvable path (`which typst`). Do not try to install automatically.**

## Preflight

1. Check `~/.claude/plugins-data/typst-document-generator/profile.yaml` exists. If not → tell the user to run `/typst-document-generator:onboard` and stop.
2. Check `~/.claude/plugins-data/typst-document-generator/templates/personal-doc.yaml` exists. If not → offer to re-seed from `${CLAUDE_PLUGIN_ROOT}/seeds/templates/personal-doc.yaml`.
3. Load profile + template YAML.

## Workflow

1. Ask for: title, optional subtitle, output path (or propose `./{slug}.typ` in the cwd, honouring `profile.default_output_dir` if set).
2. Ask if AI-assisted. If yes, collect tool + role + human work, and placement (default from template: `inline`).
3. Copy `${CLAUDE_PLUGIN_ROOT}/shared/styles.typ` next to the output `.typ`.
4. Generate the `.typ` scaffold with values resolved from profile + answers:

   ```typst
   #import "./styles.typ": doc-base, ai-disclosure-block

   #show: doc-base.with(
     title: "{TITLE}",
     subtitle: {SUBTITLE OR none},
     author: "{author.name}",
     // AI disclosure block if collected
   )

   = Chapter One

   Intro paragraph.
   ```

5. Compile: `typst compile {path}.typ`. If it fails, surface the error verbatim and stop — don't retry with guesses.
6. Report the resulting PDF path.

## Style reminders

- Chapters (`=`) auto page-break. Don't over-nest — stop at `==` unless the doc is >30 pages.
- Prefer real Typst tables over ASCII for tabular data.
- For technical diagrams, recommend the `nano-tech-diagrams` MCP (NanoBanana 2 via Fal).
- Don't add per-section dates, version numbers, or revision stamps unless asked.
- For slides, structural diagrams, charts, or non-document formats, see `shared/ecosystem.md` or invoke `/typst-document-generator:use-toolkit`.
