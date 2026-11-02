---
name: onboard
description: First-run setup for the typst-document-generator plugin. Interviews the user for identity (name, email, site), optional business context (name, site, logo) and defaults, and writes them to the user's private overlay directory, which also holds their own templates. Moves data from the pre-0.6 location if it finds any, and can make the overlay a private git repo. Use before any other typst-document-generator skill, or on "set up typst templates", "onboard typst", "update my typst profile", "where are my typst templates".
---

# typst-document-generator: onboard

Set up the user's **private overlay**: `profile.yaml` plus folders for their
own templates, Typst bases and assets. The plugin stays generic and public.
Read `shared/workspace.md` first for the layer model and schemas.

## Prerequisites

`typst` on the PATH (`which typst`). If it's missing, tell the user how to get
it (`cargo install --locked typst-cli`, a distro package, or a release from
<https://github.com/typst/typst/releases>) and stop. Don't install it yourself.

## Procedure

### 1. Resolve the data dir

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/paths.sh"
```

Tell the user the directory and the rule that picked it in one line. If they
want it somewhere else (an existing private repo, a synced folder), tell them
to set `TYPST_DOCGEN_HOME` in their shell profile, and use that path for this run.

### 2. Move legacy data

If `paths.sh` printed `legacy_dir:`, there is data from plugin 0.5.0 or earlier
in `~/.claude/plugins-data/typst-document-generator/`. Offer to move it:

```bash
mkdir -p "$DATA" && cp -a "$LEGACY"/. "$DATA"/ && mv "$LEGACY" "$LEGACY.moved-$(date +%Y%m%d)"
```

While moving, rename seed copies from old releases: `dsr-business-doc.yaml` →
`business-doc.yaml`, and `dsr-client-confidential.yaml` →
`client-confidential.yaml`. Update `name:` inside each file to match. Any
template file that is byte-identical to the built-in seed of the same name can
be deleted: the built-in is read directly now. Say what you moved, renamed and
dropped.

### 3. Detect existing setup

If `profile.yaml` exists, offer:
- *Update profile* (identity, business, defaults; templates untouched).
- *Add a template* → hand over to `/typst-document-generator:add-profile`.
- *Customise a built-in*: copy `seeds/templates/<name>.yaml` into `templates/` so the user can edit it. Their copy overrides the built-in from then on.
- *Full reset*: first back up to `profile.yaml.bak-YYYYMMDD-HHMMSS`.

Otherwise continue.

### 4. Identity

- `author.name`: required.
- `author.email`: required.
- `author.personal_site`: domain only, no protocol. Optional, and used by `public-doc`.
- `author.public_email`: optional.
- `date_format`: `dd-mm-yy`, the only format supported today. Just confirm it.

### 5. Business (optional)

Ask: "Do you produce documents under a business or brand?"

- **No:** `business: null`. `business-doc` and `client-confidential` won't be available.
- **Yes:** `business.name`, `business.site` (domain only), `business.logo_path`.
  Copy the logo into `<data dir>/assets/` and store the relative path
  (`assets/logo.png`), so the overlay is self-contained if it's synced or put in
  git. If they don't have a logo ready, leave it empty and say they can add it later.

More than one business: the profile holds one. For a second brand, create a
template in the overlay that sets its own header and footer values (via
`add-profile`) rather than a second profile.

### 6. Defaults

- `default_license`: default `MIT`. Alternatives: `Apache-2.0`, `CC-BY-4.0`, `CC-BY-SA-4.0`, `GPL-3.0`, `All Rights Reserved`.
- `default_output_dir`: default `null` (ask each time).

### 7. Write

```bash
mkdir -p "$DATA"/{templates,bases,assets}
```

Write `profile.yaml` with `captured_at: <today, ISO>`. Do **not** copy the
built-in templates. They're read from the plugin, so they keep getting fixes.

### 8. Private and synced (offer once)

If the data dir isn't inside a git work tree (`git -C "$DATA" rev-parse` fails),
offer to make it one: `git init`, plus a short `README.md` that says what the
folder is. Don't create a remote or push. If the user wants it on GitHub,
it must be a **private** repo: it holds their name, email and logo.

If it already sits inside a larger repo (a user-data repo), don't init a nested
one. Mention that commits there should stage this folder explicitly.

### 9. Summary

- The data dir and the rule that picked it.
- Profile: name, business (yes/no), default license.
- Templates available (`paths.sh templates`), marked user or builtin.
- Entry points: `personal-doc`, `public-doc`, `business-doc`,
  `client-confidential`, `personal-confidential`, `briefing`, `screenplay`, and
  `render` for any template (their own included). `add-profile` saves a new format.

## Tips

- Changing a site or business name later only needs a `profile.yaml` edit:
  templates use tokens, not literal values.
- Template ideas worth suggesting: meeting notes, a client pitch with a different
  footer, a technical RFC with `toc-depth: 2`.
