# Typst Document Generator: public plugin, private overlay

The plugin is public and generic. Everything that's yours (your name, your
business and logo, your own formats, your own instructions for them) lives in a
**private overlay directory** outside the plugin. Skills read both layers at
render time, and the overlay wins. You never fork the plugin or keep a parallel
private copy of it.

| Layer | Where | Holds | Lifecycle |
| --- | --- | --- | --- |
| **Built-in** | the plugin (`${CLAUDE_PLUGIN_ROOT}`) | generic Typst bases (`shared/*.typ`), generic seed templates (`seeds/templates/*.yaml`), skills | Replaced on every plugin update. Public. |
| **Overlay** | the data dir (below) | `profile.yaml`, your templates, your Typst bases, logos | Survives updates. Yours. Can be a private git repo. |

## Where the data dir is

Run `${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh` and don't guess. It prints the
directory and the rule that picked it:

1. `$TYPST_DOCGEN_HOME`, an explicit override (point it at any folder, such as a clone of a private repo).
2. `$CLAUDE_USER_DATA/typst-document-generator`.
3. `~/.claude-user-data/typst-document-generator`, if `~/.claude-user-data` exists.
4. `${XDG_DATA_HOME:-~/.local/share}/claude-plugins/typst-document-generator`, if that root exists.
5. `~/.claude-user-data/typst-document-generator`, the default.

Up to 0.5.0 the data lived in `~/.claude/plugins-data/typst-document-generator/`.
`paths.sh` reports that location if it finds it, and `onboard` offers to move it.
User data doesn't belong under `~/.claude`, which is the agent's own state.

```
<data dir>/
├── profile.yaml          # identity, business, defaults
├── templates/            # your templates; same name as a built-in = override
│   ├── acme-proposal.yaml
│   └── briefing.yaml     # e.g. your tweaked copy of the built-in
├── bases/                # your own Typst wrappers (a house style), optional
│   └── acme.typ
└── assets/               # logos, signatures, reference images
```

The plugin ships **zero personal data**. `onboard` writes `profile.yaml`;
`add-profile` writes templates and bases.

## Lookup rules

- **Templates:** `paths.sh templates` lists every template, with the overlay
  first. A user template with the same file name as a built-in replaces it.
  `paths.sh template <name>` gives the one that wins.
- **Bases:** a template's `base_file:` names a `.typ` file. Look it up in
  `<data dir>/bases/` first, then `${CLAUDE_PLUGIN_ROOT}/shared/`. `paths.sh bases`
  lists both.
- **Built-in templates aren't copied** into the overlay at onboarding. They're
  read from the plugin, so they pick up fixes on update. Copy one into
  `templates/` only to change it.

## Keeping the overlay private and synced

The overlay is a plain folder of YAML, Typst and images, readable without the
agent. To version it or share it across machines, make it a git repo (or a
folder in an existing private user-data repo), or point `$TYPST_DOCGEN_HOME` at
a clone. The plugin never commits or pushes it.

## profile.yaml: schema

```yaml
author:
  name: "Full Name"
  email: "you@example.com"
  personal_site: "example.com"       # no protocol
  public_email: "public@example.com" # optional

date_format: "dd-mm-yy"              # only dd-mm-yy supported today

business:                            # null for personal-only use
  name: "Company Name"
  site: "company.com"
  logo_path: "assets/logo.png"       # relative to the data dir, or absolute / ~/

default_license: "MIT"
default_output_dir: null             # null = ask each time
captured_at: "YYYY-MM-DD"
```

## templates/<name>.yaml: schema

```yaml
name: kebab-case-identifier          # must match filename stem
label: "Human-Readable Label"
description: "One line. The render skill shows it when listing templates."
triggers: ["acme proposal", "proposal for a client"]  # optional phrases that pick this template

base: doc-base | briefing-base | screenplay | <function in base_file>
base_file: styles.typ                # optional; default styles.typ (screenplay → screenplay.typ)

requires:
  business: false                    # true = profile.business must be set

header:
  left: null | "string with {tokens}"
  bold: false
  logo: false                        # true = inject profile.business.logo_path
  logo_width: "2.4cm"                # optional

footer:
  extra_lines:                       # segments appended after the default footer
    - { type: "text", text: "..." }
    - { type: "link", url: "...", text: "..." }

cover:
  show_confidentiality_block: false
  confidentiality_text: "..."        # required if show_confidentiality_block

ai_disclosure:
  default_placement: "inline" | "footer"

variables:                           # per-template prompts (resolved into tokens)
  client:
    prompt: "Client name"
    required: true
    default: "..."                   # optional; may reference {profile.*}

notes: |
  Instructions the render skill follows for this template: tone, structure,
  sections to include, filename convention, what to ask for. This is how a
  private template carries its own workflow without needing its own skill.
```

## Token resolution

When a template references `{author.name}`, `{business.site}`, `{license}`,
`{client}` and so on, resolve in this order:

1. Per-invocation variable answers (from `variables:` prompts).
2. `profile.*` lookups.
3. Literal passthrough if unresolved (and warn).

## Rendering contract

Every rendering skill, including `render` for user-defined templates, follows this:

1. Run `paths.sh`. If `profile: missing` and the template uses `{author.*}`
   or `{business.*}` tokens → tell the user to run `/typst-document-generator:onboard`.
2. Load the template from `paths.sh template <name>`.
3. If `requires.business` is true and the profile has no business → stop, explain.
4. Follow the template's `notes:` and collect its `variables:`.
5. Resolve tokens into `<base>.with(...)` keyword args.
6. Copy the base file (overlay `bases/` first, then plugin `shared/`) and any
   logo next to the output `.typ`, using local file names so the output folder
   is portable.
7. Write the `.typ`, compile with `typst compile`, render a preview with
   `pdftoppm` and look at it, then report the PDF path.

## Plugin install dir

From a skill, the plugin root is `${CLAUDE_PLUGIN_ROOT}`. If that isn't set,
find `scripts/paths.sh` relative to the SKILL.md being run.
