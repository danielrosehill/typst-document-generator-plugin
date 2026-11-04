# Typst Document Generator

Opinionated Typst document templates as agent skills: a public, generic set of formats, plus a private overlay folder where your own formats (your letterhead, your business, your house style) live without forking the plugin.

## What this plugin is

A thin rendering layer over Typst that:

- Ships a shared visual style (IBM Plex Sans, teal-700 accents, amber confidentiality markers) in `shared/styles.typ`.
- Ships six **built-in templates** covering common document kinds — personal, public, business-general, client-confidential, personal-confidential, and briefing.
- Ships a standalone `screenplay` format (Courier 12, spec-script layout).
- On first run, an `onboard` skill interviews you for identity (name, email, personal site) and optional business context (name, site, logo) and writes them to your **private overlay** folder.
- Each generator skill is a thin renderer that reads your profile and the template YAML (your overlay copy first, then the built-in) and emits a `.typ` file and compiled PDF. `render` does the same for any template, including ones only you have.

**The plugin itself contains no personal data.** Everything is resolved at render time from your local data store.

## The built-in templates

| Template | Use for | Header | Footer |
|---|---|---|---|
| `personal-doc` | Unpublished notes, writeups | Page number | Page · By: {name} · date |
| `public-doc` | Publications, open writeups | Page number | Page · By · date · {site} · License |
| `business-doc` | General business documents | Business logo + page number | Page · By · date · {business site} |
| `client-confidential` | Client deliverables | **CONFIDENTIAL — {client}** (bold) + page number | Page · By · date · {business site} · Confidential — {client} |
| `personal-confidential` | Private personal docs (finance, health, legal) | **PRIVILEGED & CONFIDENTIAL** (bold) + page number | Page · By: {name} · date |
| `briefing` | Printable field sheets — shopping lists, trip plans, run sheets | *(none — marking is watermarked)* | Page · By: {name} · date · **{marking}** |

`briefing` is the odd one out: it renders through `briefing-base` rather than
`doc-base`, and deliberately has no TOC and no chapter page-breaks. It is for
documents held in one hand in a shop or a car, not read at a desk. Everything
below applies to the other five (and not to `screenplay`, below).

## Screenplay (standalone format)

