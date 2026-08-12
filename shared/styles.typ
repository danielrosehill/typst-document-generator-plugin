// =============================================================================
// Shared Typst styling for the typst-document-generator plugin
//
// Typography : IBM Plex Sans (body + headings via weight) + IBM Plex Mono (code)
//              If IBM Plex Serif is installed, override `heading-font` below.
// Philosophy : readable, professional, slightly creative
// Palette    : dark slate body, muted teal accents, soft warm rule lines
// =============================================================================

#let heading-font = "IBM Plex Sans"  // change to "IBM Plex Serif" if installed

#let palette = (
  text:    rgb("#1F2937"),  // slate-800 — body
  heading: rgb("#0F766E"),  // teal-700 — primary accent
  muted:   rgb("#6B7280"),  // gray-500 — headers / footers
  rule:    rgb("#E5E7EB"),  // gray-200 — hair rules
  highlight: rgb("#B45309"), // amber-700 — CONFIDENTIAL / PRIVILEGED badges
  link:    rgb("#0369A1"),  // sky-700 — hyperlinks
)

// Format date as dd-mm-yy (Daniel's preference)
#let format-date(d) = d.display("[day]-[month]-[year repr:last_two]")

// -------------------------------------------------------------------------
// Core document wrapper. Each template calls this with its own header/footer
// content and then emits its body.
// -------------------------------------------------------------------------
#let doc-base(
  title: none,
  subtitle: none,
  author: "Daniel Rosehill",
  date: datetime.today(),
  header-left: none,                 // optional string/content for top-left (e.g. "CONFIDENTIAL")
  header-bold: false,                 // render header-left in bold
  footer-lines: (),                   // list of content blocks — joined with " · "
  logo-path: none,                    // path to a header logo image (optional)
  logo-width: 2.2cm,
  ai-disclosure: none,                // optional content — see ai-disclosure-block()
  ai-disclosure-in-footer: false,     // when true, render disclosure in footer
  show-toc: true,
  toc-depth: 1,                       // 1 = chapters only (Daniel's default)
  body,
) = {
  // --- Page setup -------------------------------------------------------
  set page(
    paper: "a4",
    margin: (top: 3.2cm, bottom: 3cm, x: 2.5cm),
    header: context {
      set text(size: 9pt, fill: palette.muted)
      let page-num = counter(page).display()
      grid(
        columns: (1fr, auto),
        align: (left, right),
        [
          #if logo-path != none {
            image(logo-path, width: logo-width)
          } else if header-left != none {
            if header-bold {
              text(weight: "bold", fill: palette.highlight, header-left)
            } else {
              text(header-left)
            }
          }
        ],
        [Page #page-num],
      )
      v(-0.3em)
      line(length: 100%, stroke: 0.4pt + palette.rule)
    },
    footer: context {
      set text(size: 8.5pt, fill: palette.muted)
      line(length: 100%, stroke: 0.4pt + palette.rule)
      v(0.2em)
      let page-num = counter(page).display()
      let default-line = [Page #page-num · By: #author · #format-date(date)]
      let extras = footer-lines.map(l => [#l]).join([ · ])
      let combined = if footer-lines.len() > 0 {
        [#default-line · #extras]
      } else {
        default-line
      }
      combined
      if ai-disclosure-in-footer and ai-disclosure != none {
        v(0.3em)
        set text(size: 8pt, style: "italic", fill: palette.muted)
        ai-disclosure
      }
    },
  )

  // --- Typography -------------------------------------------------------
  set text(
    font: "IBM Plex Sans",
    size: 10.5pt,
    fill: palette.text,
  )
  set par(justify: true, leading: 0.7em, first-line-indent: 0pt)

  show heading: set text(font: heading-font, fill: palette.heading)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: 0pt, below: 1.2em)[
      #set text(size: 22pt, weight: "semibold")
      #it.body
    ]
  }
  show heading.where(level: 2): set text(size: 14pt, weight: "semibold")
  show heading.where(level: 3): set text(size: 12pt, weight: "medium")

  show link: set text(fill: palette.link)
  show raw: set text(font: "IBM Plex Mono", size: 9.5pt)

  // Tables — clean, readable, slightly creative banding
  set table(
    stroke: 0.5pt + palette.rule,
    inset: 6pt,
  )
  show table.cell.where(y: 0): strong

  // --- Cover block ------------------------------------------------------
  if title != none {
    v(3cm)
    align(left)[
      #text(font: heading-font, size: 30pt, weight: "bold", fill: palette.heading, title)
    ]
    if subtitle != none {
      v(0.4em)
      align(left)[
        #text(size: 14pt, fill: palette.muted, style: "italic", subtitle)
      ]
    }
    v(1.2em)
    line(length: 40%, stroke: 1pt + palette.heading)
    v(0.6em)
    text(size: 10pt, fill: palette.muted)[
      #author · #format-date(date)
    ]
  }

  // --- AI disclosure (inline version) ----------------------------------
  if ai-disclosure != none and not ai-disclosure-in-footer {
    v(2em)
    block(
      fill: rgb("#FEF3C7"),   // amber-100
      stroke: 0.5pt + palette.highlight,
      inset: 10pt,
      radius: 3pt,
      width: 100%,
    )[
      #set text(size: 9pt, fill: palette.text)
      #text(weight: "semibold", fill: palette.highlight)[AI-assisted document] \
      #ai-disclosure
    ]
  }

  // --- Table of contents -----------------------------------------------
  if show-toc {
    pagebreak()
    outline(title: [Contents], depth: toc-depth, indent: auto)
  }

  // --- Body -------------------------------------------------------------
  pagebreak()
  body
}

// -------------------------------------------------------------------------
// Helper: build an AI-disclosure content block.
//   tool  : "Claude Opus 4.6", "GPT-5", etc
//   role  : "drafted initial structure; human-edited"
//   human : optional extra line describing human work division
// -------------------------------------------------------------------------
#let ai-disclosure-block(tool: none, role: none, human: none) = {
  let parts = ()
  if tool != none { parts.push([Tool: #tool]) }
  if role != none { parts.push([AI role: #role]) }
  if human != none { parts.push([Human work: #human]) }
  parts.join([ · ])
}

// =============================================================================
// BRIEFING
//
// A second base wrapper, alongside `doc-base`. Where `doc-base` renders a prose
// report — justified body, chapter page-breaks, TOC — `briefing-base` renders a
// single-subject working document meant to be PRINTED AND CARRIED: shopping
// lists, trip plans, run sheets, field checklists.
//
// What distinguishes it:
//   · full-bleed dark cover with an accent rule and a bottom metadata strip
//   · a rotated classification marking on every page, cover included
//   · checkbox-first body helpers instead of headings and paragraphs
//   · no TOC, no chapter page-breaks, ragged-right body, tighter leading
//
// Extracted 2026-08-13 from the workwear purchasing plan
// (logistics-procurement/Workwear-Purchase-0812), where the styling did its job.
// =============================================================================

#let briefing-palette = (
  deep:  rgb("#131B24"),  // cover field
  ember: rgb("#C8752F"),  // cover accent — default
  wash:  rgb("#F4F6F9"),  // panel fill
  box:   rgb("#9AA5B1"),  // checkbox stroke
)

// --- Watermark ---------------------------------------------------------------
// GOTCHA: Typst lays text out at the container width BEFORE applying rotation,
// so the size ceiling is set by the page width, not by the length of the
// diagonal. At 62pt "NON-CONFIDENTIAL" wraps to two lines on A4 and looks like
// a bug. 44pt is the largest that holds one line for a 16-character marking;
// shorten the marking if you want it bigger.
#let watermark(marking, fill, size: 44pt) = align(center + horizon,
  rotate(-32deg, reflow: false,
    text(size: size, weight: 900, tracking: 3pt, fill: fill)[#marking]))

// --- Body helpers ------------------------------------------------------------

#let checkbox = box(width: 8.5pt, height: 8.5pt, radius: 1.5pt,
  stroke: 0.8pt + briefing-palette.box, baseline: 1pt)

/// A checklist line. `qty: none` renders the box with no multiplier.
#let item(qty, what, note: none, price: none) = block(
  above: 0.45em, below: 0.45em, width: 100%,
  grid(columns: (auto, 1fr, auto), column-gutter: 7pt, align: (left, left, right),
    checkbox,
    [
      #if qty != none [#text(weight: 700)[#qty ×] ]
      #what
      #if note != none [\ #text(size: 8.1pt, fill: palette.muted, style: "italic")[#note]]
    ],
    if price != none { text(size: 8.6pt, fill: palette.muted)[#price] } else { [] },
  ),
)

/// A rule-marked aside for warnings and hard constraints.
#let note-block(body, color: palette.highlight) = block(
  width: 100%, inset: (left: 8pt, y: 5pt), above: 0.7em, below: 0.7em,
  stroke: (left: 2pt + color),
  text(size: 8.4pt)[#body],
)

/// A filled, titled box — totals, packing lists, summaries.
#let panel(title, body) = block(
  width: 100%, inset: 9pt, radius: 4pt,
  fill: briefing-palette.wash, stroke: 0.6pt + palette.rule,
)[
  #text(weight: 700, size: 10pt)[#title]
  #v(3pt)
  #body
]

/// A numbered destination heading: badge, name, address, hours.
#let stop(num, name, addr, hours, phone: none, label: "STOP") = block(
  above: 1.1em, below: 0.8em)[
  #line(length: 100%, stroke: 1.2pt + palette.text)
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 9pt, align: (left + horizon, left),
    box(fill: palette.text, inset: (x: 6pt, y: 3.5pt), radius: 2pt,
      text(fill: white, weight: 700, size: 8.5pt)[#label #num]),
    text(weight: 700, size: 14pt)[#name],
  )
  #v(2pt)
  #text(size: 8.6pt)[
    *#addr*#if phone != none [ · *#phone*] \
    #text(fill: palette.muted)[#hours]
  ]
]

// --- The wrapper -------------------------------------------------------------

#let briefing-base(
  title: none,
  accent-title: none,       // second title line, rendered in the accent colour
  eyebrow: none,            // small tracked line above the title
  subtitle: none,
  marking: "NON-CONFIDENTIAL",
  meta: (),                 // array of (label, value) pairs for the cover strip
  footer-note: none,
  author: none,
  date: datetime.today(),
  accent: briefing-palette.ember,
  paper: "a4",
  cover: true,
  font: "IBM Plex Sans",
  body,
) = {
  set page(
    paper: paper,
    margin: (x: 1.6cm, top: 1.5cm, bottom: 1.6cm),
    background: watermark(marking, palette.highlight.transparentize(88%)),
    footer: context [
      #set text(size: 7.5pt, fill: palette.muted)
      #line(length: 100%, stroke: 0.5pt + palette.rule)
      #v(-3pt)
      #grid(columns: (1fr, auto, 1fr),
        align: (left, center, right),
        [#if footer-note != none { footer-note } else if author != none {
          [By: #author · #format-date(date)]
        }],
        text(fill: palette.highlight, weight: 600)[#marking],
        [#counter(page).display("1 / 1", both: true)],
      )
    ],
  )

  set text(font: font, size: 9.4pt, fill: palette.text, hyphenate: false)
  // Ragged right and tight leading: this is a scanning document, not prose.
  set par(justify: false, leading: 0.58em, spacing: 0.75em)

  // --- Cover ---------------------------------------------------------------
  // A separate `page()` call rather than part of the `set page` flow, because it
  // needs its own fill, zero margin, no footer, and a light-on-dark watermark.
  // The counter is reset afterwards so body page numbering starts at 1.
  if cover {
    page(
      fill: briefing-palette.deep,
      margin: 0pt,
      footer: none,
      background: watermark(marking, white.transparentize(86%)),
    )[
      #set text(fill: white)
      #place(top + left, rect(width: 100%, height: 9pt, fill: accent))

      #block(inset: (x: 2.6cm, top: 5.2cm, bottom: 0pt))[
        #if eyebrow != none [
          #text(size: 10pt, weight: 600, tracking: 3.4pt, fill: accent)[#eyebrow]
          #v(16pt)
        ]
        #if title != none [
          #text(size: 46pt, weight: 900, tracking: -1.6pt)[#title]
        ]
        #if accent-title != none [
          #v(-14pt)
          #text(size: 46pt, weight: 900, tracking: -1.6pt, fill: accent)[#accent-title]
        ]
        #v(10pt)
        #line(length: 5.2cm, stroke: 2.5pt + accent)
        #if subtitle != none [
          #v(14pt)
          #text(size: 12.5pt, fill: white.transparentize(18%))[#subtitle]
        ]
      ]

      #if meta.len() > 0 [
        #place(bottom + left, dx: 2.6cm, dy: -2.4cm, block(width: 15.5cm)[
          #line(length: 100%, stroke: 0.8pt + white.transparentize(72%))
          #v(10pt)
          // GOTCHA: do NOT name this parameter `v` — it shadows the spacing
          // function for the rest of the scope, and the resulting error
          // ("expected function, found string") points at the v() call rather
          // than at the binding. Same trap applies to `h`.
          #let cell(k, val) = [
            #text(size: 7.6pt, weight: 600, tracking: 1.6pt, fill: accent)[#upper(k)] \
            #v(2pt)
            #text(size: 11pt, weight: 700, fill: white)[#val]
          ]
          #grid(columns: meta.map(_ => 1fr), column-gutter: 10pt,
            ..meta.map(((k, val)) => cell(k, val)))
        ])
      ]
    ]
    counter(page).update(1)
  }

  body
}
