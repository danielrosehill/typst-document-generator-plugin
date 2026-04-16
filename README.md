# Typst Document Generator

Opinionated Typst document templates, packaged as a Claude Code plugin.

## A note on intended audience

**This plugin is made public for my own installation convenience.** It encodes a set of document conventions — typography, header/footer formatting, confidentiality markers, brand elements — that are specific to how I (Daniel Rosehill) like my documents to look. It will probably not be directly useful to anyone else.

You are welcome to fork it, strip out the personal bits (author name, site links, DSR Holdings branding), and adapt it to your own conventions. The `shared/styles.typ` module is the only file that meaningfully encodes the visual style — everything else is glue.

## What it does

Five skills for generating Typst documents, each producing a `.typ` file (and on request, a compiled PDF) with a pre-configured header, footer, table of contents, and cover page:

| Skill | Use for | Header | Footer |
|---|---|---|---|
| `personal-doc` | My own unpublished notes, writeups | Page number | Page · By: Daniel Rosehill · dd-mm-yy |
| `public-doc` | Publications, open writeups | Page number | Page · By · date · danielrosehill.com · License |
| `dsr-business-doc` | DSR Holdings general business docs | DSR logo + page number | Page · By · date · dsrholdings.cloud |
| `dsr-client-confidential` | DSR Holdings client deliverables | **CONFIDENTIAL — Client** (bold) + page number | Page · By · date · dsrholdings.cloud · Confidential — Client |
| `personal-confidential` | My own private docs (finance, health, legal) | **PRIVILEGED & CONFIDENTIAL** (bold) + page number | Page · By: Daniel Rosehill · dd-mm-yy |

All five skills share:

- **IBM Plex Sans** body, **IBM Plex Serif** display, **IBM Plex Mono** code
- A teal-700 heading accent on a slate-800 body, with warm amber highlights for confidentiality markers
- Simple chapter-level TOC (depth 1 by default — no deep nesting)
- Page breaks on every chapter (`=` heading)
- Proper Typst tables for tabular data
- Optional **AI-assistance disclosure** — a named block specifying the tool used and the AI/human work division, placed either inline on the cover or in the footer

## Installation

```bash
/plugin install typst-document-generator@danielrosehill
```

Prerequisite: [Typst](https://typst.app/) v0.13 or later installed locally (`/usr/local/bin/typst` or on PATH). The skills assume Typst is already installed and will not check or install it.

## Usage

Each skill is self-contained. Once the plugin is installed, ask Claude something like:

- "Create a personal doc about X"
- "Start a public writeup on Y, MIT licensed"
- "Write a DSR client confidential report for client Acme about Z"

Claude picks the right skill based on the description. The skill then asks for a title, output path, and any template-specific parameters (e.g. client name for `dsr-client-confidential`), copies the shared styles module next to the new `.typ` file, writes it, and compiles to PDF.

## Customising for your own use

If you fork this:

1. Edit `shared/styles.typ` — change the palette, fonts, margins, and heading styles to your taste.
2. Edit each skill's `SKILL.md` — swap out "Daniel Rosehill", "danielrosehill.com", "DSR Holdings", and "dsrholdings.cloud" for your own identity/brand.
3. If you don't run a business, delete the two `dsr-*` skills.
4. Replace the DSR Holdings logo path reference in `dsr-business-doc` with your own asset.

## Related

- The `nano-tech-diagrams` MCP server (NanoBanana 2 via Fal) pairs well with these templates for generating technical diagrams — referenced in each skill's style reminders.

## License

MIT — see `LICENSE`.
