#!/usr/bin/env bash
# Resolve this plugin's user data directory (the private overlay) and list the
# templates and bases visible from it.
#
#   scripts/paths.sh            -> prints the data dir and which rule picked it
#   scripts/paths.sh dir        -> prints only the data dir
#   scripts/paths.sh templates  -> every template, user overlay first:  <name>\t<user|builtin>\t<path>
#   scripts/paths.sh template N -> path of template N (user copy wins), exit 1 if none
#   scripts/paths.sh bases      -> every Typst base file:               <file>\t<user|builtin>\t<path>
#
# Resolution order for the data dir (first match wins):
#   1. $TYPST_DOCGEN_HOME                              explicit override
#   2. $CLAUDE_USER_DATA/typst-document-generator      shared user-data root, if set
#   3. ~/.claude-user-data/typst-document-generator    if ~/.claude-user-data exists
#   4. ${XDG_DATA_HOME:-~/.local/share}/claude-plugins/typst-document-generator
#                                                      if that claude-plugins root exists
#   5. ~/.claude-user-data/typst-document-generator    default
# The legacy location ~/.claude/plugins-data/typst-document-generator (plugin
# version 0.5.0 and earlier) is reported, never used: `onboard` offers to move it.
set -euo pipefail

NAME=typst-document-generator
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
XDG_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins"
LEGACY="$HOME/.claude/plugins-data/$NAME"

if [[ -n "${TYPST_DOCGEN_HOME:-}" ]]; then
  DIR="$TYPST_DOCGEN_HOME"; RULE="TYPST_DOCGEN_HOME"
elif [[ -n "${CLAUDE_USER_DATA:-}" ]]; then
  DIR="$CLAUDE_USER_DATA/$NAME"; RULE="CLAUDE_USER_DATA"
elif [[ -d "$HOME/.claude-user-data" ]]; then
  DIR="$HOME/.claude-user-data/$NAME"; RULE="existing ~/.claude-user-data"
elif [[ -d "$XDG_ROOT" ]]; then
  DIR="$XDG_ROOT/$NAME"; RULE="existing $XDG_ROOT"
else
  DIR="$HOME/.claude-user-data/$NAME"; RULE="default"
fi

list() { # $1 = subdir in data dir, $2 = subdir in plugin, $3 = glob
  declare -A seen=()
  if [[ -d "$DIR/$1" ]]; then
    for f in "$DIR/$1"/$3; do
      [[ -e "$f" ]] || continue
      b=$(basename "$f"); seen[$b]=1
      printf '%s\tuser\t%s\n' "${b%.yaml}" "$f"
    done
  fi
  for f in "$PLUGIN_ROOT/$2"/$3; do
    [[ -e "$f" ]] || continue
    b=$(basename "$f")
    [[ -n "${seen[$b]:-}" ]] && continue
    printf '%s\tbuiltin\t%s\n' "${b%.yaml}" "$f"
  done
}

case "${1:-}" in
  dir) echo "$DIR" ;;
  templates) list templates seeds/templates '*.yaml' ;;
  template)
    n="${2:?template name}"
    if [[ -f "$DIR/templates/$n.yaml" ]]; then echo "$DIR/templates/$n.yaml"
    elif [[ -f "$PLUGIN_ROOT/seeds/templates/$n.yaml" ]]; then echo "$PLUGIN_ROOT/seeds/templates/$n.yaml"
    else echo "no template named '$n'" >&2; exit 1; fi ;;
  bases) list bases shared '*.typ' ;;
  "")
    echo "data_dir: $DIR"
    echo "rule: $RULE"
    echo "plugin_root: $PLUGIN_ROOT"
    echo "profile: $([[ -f "$DIR/profile.yaml" ]] && echo present || echo missing)"
    [[ -d "$LEGACY" ]] && echo "legacy_dir: $LEGACY (run onboard to move it)"
    exit 0 ;;
  *) echo "usage: $0 [dir|templates|template NAME|bases]" >&2; exit 2 ;;
esac
