---
name: briefing
description: Generate a printable Typst briefing or field sheet using the user's `briefing` template — dark full-bleed cover, a classification marking watermarked on every page, and a checkbox-first body with quantities, prices and addresses. Use for shopping lists, trip plans, run sheets, packing lists, site-visit sheets, or any single-subject document that will be printed and carried rather than read at a desk.
---

# Briefing / Field Sheet Template

Thin renderer — all identity and template shape live in the user's data store.
See `shared/workspace.md` for the full schema.

> **Typst must be installed at a resolvable path (`which typst`). Do not try to install automatically.**

This is the one template that renders through **`briefing-base`**, not
`doc-base`. Everything else in this plugin produces a prose report with a TOC;
this produces a sheet to hold in one hand.

## Preflight

1. Check `~/.claude/plugins-data/typst-document-generator/profile.yaml` exists. If not → tell the user to run `/typst-document-generator:onboard` and stop.
2. Check `~/.claude/plugins-data/typst-document-generator/templates/briefing.yaml` exists. If not → offer to re-seed from `${CLAUDE_PLUGIN_ROOT}/seeds/templates/briefing.yaml`.
3. Load profile + template YAML.

## Workflow

1. Ask for: title, optional second title line (`accent_title`), subtitle, and output path (or propose `./{slug}.typ`, honouring `profile.default_output_dir`).
2. Collect the template `variables:` — `marking` (default `NON-CONFIDENTIAL`), `eyebrow`, and up to four `meta` pairs for the cover strip. All optional; skip the prompt if the user already said it in their request.
3. Ask if AI-assisted. Default placement for this template is `footer` — the cover is already busy.
4. Copy `${CLAUDE_PLUGIN_ROOT}/shared/styles.typ` next to the output `.typ`.
5. Generate the scaffold:

   ```typst
   #import "./styles.typ": briefing-base, item, note-block, panel, stop, palette

   #show: briefing-base.with(
     title: "{TITLE}",
     accent-title: {ACCENT_TITLE OR none},
     eyebrow: {EYEBROW OR none},
     subtitle: [{SUBTITLE}],
     marking: "{MARKING}",
     meta: (("Label", "Value"), ...),
     author: "{author.name}",
   )

   #item("2", [Thing to buy], note: [Why this one.], price: "≈ $45 ea")
   ```

6. Compile: `typst compile {path}.typ`. If it fails, surface the error verbatim and stop — don't retry with guesses.
7. **Render and look at it** before reporting success:
   ```bash
   pdftoppm -png -r 60 {path}.pdf /tmp/preview
   ```
   Read the PNGs. This template fails *visually* far more often than it fails to
   compile — a long marking wraps mid-watermark, a five-item `meta` strip
   crowds, a dense body pushes the totals panel onto a stray third page.
8. Report the PDF path.

## Using the helpers

Reach for the exported helpers rather than hand-rolling equivalents — they are
what keeps briefings looking like each other.

| Helper | For |
| --- | --- |
| `item(qty, what, note: none, price: none)` | A checklist line. `qty: none` gives a plain checkbox with no multiplier. |
| `note-block(body, color: none)` | A rule-marked aside — warnings, constraints, "don't buy two of these". |
| `panel(title, body)` | A filled box for totals, packing notes, summaries. Two side by side in a `grid` works well as a closing block. |
| `stop(num, name, addr, hours, phone: none)` | A numbered destination heading. Pass `label:` to relabel from "STOP" (e.g. `"SITE"`, `"DAY"`). |

## Style reminders

- **No TOC, no `=` chapter headings.** `briefing-base` does not page-break on
  headings. If the document wants a TOC it is the wrong template — offer
  `personal-doc` instead.
- **Keep the marking short.** It is laid out at page width *before* rotation, so
  the ceiling is the page width, not the diagonal. 16 characters at the default
  44pt is the limit; shorten the text rather than shrinking the size.
- **Order sections the way the user will walk them**, not the way they were
  researched. For a multi-stop trip that usually means earliest-closing first.
- Put anything time-critical on the first body page. The cover is for
  identification, not information.
- Prices, hours and addresses are the content most likely to be stale — say in
  the document when they were verified, as an absolute date.

## Printing

The user usually wants this on paper. Offer to send it:

```bash
lp -d {printer} -n {copies} -o media=A4 -o fit-to-page {path}.pdf
```

List printers with `lpstat -p -d` rather than guessing the queue name. The cover
is full-bleed dark: on a non-borderless printer it prints with a white edge, and
on a cartridge inkjet it is worth flagging the ink cost before sending copies.
