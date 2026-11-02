---
name: screenplay
description: Typeset a screenplay as a PDF with Typst in standard spec-script format (Courier 12, US Letter, industry margins and element indents, title page, numbered pages). Takes the script in any form (Fountain, plain text, Markdown, a Word/PDF export, a Final Draft .fdx, or prose to adapt), prepares it into scene headings, action, dialogue, parentheticals and transitions, then renders through the bundled `screenplay.typ` skeleton. Use on "format this as a screenplay", "make a script PDF", "turn this into screenplay format", "typeset my Fountain file".
---

# Screenplay

Renders through **`shared/screenplay.typ`**, not `styles.typ`. A screenplay is a
fixed industry format, not a house style: no IBM Plex, no branding, no
header/footer conventions, no AI-assistance line on the page. No profile or
onboarding is needed. If `~/.claude/plugins-data/typst-document-generator/profile.yaml`
exists, offer `author.name` as the default author; otherwise ask.

> **Typst must be installed at a resolvable path (`which typst`). Do not try to install it automatically.**

## What the skeleton fixes (don't override these)

| Element | Position (US Letter, Courier 12) | Helper |
| --- | --- | --- |
| Margins | left 1.5in, right 1.0in, top 1.0in, bottom 1.0in | `screenplay.with(...)` |
| Scene heading | left margin, uppercase, 2 blank lines above, kept with the next block | `#scene[INT. KITCHEN - NIGHT]` |
| Action | left margin, 6.0in wide | `#action[...]` |
| Character name | 3.7in from the page edge, uppercase, extension in brackets | `#dialogue("ANNA", ext: "V.O.")[...]` |
| Parenthetical | 3.1in from the page edge, 2.0in wide | `paren[quietly]` inside `dialogue` |
| Dialogue | 2.5in from the page edge, 3.5in wide | `#dialogue("ANNA")[...]` |
| Transition | right-aligned, uppercase | `#transition[CUT TO:]` |
| Centered | centered | `#centered[THE END]` |
| Dual dialogue | two columns side by side | `#dual(("ANNA", [Stop!]), ("BEN", [Go!]))` |
| Page number | top right, `2.` form, from the second script page; the title page is unnumbered | automatic |

Every line sits on a 12pt grid (6 lines per inch), so one page is roughly one
minute of screen time. Don't change the font size, line height or margins to
make a script fit: that breaks the page-minute rule, and readers spot it.

`screenplay.with` options: `title`, `author`, `credit` (default `"Written by"`),
`source` (e.g. `[Based on the novel by …]`), `contact` (title page, bottom left),
`draft` (title page, bottom right, e.g. `[First Draft \ 2 November 2026]`),
`paper` (`"us-letter"` default, `"a4"`), `scene-numbers` (`false` for a spec
script, `true` for a shooting script), `title-page` (default `true`), `font`.

## Step 1: get the input in

Identify what you were given and pull out plain text:

| Input | How |
| --- | --- |
| Pasted text, `.txt`, `.md`, `.fountain` | Read it directly |
| `.docx`, `.odt`, `.rtf` | `pandoc -t plain --wrap=none in.docx` |
| `.pdf` | `pdftotext -layout in.pdf -`. Keep `-layout`: the indentation tells you which lines are character names and which are dialogue |
| `.fdx` (Final Draft) | XML: each `<Paragraph Type="Scene Heading|Action|Character|Parenthetical|Dialogue|Transition">` maps one-to-one to a helper |
| Prose, a story, notes, a transcript | This is **adaptation**, not conversion (see below) |

Then decide which job this is, and say which in one line before you start:

- **Conversion.** The input is already a script in some layout. Keep every word.
  Your job is only to classify each line as an element. Don't tidy dialogue or
  fix the writer's style.
- **Adaptation.** The input is prose or notes. Writing scenes is creative work.
  Confirm the user wants it, stay inside what the source supports, and don't
  invent plot, characters or lines of dialogue the source doesn't imply. Mark
  any gap you had to bridge with a `// NOTE:` comment in the `.typ` file and
  list the gaps in your report.

## Step 2: classify into elements

Fountain is the most common text form. Its rules are a good classifier for any
plain-text script:

| Line looks like | Element |
| --- | --- |
| Starts `INT.`, `EXT.`, `INT./EXT.`, `I/E`, `EST.` (or Fountain `.FORCED`) | `scene` |
| ALL CAPS on its own line, blank line before, text directly after | `dialogue` name. A trailing `(V.O.)`, `(O.S.)`, `(O.C.)` or `(CONT'D)` goes to `ext:` |
| `(…)` on its own line inside a speech | `paren` |
| Fountain `^` after the second character name | `dual` |
| ALL CAPS ending in `TO:`, or Fountain `> TEXT` | `transition` |
| Fountain `> TEXT <` | `centered` |
| Title-page keys (`Title:`, `Credit:`, `Author:`, `Source:`, `Contact:`, `Draft date:`) | `screenplay.with` options |
| `[[notes]]`, `/* boneyard */` | Drop, or keep as `//` comments |
| `= synopsis`, `# section` | Drop. They're outline aids, not printed |
| Anything else | `action` |

