// screenplay.typ: spec-screenplay layout for Typst.
//
// Standalone: this file does NOT import styles.typ. A screenplay is a fixed
// industry format (Courier 12, fixed element indents, no branding), not a
// house style.
//
// Layout (US Letter, Courier 12 = 10 chars/inch, 6 lines/inch):
//   margins      left 1.5in, right 1.0in, top 1.0in, bottom 1.0in
//   scene/action from the left margin, 6.0in wide
//   character    3.7in from the page edge (2.2in into the text block)
//   parenthetical 3.1in from the page edge (1.6in in), 2.0in wide
//   dialogue     2.5in from the page edge (1.0in in), 3.5in wide
//   transition   right-aligned to 7.5in
//   page number  top right, 0.5in from the top, "2." form, from script page 2
//
// Every line sits on a 12pt grid (one line = 1/6in), so 1 page ~ 1 minute.
//
// Known limits (by design):
//   - A dialogue block never splits across pages. It moves whole to the next
//     page, so no (MORE)/(CONT'D) is needed. That's fine for readings and drafts.
//     For a submission draft, export to Fountain/FDX and use a dedicated tool.
//   - (CONT'D) for a speaker interrupted by action is written by hand:
//     #dialogue("ANNA", ext: "CONT'D")[...]

#let _in = 1in

// ---- element indents, relative to the 1.5in left margin ----
#let _char-indent = 3.7in - 1.5in
#let _paren-indent = 3.1in - 1.5in
#let _paren-width = 2.0in
#let _dial-indent = 2.5in - 1.5in
#let _dial-width = 3.5in

#let _line = 12pt // one screenplay line

#let _scene-numbers = state("sp-scene-numbers", false)
#let _scene-counter = counter("sp-scene")

// ---- elements ----

/// Scene heading (slugline): INT./EXT. LOCATION - TIME. Uppercased.
/// Pass `number:` to override the automatic scene number.
#let scene(heading, number: auto) = {
  _scene-counter.step()
  block(above: 2 * _line, below: _line, sticky: true, width: 100%, context {
    let show-num = _scene-numbers.get()
    let n = if number == auto { str(_scene-counter.get().first()) } else { str(number) }
    if show-num {
      place(left, dx: -0.75in, n)
      place(right, dx: 0.6in, n)
    }
    upper(heading)
  })
}

/// Action / description. Present tense, full width.
#let action(body) = block(above: _line, below: _line, width: 100%, body)

/// A line of dialogue. `parts` alternates dialogue content and
/// parentheticals made with `paren[...]`.
///   #dialogue("ANNA")[Hello.]
///   #dialogue("ANNA", ext: "V.O.")[Hello.]
///   #dialogue("ANNA", paren[quietly], [Hello.], paren[beat], [Goodbye.])
#let paren(body) = (kind: "paren", body: body)

#let dialogue(name, ext: none, ..parts) = {
  let name-line = upper(name) + if ext != none { " (" + upper(ext) + ")" }
  block(above: _line, below: _line, breakable: false, width: 100%, {
    pad(left: _char-indent, name-line)
    for p in parts.pos() {
      if type(p) == dictionary and p.at("kind", default: none) == "paren" {
        pad(left: _paren-indent, box(width: _paren-width)[(#p.body)])
      } else {
        pad(left: _dial-indent, box(width: _dial-width, p))
      }
    }
  })
}

/// Transition: CUT TO:, DISSOLVE TO:, SMASH CUT TO:. Right-aligned, uppercased.
/// FADE IN: at the very start is conventionally left-aligned: use #action[FADE IN:].
#let transition(body) = block(above: _line, below: _line, width: 100%,
  align(right, upper(body)))

/// Centered text: THE END, title cards, > INTERMISSION <.
#let centered(body) = block(above: _line, below: _line, width: 100%,
  align(center, body))

/// Dual (simultaneous) dialogue: two speakers side by side.
///   #dual(("ANNA", [Stop!]), ("BEN", [Go!]))
/// Each side is (name, body) or (name, body, ext).
#let dual(left-side, right-side) = {
  let col(s) = {
    let ext = if s.len() > 2 { s.at(2) } else { none }
    let nm = upper(s.at(0)) + if ext != none { " (" + upper(ext) + ")" }
    pad(left: 0.9in, nm)
    pad(left: 0.3in, box(width: 2.5in, s.at(1)))
  }
  block(above: _line, below: _line, breakable: false, width: 100%,
    grid(columns: (1fr, 1fr), column-gutter: 0.2in, col(left-side), col(right-side)))
}

// ---- title page ----

#let _title-page(title, credit, author, source, contact, draft) = {
  v(3in)
  align(center, {
    upper(title)
    v(2 * _line)
    credit
    v(_line)
    author
    if source != none {
      v(2 * _line)
      source
    }
  })
  place(bottom + left, contact)
  if draft != none { place(bottom + right, align(right, draft)) }
}

// ---- document wrapper ----

/// #show: screenplay.with(title: "...", author: "...")
#let screenplay(
  title: "UNTITLED",
  author: none,
  credit: "Written by",
  source: none,           // e.g. [Based on the novel by Jane Doe]
  contact: none,          // bottom-left of title page; multi-line content ok
  draft: none,            // bottom-right, e.g. [First Draft \ 2 November 2026]
  paper: "us-letter",     // "us-letter" (industry) or "a4"
  scene-numbers: false,   // true = numbers in both margins (shooting script)
  title-page: true,
  font: ("Courier Prime", "Courier New", "Courier", "Nimbus Mono PS", "Liberation Mono"),
  body,
) = {
  set document(title: title, author: if author != none { author } else { () })
  // A4 keeps the left/top margins and takes the extra height at the bottom.
  set page(
    paper: paper,
    margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in),
    header-ascent: 0.5in - 12pt,
    header: context {
      let p = counter(page).get().first()
      if p > 1 { align(right, str(p) + ".") }
    },
  )
  // Exact 12pt line grid: the line box is 1em tall, so leading is 0.
  set text(font: font, size: 12pt, top-edge: 0.8em, bottom-edge: -0.2em,
    hyphenate: false, lang: "en")
  set par(leading: 0pt, spacing: _line, justify: false)
  set block(spacing: _line)
  _scene-numbers.update(scene-numbers)

  if title-page {
    _title-page(title, credit, author, source, contact, draft)
    // The title page is unnumbered; the first script page becomes page 1.
    counter(page).update(0)
    pagebreak()
  }
  body
}
