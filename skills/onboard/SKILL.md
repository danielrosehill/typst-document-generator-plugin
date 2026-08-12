---
name: onboard
description: First-run onboarding for the typst-document-generator plugin. Interview the user about their identity (name, email, personal site), optional business context (name, site, logo), and default preferences (license, output directory), then seed the template library with the six built-in templates (personal-doc, public-doc, business-doc, client-confidential, personal-confidential, briefing) personalized to the user's answers. Writes everything to ~/.claude/plugins-data/typst-document-generator/. Use this before any other typst-document-generator skill, or when the user says "set up typst templates", "onboard typst", or wants to reset/reseed their templates.
---

# typst-document-generator: onboard

Establish the persistent profile + template library for this plugin.

Full data-store schema is in `shared/workspace.md` — read it before running.

## When to use

- User says "onboard typst", "set up typst templates", "configure typst-document-generator".
- Any other skill in this plugin reports `profile.yaml` missing.
- User wants to reset, reseed, or add a new custom template.

## Prerequisites

- `typst` binary available. Check with `which typst`. If missing, tell the user to install (`cargo install --locked typst-cli` or grab the release from <https://github.com/typst/typst/releases>) and stop.
- The data-store directory. Create if missing:

  ```bash
  mkdir -p ~/.claude/plugins-data/typst-document-generator/templates
  mkdir -p ~/.claude/plugins-data/typst-document-generator/assets
  ```

## Procedure

### 1. Detect existing install

Check for `~/.claude/plugins-data/typst-document-generator/profile.yaml`.

- **Exists** — offer three paths:
  - *Update profile* (overwrite identity/business/defaults; keep templates).
  - *Add custom template* (skip to step 5).
  - *Reseed built-in templates* (re-copy the six defaults; confirm overwrite for any that already exist).
  - *Full reset* (back up existing files with `.bak-YYYYMMDD-HHMMSS` then start fresh).

- **Missing** — proceed to step 2.

### 2. Identity interview

Collect:

- `author.name` — full name (required).
- `author.email` — primary email (required).
- `author.personal_site` — domain only, no protocol (e.g. `example.com`). Optional but recommended for `public-doc`.
- `author.public_email` — a separate public-facing email, if they have one. Optional.
- `date_format` — default `dd-mm-yy`. Only that format is currently supported — just confirm.

### 3. Business context (optional)

Ask: "Do you produce documents under a business or brand other than your personal name?"

- **No** — set `business: null`. The `dsr-business-doc` and `dsr-client-confidential` seed templates will be skipped (or generated in a disabled state — ask which).
- **Yes** — collect:
  - `business.name`
  - `business.site` (domain only)
  - `business.logo_path` — absolute path or `~/…`. Verify the file exists (`ls <path>`). If they don't have one ready, let them skip and fill in later by editing `profile.yaml`.

### 4. Defaults

- `default_license` — default `MIT`. Common alternatives: `Apache-2.0`, `CC-BY-4.0`, `CC-BY-SA-4.0`, `GPL-3.0`, `All Rights Reserved`.
- `default_output_dir` — default `null` (ask each time). If the user wants a fixed landing spot (e.g. `~/Documents/typst-output/`), capture it.

### 5. Write `profile.yaml`

Write to `~/.claude/plugins-data/typst-document-generator/profile.yaml` with `captured_at: <today ISO date>`. Schema is in `shared/workspace.md`.

### 6. Seed built-in templates

Copy these six template YAMLs from the plugin's install dir (`${CLAUDE_PLUGIN_ROOT}/seeds/templates/` — see note below) into `~/.claude/plugins-data/typst-document-generator/templates/`:

- `personal-doc.yaml`
- `public-doc.yaml`
- `dsr-business-doc.yaml` (rename to `<business-slug>-business-doc.yaml` if business isn't DSR Holdings; update `name:` inside to match)
- `dsr-client-confidential.yaml` (same rename logic → `<business-slug>-client-confidential.yaml`)
- `personal-confidential.yaml`
- `briefing.yaml`

If the user said "no business", skip the two business templates.

> **Note on seeds**: this plugin's seed templates live at `seeds/templates/*.yaml` inside the plugin install dir. They contain no personal data — only the structural shape. Token references like `{author.name}` and `{business.site}` resolve at render time from `profile.yaml`.

### 7. Optionally collect a first custom template

Ask: "Do you want to define any additional templates now (e.g. a second business, a specific report format)?"

If yes, walk through the template schema (from `shared/workspace.md`) interactively and write `templates/<name>.yaml`.

### 8. Summary

Print:
- Data store path.
- Profile summary (name, business status, default license).
- List of templates written.
- List of sibling skills the user can now invoke (`personal-doc`, `public-doc`, `dsr-business-doc`, `dsr-client-confidential`, `personal-confidential`, `briefing`, plus any custom ones as they're added).

## Re-running

Re-running is safe — it always offers the three update paths from step 1 rather than silently overwriting. Always back up existing files with `.bak-<timestamp>` before a full reset.

## Tips

- Users with no business can still use `personal-doc`, `public-doc`, `personal-confidential` and `briefing` — the other two require business context.
- If the user changes their personal site or business name later, a `profile.yaml` edit is enough; no template regeneration needed because templates reference tokens, not literals.
- Custom template ideas worth suggesting: a "meeting notes" template, a "client pitch" variant with different footer, a "technical RFC" template with dense TOC (`toc-depth: 2`).