## Step 3: apply the core conventions

When converting, fix only the mechanical items below, and list what you
changed. When adapting, write to all of them:

- Scene headings: `INT.`/`EXT.` + LOCATION + ` - ` + `DAY`/`NIGHT` (or
  `CONTINUOUS`, `LATER`, `MOMENTS LATER`). Go from general to specific:
  `INT. HOSPITAL - CORRIDOR - NIGHT`.
- A character's first appearance in action is in CAPS with an age:
  `MIRIAM (60s)`. After that, normal case.
- Action is in the present tense and active voice. Paragraphs are short, rarely
  more than 4 lines. Show only what the camera can see and the actor can play.
- Character names stay the same throughout. Pick one form (`DR. COHEN`, not
  sometimes `COHEN`).
- `V.O.` is a speaker who isn't in the scene's space (narration, the far end of
  a phone call). `O.S.` is in the space but off-screen. `CONT'D` is the same
  speaker resuming after an action line.
- Parentheticals are a few words, lower case, a verb or a delivery note. Use
  them rarely.
- Spec scripts carry no camera directions (`CLOSE ON`, `WE SEE`, `ANGLE ON`) and
  few transitions. `FADE IN:` opens the script (`#action[FADE IN:]`, left
  aligned) and `FADE OUT.` closes it (`#transition[FADE OUT.]`).

## Step 4: escape for Typst

Script text goes inside content blocks `[...]`, where these characters mean
something. Escape them with a backslash:

| Character | Problem | Write |
| --- | --- | --- |
| `#` `$` `@` `<` `>` `*` `_` `` ` `` `\` | markup or code | `\#` `\$` `\@` `\<` `\>` `\*` `\_` `` \` `` `\\` |
| `[` `]` | close the block early | `\[` `\]` |
| `//` (not part of an `http(s)://` URL, which Typst links automatically) | starts a comment, silently eats the rest of the line | `\/\/` |
| `-` `+` `=` at the start of a line | list, enum, heading | `\-` `\+` `\=` |
| `~` | non-breaking space | `\~` |

`--` becomes an en dash and `---` an em dash. That's fine in action and usually
intended. `...` becomes an ellipsis, and straight quotes become curly ones.
Leave both as they are.

Character names go in as strings (`"ANNA"`), so only `"` and `\` need escaping
there.

## Step 5: build and render

1. Pick the output path. Propose `./{slug}.typ`, or use `profile.default_output_dir` if it's set.
2. Copy `${CLAUDE_PLUGIN_ROOT}/shared/screenplay.typ` next to the output `.typ`.
3. Write the document:

   ```typst
   #import "./screenplay.typ": *

   #show: screenplay.with(
     title: "The Last Bus",
     author: "Jane Doe",
     contact: [Jane Doe \ jane\@example.com],
     draft: [First Draft \ 2 November 2026],
   )

   #action[FADE IN:]

   #scene[EXT. CENTRAL BUS STATION - NIGHT]

   #action[Rain hammers the concrete. MIRIAM (60s) watches the departures board go dark.]

   #dialogue("MIRIAM", paren[to herself], [Of course it's gone.])

   #dialogue("YONI", ext: "O.S.")[Last one to Haifa!]

   #transition[CUT TO:]
   ```

   Use one helper call per element, with a blank line between calls. Don't put
   raw text outside the helpers.
4. Compile: `typst compile {path}.typ`. Warnings like `unknown font family:
   courier prime` are normal: the template lists fallbacks, and Typst warns
   about each one it doesn't find. On a real **error**, show it verbatim and
   stop. Don't retry with guesses.
5. Check the font: `pdffonts {path}.pdf` should show a Courier-metric
   monospace font (Courier Prime, Courier New, Courier, or Nimbus Mono PS). If
   only Liberation Mono or DejaVu was found, the page count won't match a real
   Courier script. Tell the user that Courier Prime is free (SIL OFL, Google
   Fonts) and is the usual choice, but don't install it yourself.
6. **Render and look at it** before you report success:
   ```bash
   pdftoppm -png -r 50 -f 1 -l 3 {path}.pdf /tmp/screenplay-preview
   ```
   Check that character names line up in one column, dialogue sits in its
   narrower column, scene headings aren't stranded at a page bottom, the title
   page is unnumbered, and the first numbered page says `2.`.
7. Report the PDF path, the page count (≈ minutes) and, for a conversion, any
   lines you weren't sure how to classify.

## Known limits

- **Dialogue never splits across pages.** A speech that won't fit moves whole
  to the next page, so the template never needs `(MORE)`/`(CONT'D)` at page
  breaks. That's right for drafts, table reads and sharing. It can leave a
  short page now and then.
- `(CONT'D)` for a speaker interrupted by action isn't automatic. Add it with
  `ext: "CONT'D"`.
- If a production or competition requires `(MORE)`/`(CONT'D)` page breaking or
  an `.fdx` file, Typst isn't the right tool. Say so, and offer the classified
  script as a `.fountain` file for a Fountain tool (afterwriting, screenplain).
