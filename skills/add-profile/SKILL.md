---
name: add-profile
description: Promote a one-off Typst document into a reusable named profile in this plugin — generalise the styling into shared/styles.typ, write the seed template YAML and generator skill, verify by rendering, and record any Typst traps hit along the way. Use when a PDF came out well and the user wants that look reusable ("save this as a profile", "I want to reuse this style", "add this to my Typst templates"), or when auditing which profiles already exist before building a new one.
---

# Add a Typst profile

A profile is a **named look that survives the document that produced it**. The
trigger is nearly always the same: a one-off `.typ` came out well, and the
styling is about to be lost inside a project repo where nothing will find it
again.

The job is to separate the furniture from the subject, and file the furniture.

## First: check it doesn't already exist

Profiles are easy to build twice. Before writing anything:

1. List `${CLAUDE_PLUGIN_ROOT}/seeds/templates/*.yaml` and read the `label` and
   `description` of each.
2. Read the profile table in the plugin README.
3. Grep the user's repos for other Typst collections that might already own this
   look — `dsr-holdings/dsrholdings-typst-templates` is a separate,
   business-branded collection, and `israel/Hebrew-Letter-Typst-Profile` owns
   official Hebrew letters. Neither should absorb a personal profile, and this
   plugin should not absorb theirs.

If something close already exists, say so and propose **extending it with a
parameter** rather than adding a near-duplicate. Two profiles that differ only
by an accent colour is a failure mode, not a library.

## Where each piece goes

This plugin keeps personal data out of the repo entirely. A profile is four
edits, and only the first is real work:

| Piece | Path | What it holds |
| --- | --- | --- |
| Style | `shared/styles.typ` | The look. A `<name>-base` wrapper plus its block helpers. |
| Template | `seeds/templates/<name>.yaml` | Header/footer/cover shape, `variables:` prompts, guidance notes. |
| Skill | `skills/<name>/SKILL.md` | The thin renderer that collects values and emits the `.typ`. |
| Registration | `README.md` | The profile table, so it is choosable. |

**Never put a name, address, price or client into any of them.** The plugin
ships zero personal data; everything resolves at render time from
`~/.claude/plugins-data/typst-document-generator/`.

### Reuse the base if you can

Most new profiles are a variation on `doc-base` and need no new style code —
just a new YAML with different header/footer/cover values. Only write a new
`<name>-base` when the *page architecture* genuinely differs: a different cover
concept, a watermark, a body built from something other than headings and
paragraphs. `briefing-base` earned its own wrapper; a "personal-doc but green"
would not.

Add a `base: <name>-base` key to the YAML when it is not `doc-base`, so the
renderer knows which wrapper to import.

## What is furniture and what is subject

Split the source document in two:

**Furniture — goes in the profile.** Page geometry and margins. Type stack and
sizes. Colour constants. Header, footer, page counter. Cover layout. Watermarks
and markings. Reusable block helpers: checklist items, callouts, panels, badges,
section headings.

**Subject — stays behind, or becomes the example.** Prices, addresses, phone
numbers, dates, names, quantities. Anything that would be wrong in the next
document.

The test for each helper: *would the next document of this kind want it?* A
`stop()` helper for numbered destinations passes — any trip plan wants one. A
hardcoded `"Carhartt subtotal ≈ $342"` does not.

Everything that survives becomes a **named argument with a sensible default**,
not a constant to be edited in place. A profile that must be edited to be used
is a template, and templates rot.

Reuse the existing `palette` from `shared/styles.typ` wherever the new profile
needs a body colour, a muted tone, a rule or a marking. Introduce a new palette
dictionary only for genuinely new furniture — a cover field colour has no
equivalent in `palette`, so `briefing-palette` is justified.

## Verify by rendering, not by compiling

A profile that compiles can still be visually broken. Always:

```bash
cp shared/styles.typ /tmp/ptest/ && cd /tmp/ptest
typst compile --root . test.typ test.pdf
pdftoppm -png -r 60 test.pdf page
```

Then **actually read the PNGs**. Things that compile clean and look wrong:
watermarks wrapped to two lines, weak spacing silently collapsed, a cover
metadata strip overlapping its rule, a footer grid whose centre cell pushes the
page number off the margin.

Write the test document to exercise *every* helper the profile exports. That
makes it double as the regression test for the next change.

## Record the traps

Typst fails in ways that point at the wrong line. Anything that cost time goes
into the profile's own comments at the point of use, and — if it is general —
into the plugin README. Known traps, all verified against **Typst 0.14.2**:

- **`v` and `h` shadow the spacing functions.** Binding either, especially by
  destructuring a `(key, value)` pair, breaks `v(3pt)` for the rest of the
  scope. The error reads `expected function, found string` and points at the
  spacing call rather than at the binding.
- **Rotated text is laid out at the container width before rotation.** A
  watermark's size ceiling comes from the page width, not the diagonal, so a
  long marking wraps to two lines well before it looks too big.
- **Weak spacing collapses at a line boundary** — `v(2pt, weak: true)` straight
  after a `linebreak()` is silently dropped.
- **Markup `#if` bodies carry their surrounding whitespace** into the output.
- **A cover needing its own fill must be a separate `page()` call**, not part of
  the `set page` flow. Reset the counter afterwards so body numbering starts
  at 1.

## Finish

Bump the `version` in `.claude-plugin/plugin.json`, commit, and push. This repo
is **private** and listed in the private marketplace
(`Claude-Code-Plugins-Private`) — keep it that way; it encodes personal document
conventions.

Then tell the user the one thing they have to remember:

```
/typst-document-generator:<name>
```

Leave the originating document alone. It already works, and rewriting it through
the new profile risks changing a PDF they may have already printed. Offer that
as a follow-up rather than doing it unasked.
