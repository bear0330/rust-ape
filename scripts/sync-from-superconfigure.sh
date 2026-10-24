#!/bin/sh
# Copy lang/rust back from a superconfigure checkout. Tests stay in this
# repository and are not part of the upstream recipe.
set -eu

usage() {
  echo "Usage: $0 [--force] /path/to/superconfigure" >&2
  exit 2
}

FORCE=false
case "${1:-}" in
  --force) FORCE=true; shift ;;
esac
[ "$#" -eq 1 ] || usage

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SOURCE=$(CDPATH= cd -- "$1" && pwd)
for path in lang/rust/BUILD.mk lang/rust/stage lang/rust/check.signature lang/rust/so-reuseaddr.diff; do
  [ -e "$SOURCE/$path" ] || {
    echo "missing required source path: $SOURCE/$path" >&2
    exit 1
  }
done

if [ "$FORCE" != true ] && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git -C "$ROOT" status --porcelain --untracked-files=all -- lang/rust)" ]; then
    echo "refusing to overwrite modified lang/rust; commit/stash it or rerun with --force" >&2
    exit 1
  fi
fi

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/rust-ape-sync-stage.XXXXXX")
BACKUP=$(mktemp -d "${TMPDIR:-/tmp}/rust-ape-sync-backup.XXXXXX")
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT HUP INT TERM

mkdir -p "$STAGE/lang"
cp -a "$SOURCE/lang/rust" "$STAGE/lang/rust"
if [ -e "$ROOT/lang/rust" ]; then mkdir -p "$BACKUP/lang"; mv "$ROOT/lang/rust" "$BACKUP/lang/rust"; fi
mv "$STAGE/lang/rust" "$ROOT/lang/rust"
chmod +x "$ROOT/lang/rust/stage"

echo "Synchronized from $SOURCE"
echo "Replaced files are backed up at $BACKUP"