`screenplay` is not a seed template and ignores the shared style entirely. It
renders through [`shared/screenplay.typ`](shared/screenplay.typ), a skeleton
that fixes the spec-script conventions: Courier 12 (Courier Prime → Courier New
→ Courier → Nimbus Mono PS fallback), US Letter (A4 optional), 1.5in/1in
margins, industry element indents (character 3.7in, parenthetical 3.1in,
dialogue 2.5in × 3.5in), a 12pt line grid (≈ 1 page per minute), a title page and
`2.`-style page numbers. The skill prepares the input (Fountain, plain text,
Markdown, Word/PDF exports, Final Draft `.fdx`, or prose to adapt) into
`#scene`, `#action`, `#dialogue`, `paren`, `#transition`, `#centered` and `#dual`
calls, then compiles. It needs no profile. One limit: dialogue blocks never
split across pages, so there's no `(MORE)`/`(CONT'D)` at page breaks.

All templates share:

- **IBM Plex Sans** body, **IBM Plex Serif** display (falls back to Sans weight if Serif not installed), **IBM Plex Mono** code.
- Teal-700 heading accent on slate-800 body, warm amber highlights for confidentiality markers.
- Chapter-level TOC (depth 1 by default).
- Page breaks on every chapter (`=` heading).
- Proper Typst tables for tabular data.
- Optional **AI-assistance disclosure** (inline amber block on cover, or subtle footer line).

## Installation

```
/plugin marketplace add danielrosehill/Claude-Code-Plugins
/plugin install typst-document-generator@danielrosehill
```

Prerequisite: [Typst](https://typst.app/) v0.13+ on `PATH`.

After install, run the onboarding skill:

```
/typst-document-generator:onboard
```

This writes your profile to the overlay. The built-in templates are read straight from the plugin, so nothing is copied. Skills that put your name or business on the page need the profile; `screenplay` doesn't.

## Public plugin, private formats

The plugin holds only generic layouts. Everything that's yours lives in an
overlay folder outside it, which survives plugin updates and can be its own
private git repo:

```
~/.claude-user-data/typst-document-generator/    # or $TYPST_DOCGEN_HOME
├── profile.yaml        # name, email, site, business, logo path, defaults
├── templates/          # your formats; same name as a built-in = your override
├── bases/              # your own Typst wrappers (a house style), optional
└── assets/             # logos and images
```

- **Your own format** is a YAML in `templates/`, with `notes:` holding its
  instructions and `triggers:` naming the phrases that pick it. No skill and no
  fork needed: `/typst-document-generator:render` lists and renders it.
- **Your own look** is a self-contained `.typ` in `bases/`, which the template names via `base_file:`.
- **Tweaking a built-in** means copying its YAML into `templates/` and editing
  the copy. Your copy wins, and untouched built-ins keep getting fixes.
- **Where the folder is:** `scripts/paths.sh` prints it and the rule that
  picked it. The order is `$TYPST_DOCGEN_HOME` → `$CLAUDE_USER_DATA/typst-document-generator`
  → `~/.claude-user-data/…` (if it exists) → `$XDG_DATA_HOME/claude-plugins/…`
  (if it exists) → `~/.claude-user-data/…`. Data from 0.5.0 and earlier
  (`~/.claude/plugins-data/…`) is moved by `onboard`.

Full schema and rendering contract: [`shared/workspace.md`](shared/workspace.md).
Tokens (`{author.name}`, `{business.site}`, `{client}`, `{license}`, …) resolve at
render time from `profile.yaml` and per-invocation prompts.

## Usage

Once onboarded, ask Claude:

- "Create a personal doc about X"
- "Start a public writeup on Y, MIT licensed"
- "Write a client-confidential report for client Acme about Z"
- "Format this script as a screenplay PDF"
- "Make this a PDF with my proposal template" (one of yours, via `render`)

Claude picks the right skill, collects any template-specific values (client name, license override, AI disclosure), copies the base file next to the output, writes the `.typ`, and compiles to PDF.

## Adding your own formats

Run `/typst-document-generator:add-profile`, usually after a one-off document
came out well. It separates the reusable layout from the content and saves it to
your **overlay** by default: a template YAML, plus a base `.typ` only if the
existing bases can't express the look. Only a generic layout you choose to
contribute becomes a built-in in the plugin.

You can also hand-write a YAML in the overlay's `templates/`, following
[`shared/workspace.md`](shared/workspace.md).

## Customising the visual style

`shared/styles.typ` is the only file that meaningfully encodes the visual style (palette, fonts, margins, heading shape, cover layout). For a different look, don't fork the plugin: copy `styles.typ` into your overlay's `bases/`, edit it there, and point your templates at it with `base_file:`.

## Ecosystem toolkit

For jobs the six document templates don't cover — slides, structural
diagrams, scientific plots, formal letters/CVs/invoices, programmatic
rendering — the plugin bundles a curated reference of Typst ecosystem
libraries in [`shared/ecosystem.md`](shared/ecosystem.md):

- **polylux / touying** — presentation slides
- **fletcher** — vector diagrams (nodes, arrows, commutative diagrams)
- **lilaq** — scientific plotting inside Typst
- **typst/templates** — official letter / CV / invoice / paper gallery
- **typst-py** — Python bindings for programmatic rendering

The `use-toolkit` skill picks the right library for a described need and
wires it into the current document.

## Related

- `tech-comms-diagrams` plugin pairs well with these templates for illustrated/organic technical diagrams (vs. fletcher's exact structural ones).

## License

MIT — see `LICENSE`.
