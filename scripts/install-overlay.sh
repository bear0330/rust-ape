#!/bin/sh
set -eu

[ "$#" -le 1 ] || { echo "Usage: $0 [superconfigure-directory]" >&2; exit 2; }
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
value() { sed -n "s/^$1=//p" "$ROOT/superconfigure.lock"; }
REPOSITORY=$(value superconfigure_repository)
REF=$(value superconfigure_ref)
EXPECTED=$(value superconfigure_commit)
if [ "$#" -eq 0 ]; then
  SUPER=$ROOT/superconfigure
  if [ ! -e "$SUPER" ]; then git clone --depth 1 --branch "$REF" "$REPOSITORY" "$SUPER"; fi
else
  SUPER=$1
fi
SUPER=$(CDPATH= cd -- "$SUPER" && pwd)
ACTUAL=$(git -C "$SUPER" rev-parse HEAD 2>/dev/null || true)
[ "$ACTUAL" = "$EXPECTED" ] || { echo "expected superconfigure $EXPECTED, got ${ACTUAL:-not-a-matching-git-checkout}" >&2; exit 1; }
# The recipe downloads cosmocc 4.0.2 itself. Do not run setup or cosmo for it,
# and do not reuse this tree's Cosmopolitan checkout.
mkdir -p "$SUPER/.ape-overlay-backups"
BACKUPS=$(mktemp -d "$SUPER/.ape-overlay-backups/rust-ape.XXXXXX")
DESTINATION=$SUPER/lang/rust
if [ -e "$DESTINATION" ]; then mkdir -p "$BACKUPS/lang"; mv "$DESTINATION" "$BACKUPS/lang/rust"; fi
mkdir -p "$SUPER/lang"
cp -a "$ROOT/lang/rust" "$DESTINATION"
chmod +x "$DESTINATION/stage" "$DESTINATION/patch-wrapper"
grep -Fqx 'include lang/rust/BUILD.mk' "$SUPER/lang/BUILD.mk" || printf '\ninclude lang/rust/BUILD.mk\n' >> "$SUPER/lang/BUILD.mk"
printf 'Installed Rust overlay into %s. Backup: %s\n' "$SUPER" "$BACKUPS"
