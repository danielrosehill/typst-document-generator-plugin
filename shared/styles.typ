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
