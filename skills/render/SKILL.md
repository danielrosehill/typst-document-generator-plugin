---
name: render
description: Render a Typst document from any template, built-in or the user's own private templates in their overlay directory (their business letterhead, a proposal format, a house style). Lists what's available, picks one by name or trigger phrase, follows that template's own notes, and compiles a PDF. Use on "make this a PDF with my <X> template", "use my proposal format", "which document templates do I have", or whenever the request matches a user template that has no dedicated skill.
---

# Render any template

This is the entry point for templates that have no skill of their own,
usually the user's private ones. The built-in skills (`personal-doc`,
`public-doc`, `business-doc`, `client-confidential`, `personal-confidential`,
`briefing`, `screenplay`) follow the same contract and are only shortcuts.

The contract is in `shared/workspace.md`. Read it first.

> **Typst must be installed at a resolvable path (`which typst`). Do not try to install it automatically.**

## Steps

1. **Resolve the layers:**
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh"
   "${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh" templates
   ```
   If the output has a `legacy_dir:` line, mention it once and offer
   `/typst-document-generator:onboard` to move it.

2. **Pick the template.** Match the request against each template's `name`,
   `label`, `description` and `triggers` (read the YAML files). User templates
   come first, because they're the more specific match. If two match, or none
   does, show the list as `name (user|builtin): description` and ask. When the
   user asks "what templates do I have", show that list and stop.

3. **If the template is a built-in with a dedicated skill**, follow that
   skill's workflow. It has the rendering details for its base (`briefing`,
   `screenplay`, ...). A user template that overrides a built-in by name still
   uses that skill's workflow, with the user's YAML values.

4. **Otherwise render it here**, following the contract in `shared/workspace.md`:
   - Read the YAML. Follow its `notes:` as instructions: they're the template
     author's own workflow (sections, tone, what to ask for).
   - Check `requires.business` against `profile.yaml`.
   - Collect `variables:`. Skip any prompt the user already answered in their request.
   - Base: `base_file` (default `styles.typ`), looked up with `paths.sh bases`,
     overlay first. Copy it next to the output. Copy any logo too (paths in
     `profile.yaml` are relative to the data dir unless they're absolute or
     start with `~`).
   - Write the `.typ` with `#import "./<base_file>": <base>` and
     `#show: <base>.with(...)`, using the resolved tokens.
   - Ask about AI-assistance disclosure if the base supports it
     (`doc-base` does). Use the template's `ai_disclosure.default_placement`.

5. **Compile and look:**
   ```bash
   typst compile {path}.typ
   pdftoppm -png -r 50 -f 1 -l 3 {path}.pdf /tmp/render-preview
   ```
   On an error, show it verbatim and stop. Read the preview PNGs before
   reporting. A template that compiles can still be broken visually: a
   missing logo, a footer that's too long, an empty cover field.

6. Report the PDF path and which template (and which layer) was used.

## When the user wants a new format

If they ask for a format that doesn't exist yet, or want to keep the look of
the document you just made, hand over to `/typst-document-generator:add-profile`.
By default it saves the new format to their private overlay, not the plugin.
