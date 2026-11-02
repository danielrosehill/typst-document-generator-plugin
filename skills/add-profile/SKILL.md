---
name: add-profile
description: Promote a one-off Typst document into a reusable named format. By default it goes into the user's private overlay (their own template YAML, and a Typst base if the look needs one), so personal and business formats never enter the public plugin. Only a generic look the user wants to share becomes a built-in. Verifies by rendering and records any Typst traps hit along the way. Use when a PDF came out well and the user wants that look reusable ("save this as a profile", "I want to reuse this style", "add this to my Typst templates"), or when auditing which profiles already exist before building a new one.
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
3. List the user's overlay: `"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh" templates`
   and `paths.sh bases`. Their own formats live there.

If something close already exists, say so and propose **extending it with a
parameter** rather than adding a near-duplicate. Two profiles that differ only
by an accent colour is a failure mode, not a library.

## Decide the layer first

Ask one question: **is this look generic, or is it the user's?**

- **The user's (the default):** anything carrying their name, business, logo,
  client, colours they consider their brand, or a workflow only they use. It
  goes in the **overlay**, `<data dir>` from `paths.sh dir`. The plugin isn't
  touched, and no skill is written: the template's `notes:` carries its
  instructions, and `/typst-document-generator:render` (or its `triggers:`)
  picks it up.
- **Generic, and the user wants to contribute it:** a layout anyone could use
  with their own profile (a meeting-minutes layout, an invoice skeleton). It
  goes in the **plugin** as a built-in. This changes a public repo, so confirm first.

| Piece | Overlay (private, default) | Plugin (public built-in) |
| --- | --- | --- |
| Look | `<data dir>/bases/<name>.typ`, only if `doc-base`/`briefing-base` can't express it | a `<name>-base` in `shared/styles.typ`, or its own `shared/<name>.typ` |
| Template | `<data dir>/templates/<name>.yaml` with `base_file:`, `notes:`, `triggers:` | `seeds/templates/<name>.yaml` |
| Skill | none: `render` covers it | `skills/<name>/SKILL.md`, a thin renderer |
| Registration | nothing | the README profile table |

**A built-in never contains a name, address, price, client, logo or brand
colour.** Those resolve at render time from the overlay.

A user base file should `#import` nothing from the plugin by relative path,
because the plugin's install path changes on update. Make it self-contained, or
copy the plugin's `styles.typ` into `bases/` and extend that copy.

### Reuse the base if you can

Most new profiles are a variation on `doc-base` and need no new style code —
just a new YAML with different header/footer/cover values. Only write a new
`<name>-base` when the *page architecture* genuinely differs: a different cover
concept, a watermark, a body built from something other than headings and
paragraphs. `briefing-base` earned its own wrapper; a "personal-doc but green"
would not.

Set `base: <name>-base` (and `base_file:` when it isn't `styles.typ`) in the
YAML when it isn't `doc-base`, so the renderer knows what to import.

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
cp <base file> /tmp/ptest/ && cd /tmp/ptest
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

**Overlay:** write the files and render the test. If the data dir is a git repo,
commit just that folder (stage it explicitly; it may live inside a larger
user-data repo). Don't push unless that's the user's habit for the repo.

**Built-in:** bump `version` in `.claude-plugin/plugin.json`, then commit and
push. The plugin is public: check the diff for personal data before committing.

Then tell the user how to use it:

```
/typst-document-generator:render <name>       # overlay template
/typst-document-generator:<name>              # built-in with its own skill
```

Leave the originating document alone. It already works, and rewriting it through
the new profile risks changing a PDF they may have already printed. Offer that
as a follow-up rather than doing it unasked.
