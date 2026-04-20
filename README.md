# Typst Document Generator

Opinionated Typst document templates, packaged as a Claude Code plugin.

## What this plugin is

A thin rendering layer over Typst that:

- Ships a shared visual style (IBM Plex Sans, teal-700 accents, amber confidentiality markers) in `shared/styles.typ`.
- Ships five **seed templates** covering common document kinds — personal, public, business-general, client-confidential, personal-confidential.
- On first run, an `onboard` skill interviews you for identity (name, email, personal site) and optional business context (name, site, logo), then seeds your personal template library under `~/.claude/plugins-data/typst-document-generator/`.
- Each generator skill is a thin renderer that reads your profile + template YAML and emits a `.typ` file + compiled PDF.

**The plugin itself contains no personal data.** Everything is resolved at render time from your local data store.

## The five seed templates

| Template | Use for | Header | Footer |
|---|---|---|---|
| `personal-doc` | Unpublished notes, writeups | Page number | Page · By: {name} · date |
| `public-doc` | Publications, open writeups | Page number | Page · By · date · {site} · License |
| `business-doc` | General business documents | Business logo + page number | Page · By · date · {business site} |
| `client-confidential` | Client deliverables | **CONFIDENTIAL — {client}** (bold) + page number | Page · By · date · {business site} · Confidential — {client} |
| `personal-confidential` | Private personal docs (finance, health, legal) | **PRIVILEGED & CONFIDENTIAL** (bold) + page number | Page · By: {name} · date |

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

## Customising the visual style

`shared/styles.typ` is the only file that meaningfully encodes the visual style (palette, fonts, margins, heading shape, cover layout). Fork and edit that one file if you want a different look — templates don't need to change.

## Related

- `nano-tech-diagrams` MCP (NanoBanana 2 via Fal) pairs well with these templates for technical diagrams.

## License

MIT — see `LICENSE`.
