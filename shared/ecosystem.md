# Typst Ecosystem Toolkit

Curated reference of Typst libraries that extend this plugin beyond plain
document typesetting. The plugin's core templates cover **documents**; the
libraries below cover **slides, diagrams, plots, and programmatic rendering**.

When any of these is a good fit, the `use-toolkit` skill wires the import,
minimal example, and install step into the user's current work.

---

## polylux — presentation slides

- **Repo**: <https://github.com/polylux-typ/polylux>
- **Purpose**: Slide authoring with `#slide[...]` blocks, themes, speaker
  notes, handouts, overlays. Mature and stable.
- **Reach for it when**: the user wants a slide deck in Typst and has no
  preference, or wants the longer-established option.
- **Install**: published on Typst Universe.

  ```typst
  #import "@preview/polylux:0.4.0": *
  ```

- **Minimal example**:

  ```typst
  #import "@preview/polylux:0.4.0": *

  #set page(paper: "presentation-16-9")
  #set text(size: 25pt)

  #slide[
    = Title slide
    Subtitle, author, date.
  ]

  #slide[
    == Body slide
    - Point one
    - Point two
  ]
  ```

- **Notes**: does **not** share this plugin's header/footer `doc-base`. If the
  user wants corporate slide styling, they'll need a polylux theme or a
  custom slide master.

---

## touying — presentation slides (modern)

- **Repo**: <https://github.com/touying-typ/touying>
- **Purpose**: Slide authoring with a richer theming system, dynamic slides
  (incremental reveals), and a library of themes (university, dewdrop,
  simple, metropolis-like, etc.).
- **Reach for it when**: the user wants slides *and* cares about themes,
  animations/reveals, or is comparing to LaTeX Beamer. More actively
  developed than polylux.
- **Install**:

  ```typst
  #import "@preview/touying:0.6.1": *
  #import "@preview/touying-simpl-hkustgz:0.1.1" as themes
  ```

- **Minimal example**:

  ```typst
  #import "@preview/touying:0.6.1": *
  #import themes.university: *

  #show: university-theme.with(
    aspect-ratio: "16-9",
    config-info(
      title: [My Talk],
      author: [Author],
      date: datetime.today(),
    ),
  )

  #title-slide()

  == Introduction
  - First bullet
  - #pause Second bullet appears on click
  ```

- **Choosing between polylux and touying**: polylux is simpler and stable;
  touying is more featureful and the current community centre of gravity for
  new decks. Default recommend: **touying** unless the user already knows
  polylux.

---

## fletcher — diagrams, graphs, commutative diagrams

- **Repo**: <https://github.com/Jollywatt/typst-fletcher>
- **Purpose**: Node-and-arrow diagrams — commutative diagrams (category
  theory), state machines, flowcharts, mind maps. Grid-based placement,
  curved/straight arrows, labels.
- **Reach for it when**: the user needs a precise vector diagram in the
  document itself (not a raster image). Much better than `tech-comms-diagrams`
  for anything structural where exactness matters.
- **Install**:

  ```typst
  #import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  ```

- **Minimal example**:

  ```typst
  #import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

  #diagram(
    node-stroke: 1pt,
    node((0,0), [Start], shape: circle),
    node((1,0), [Middle]),
    node((2,0), [End], shape: circle),
    edge((0,0), (1,0), "->"),
    edge((1,0), (2,0), "->"),
  )
  ```

- **Notes**: diagrams render inline in the compiled PDF. Great for
  academic-style documents. For more organic, illustrated diagrams, stick
  with `tech-comms-diagrams`.

---

## lilaq — scientific plotting

- **Repo**: <https://github.com/lilaq-project/lilaq>
- **Purpose**: Native Typst plotting — scatter, line, bar, histogram, log
  scales, subplots. Matplotlib-like API inside Typst.
- **Reach for it when**: the user wants charts embedded in a Typst doc
  without leaving the Typst toolchain (no Python, no exported PNG). For
  scientific/technical reports.
- **Install**:

  ```typst
  #import "@preview/lilaq:0.4.0" as lq
  ```

- **Minimal example**:

  ```typst
  #import "@preview/lilaq:0.4.0" as lq

  #lq.diagram(
    lq.plot(
      (1, 2, 3, 4, 5),
      (1, 4, 9, 16, 25),
      label: [$x^2$],
    ),
    xlabel: [x],
    ylabel: [y],
  )
  ```

- **Notes**: for interactive or very large datasets, still use matplotlib /
  plotly and embed as image. Lilaq shines for <10k-point static scientific
  figures.

---

## typst/templates — official template gallery

- **Repo**: <https://github.com/typst/templates>
- **Purpose**: Official collection of starter templates — letters, CVs,
  invoices, academic papers, slides. Useful as a reference library.
- **Reach for it when**: the user wants a one-off doc in a style this
  plugin's six seeds don't cover (e.g. formal letter, invoice, IEEE-style
  paper) and doesn't want to build from scratch.
- **Install**: templates are typically imported from Typst Universe
  (`@preview/<template-name>`) or can be copied from the repo directly.
- **Workflow**: browse the repo list, pick one, copy its `.typ` into a new
  folder, adapt. Not consumed by the `use-toolkit` skill as an import; it's a
  **reference for seeding new template YAMLs** in the user's data store.
- **Notes**: when you find a template worth keeping, consider capturing it
  as a new YAML in `templates/` in the user's overlay (`scripts/paths.sh dir`)
  so it's discoverable via the plugin's generator skills.

---

## typst-py — Python bindings

- **Repo**: <https://github.com/messense/typst-py>
- **Purpose**: Call the Typst compiler from Python. Render `.typ` → PDF or
  PNG, pass in variables, integrate into pipelines.
- **Reach for it when**: the user wants to generate documents
  programmatically — batch reports, templated invoices, CI-generated PDFs,
  data-driven documents where the content comes from a Python script or
  notebook.
- **Install**:

  ```bash
  pip install typst
  ```

- **Minimal example**:

  ```python
  import typst

  # Compile to PDF bytes
  pdf_bytes = typst.compile("doc.typ")
  with open("doc.pdf", "wb") as f:
      f.write(pdf_bytes)

  # Or compile directly to file
  typst.compile("doc.typ", output="doc.pdf")
  ```

- **Notes**: pairs well with Jinja2 or string templating for passing
  per-render variables. For high-volume production, spin up the Typst
  process once and reuse — cold-start is noticeable.

---

## Quick picker

| Need | Library |
|---|---|
| Slide deck, simple | polylux |
| Slide deck, themed/animated | touying |
| Vector diagram (nodes, arrows, structure) | fletcher |
| Scientific chart (scatter, line, bar) | lilaq |
| Organic / illustrated diagram | tech-comms-diagrams plugin (outside Typst) |
| Formal letter / CV / invoice / paper | typst/templates |
| Batch / programmatic rendering | typst-py |

---

## Adding a library to a document

All `@preview/…` libraries resolve automatically via Typst's package manager
on first compile — no separate install step, just the `#import` line.

The `use-toolkit` skill handles the boilerplate.
