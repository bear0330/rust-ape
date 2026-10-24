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
install_tree() {
  relative=$1
  destination=$SUPER/$relative
  mkdir -p "$(dirname -- "$destination")"
  if [ -e "$destination" ]; then
    mkdir -p "$BACKUPS/$(dirname -- "$relative")"
    mv "$destination" "$BACKUPS/$relative"
  fi
  cp -a "$ROOT/$relative" "$destination"
}
enable() { grep -Fqx "$1" "$SUPER/$2" || printf '\n%s\n' "$1" >> "$SUPER/$2"; }
install_tree lang/rust
install_tree cli/rg
install_tree cli/fd
install_tree cli/hexyl
install_tree cli/jaq
mkdir -p "$SUPER/cli"
cp -a "$ROOT/cli/build-ape" "$SUPER/cli/build-ape"
chmod +x "$SUPER/lang/rust/stage" "$SUPER/lang/rust/patch-wrapper" "$SUPER/cli/build-ape" \
  "$SUPER/cli/rg/smoke" "$SUPER/cli/fd/smoke" "$SUPER/cli/hexyl/smoke" \
  "$SUPER/cli/jaq/smoke"
enable 'include lang/rust/BUILD.mk' lang/BUILD.mk
enable 'include cli/rg/BUILD.mk' cli/BUILD.mk
enable 'include cli/fd/BUILD.mk' cli/BUILD.mk
enable 'include cli/hexyl/BUILD.mk' cli/BUILD.mk
enable 'include cli/jaq/BUILD.mk' cli/BUILD.mk
printf 'Installed Rust overlay into %s. Backup: %s\n' "$SUPER" "$BACKUPS"
