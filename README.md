# Typst Document Generator

Opinionated Typst document templates, packaged as a Claude Code plugin.

## What this plugin is

A thin rendering layer over Typst that:

- Ships a shared visual style (IBM Plex Sans, teal-700 accents, amber confidentiality markers) in `shared/styles.typ`.
- Ships six **seed templates** covering common document kinds — personal, public, business-general, client-confidential, personal-confidential, and briefing.
- On first run, an `onboard` skill interviews you for identity (name, email, personal site) and optional business context (name, site, logo), then seeds your personal template library under `~/.claude/plugins-data/typst-document-generator/`.
- Each generator skill is a thin renderer that reads your profile + template YAML and emits a `.typ` file + compiled PDF.

**The plugin itself contains no personal data.** Everything is resolved at render time from your local data store.

## The six seed templates

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
/plugin install typst-document-generator@danielrosehill
```

Prerequisite: [Typst](https://typst.app/) v0.13+ on `PATH`.

After install, run the onboarding skill:

```
/typst-document-generator:onboard
```

This writes your profile and seeds the template library. Without it, the generator skills will refuse to run.

## Data store layout

```
~/.claude/plugins-data/typst-document-generator/
├── profile.yaml             # identity, business, defaults
├── templates/
│   ├── personal-doc.yaml
│   ├── public-doc.yaml
│   ├── <business>-business-doc.yaml
│   ├── <business>-client-confidential.yaml
│   ├── personal-confidential.yaml
│   ├── briefing.yaml
│   └── <your-custom>.yaml
└── assets/                  # logos, images, custom fonts
```

Full schema in [`shared/workspace.md`](shared/workspace.md).

Tokens in templates (`{author.name}`, `{business.site}`, `{client}`, `{license}`, etc.) are resolved at render time from `profile.yaml` plus any per-invocation prompts.

## Usage

Once onboarded, ask Claude:

- "Create a personal doc about X"
- "Start a public writeup on Y, MIT licensed"
- "Write a client-confidential report for client Acme about Z"

Claude picks the right skill, collects any template-specific values (client name, license override, AI disclosure), copies `shared/styles.typ` next to the output, writes the `.typ`, and compiles to PDF.

## Adding your own templates

Either:

- Re-run `/typst-document-generator:onboard` and choose "Add custom template", or
- Hand-write a YAML in `~/.claude/plugins-data/typst-document-generator/templates/` following the schema in `shared/workspace.md`.

## Adding a profile

Run `/typst-document-generator:add-profile`. It handles the four edits a profile
needs — style wrapper, seed YAML, generator skill, README registration — and
checks the profile does not already exist first.

Most new profiles need no new style code: a new YAML with different
header/footer/cover values over the existing `doc-base` is enough. Only write a
new `<name>-base` when the page architecture genuinely differs.

## Customising the visual style

`shared/styles.typ` is the only file that meaningfully encodes the visual style (palette, fonts, margins, heading shape, cover layout). Fork and edit that one file if you want a different look — templates don't need to change.

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

- `nano-tech-diagrams` MCP (NanoBanana 2 via Fal) pairs well with these templates for illustrated/organic technical diagrams (vs. fletcher's exact structural ones).

## License

MIT — see `LICENSE`.
