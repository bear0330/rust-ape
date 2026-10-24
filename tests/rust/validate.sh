#!/bin/sh
# Smoke one rust-std.com. The deliberate panic is the unwind probe and goes
# to stderr; these lines are the stdout contract.
set -eu

[ "$#" -eq 1 ] || { echo "Usage: $0 /path/to/rust-std.com" >&2; exit 2; }
BIN=$1
[ -f "$BIN" ] || { echo "missing $BIN" >&2; exit 1; }
out=$(bash "$BIN")
printf '%s\n' "$out"
for want in \
  "hello from a std Rust APE" \
  "heap  = works" \
  "thread sum 1..10 = 55" \
  "file  = file io works" \
  "catch_unwind caught = true" \
  "ioerr = No such file or directory" \
  "pipe2 = works" \
  "accept = works"
do
  printf '%s\n' "$out" | grep -F -q -- "$want" || {
    echo "rust-ape: smoke output missing: $want" >&2
    exit 1
  }
done
