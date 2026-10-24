#!/bin/sh
# Copy lang/rust and cli back from a superconfigure checkout. Tests stay
# in this repository and are not part of the upstream recipe.
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
for path in \
  lang/rust/BUILD.mk lang/rust/stage lang/rust/patch-wrapper \
  lang/rust/check.signature lang/rust/minimal.diff lang/rust/cosmocc.sha256 \
  cli/build-ape cli/rg/BUILD.mk cli/fd/BUILD.mk cli/hexyl/BUILD.mk cli/jaq/BUILD.mk
do
  [ -e "$SOURCE/$path" ] || {
    echo "missing required source path: $SOURCE/$path" >&2
    exit 1
  }
done

if [ "$FORCE" != true ] && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git -C "$ROOT" status --porcelain --untracked-files=all -- lang/rust cli)" ]; then
    echo "refusing to overwrite modified lang/rust or cli; commit/stash it or rerun with --force" >&2
    exit 1
  fi
fi

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/rust-ape-sync-stage.XXXXXX")
BACKUP=$(mktemp -d "${TMPDIR:-/tmp}/rust-ape-sync-backup.XXXXXX")
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT HUP INT TERM

mkdir -p "$STAGE/lang" "$STAGE/cli"
cp -a "$SOURCE/lang/rust" "$STAGE/lang/rust"
cp -a "$SOURCE/cli/rg" "$STAGE/cli/rg"
cp -a "$SOURCE/cli/fd" "$STAGE/cli/fd"
cp -a "$SOURCE/cli/hexyl" "$STAGE/cli/hexyl"
cp -a "$SOURCE/cli/jaq" "$STAGE/cli/jaq"
cp -a "$SOURCE/cli/build-ape" "$STAGE/cli/build-ape"
if [ -e "$ROOT/lang/rust" ]; then mkdir -p "$BACKUP/lang"; mv "$ROOT/lang/rust" "$BACKUP/lang/rust"; fi
if [ -e "$ROOT/cli" ]; then mkdir -p "$BACKUP"; mv "$ROOT/cli" "$BACKUP/cli"; fi
mv "$STAGE/lang/rust" "$ROOT/lang/rust"
mkdir -p "$ROOT/cli"
mv "$STAGE/cli/rg" "$ROOT/cli/rg"
mv "$STAGE/cli/fd" "$ROOT/cli/fd"
mv "$STAGE/cli/hexyl" "$ROOT/cli/hexyl"
mv "$STAGE/cli/jaq" "$ROOT/cli/jaq"
mv "$STAGE/cli/build-ape" "$ROOT/cli/build-ape"
chmod +x "$ROOT/lang/rust/stage" "$ROOT/lang/rust/patch-wrapper" "$ROOT/cli/build-ape" \
  "$ROOT/cli/rg/smoke" "$ROOT/cli/fd/smoke" "$ROOT/cli/hexyl/smoke" \
  "$ROOT/cli/jaq/smoke"

echo "Synchronized from $SOURCE"
echo "Replaced files are backed up at $BACKUP"
