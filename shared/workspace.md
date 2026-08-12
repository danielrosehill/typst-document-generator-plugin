# Typst Document Generator — Data Store

All user-specific data (identity, branding, custom templates, assets) lives
outside this plugin, under:

```
~/.claude/plugins-data/typst-document-generator/
├── profile.yaml                 # identity, business, defaults
├── templates/
│   ├── personal-doc.yaml        # seeded by onboarding
│   ├── public-doc.yaml
│   ├── dsr-business-doc.yaml
│   ├── dsr-client-confidential.yaml
│   ├── personal-confidential.yaml
│   ├── briefing.yaml
│   └── <user-custom>.yaml       # user-defined templates
└── assets/                      # logos, reference images, etc.
```

This plugin ships **zero personal data**. The `onboard` skill populates the
store from an interactive interview.

## profile.yaml — schema

```yaml
author:
  name: "Full Name"
  email: "you@example.com"
  personal_site: "example.com"       # no protocol
  public_email: "public@example.com" # optional

date_format: "dd-mm-yy"              # only dd-mm-yy supported today

business:                            # nullable — personal-only users leave as null
  name: "Company Name"
  site: "company.com"
  logo_path: "/absolute/or/~/path/to/logo.png"

default_license: "MIT"
default_output_dir: null             # null = ask each time
captured_at: "YYYY-MM-DD"
```

## templates/<name>.yaml — schema

```yaml
name: kebab-case-identifier          # must match filename stem
label: "Human-Readable Label"
description: "One-line description for the skill router."
base: doc-base | briefing-base       # optional; defaults to doc-base

requires:
  business: false                    # true = profile.business must be populated

header:
  left: null | "string with {tokens}"
  bold: false
  logo: false                        # true = inject profile.business.logo_path
  logo_width: "2.4cm"                # optional

footer:
  extra_lines:                       # segments appended after default footer
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
    default: "..."                   # optional — may reference {profile.*}

notes: |
  Free-text guidance for the rendering skill (style reminders, default
  filename conventions, etc.).
```

## Token resolution

When a template references `{author.name}`, `{business.site}`, `{license}`,
`{client}`, etc., resolve in this order:

1. Per-invocation variable answers (from `variables:` prompts).
2. `profile.*` lookups.
3. Literal passthrough if unresolved (and warn).

## Rendering contract

All built-in skills (and any future user-defined ones) follow:

1. Load `profile.yaml`. If missing → tell the user to run `/typst-document-generator:onboard`.
2. Load `templates/<template>.yaml`.
3. If `requires.business` is true and profile has no business → stop, explain.
4. Collect any template `variables:` from the user.
5. Resolve tokens into `<base>.with(...)` keyword args, where `<base>` is the
   template's `base:` key (default `doc-base`).
6. Copy `shared/styles.typ` (from the plugin install dir) next to the output
   `.typ` file, plus any logo referenced by the template.
7. Write the `.typ` scaffold, compile with `typst compile`, report PDF path.

## Plugin install dir

Claude Code installs plugins under the marketplace cache. From a skill, the
plugin root is typically:

```
${CLAUDE_PLUGIN_ROOT}
```

If that env var is not set, fall back to searching for `shared/styles.typ`
relative to the SKILL.md being executed.
