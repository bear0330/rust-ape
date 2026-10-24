# Rust for Cosmopolitan APE

This project is the `lang/rust` overlay for a fat Rust APE. It builds
`results/bin/rust-std.com` from ShieldedLabs cargo_cosmo 10.0.0
(`c41e7a2`), nightly `2026-08-23`, and the cosmocc 4.0.2 release zip.
The binary carries x86_64 and aarch64. One program covers stdio, the
heap, a thread, file IO, `pipe2`, a localhost TCP accept, and
`catch_unwind`.

Superconfigure supplies the build framework. This overlay does not use
the checkout's Cosmopolitan clone. The recipe downloads the cosmocc
zip that cargo_cosmo measured.

The same binary has been run on Linux x86-64, Windows x86-64, and
macOS aarch64.

## Install the overlay

[`superconfigure.lock`](superconfigure.lock) pins ahgamut/superconfigure
`z0.0.66` (`29009f53`). With no argument, the installer clones that
base to `./superconfigure/`, copies `lang/rust`, and adds one include
line to `lang/BUILD.mk`. Rust stays off the default `lang` aggregate.

```sh
./scripts/install-overlay.sh
```

To use an existing matching checkout, pass it explicitly:

```sh
./scripts/install-overlay.sh /path/to/superconfigure
```

The installer refuses any other revision. A replaced `lang/rust` tree
is backed up under `.ape-overlay-backups/`.

## Build

On WSL, clone this repository onto the Linux filesystem, not a
`/mnt/c` or `/mnt/d` Windows mount. Cosmocc launches nested programs
that DrvFs cannot run reliably.

`rustup` must be installed. The recipe installs
`nightly-2026-08-23` with the `rust-src` component. No `setup` or
`cosmo` step is required. From the superconfigure checkout:

```sh
bash ./.github/scripts/collectbuild lang/rust
```

That is the whole build. `collectbuild` sees `lang/rust/BUILD.mk` and
`lang/rust/check.signature`, then `make` downloads `sources.tar.gz`,
checks it, applies `minimal.diff`, and apelinks `rust-std.com`.
Cargo uses `collectbuild`'s `MAXPROC` unless `CARGO_BUILD_JOBS` is
already set.

It writes:

```text
results/bin/rust-std.com
results/bin/rust-std.x86_64
results/bin/rust-std.aarch64
```

Run the fat binary with `bash results/bin/rust-std.com`. The build
also runs that smoke before it finishes.

```sh
./scripts/test-overlay.sh
```

## CLI programs

`cli/rg`, `cli/fd`, `cli/hexyl`, and `cli/jaq` are upstream Rust tools
built with that same cargo_cosmo toolchain. Each `collectbuild`
downloads the pinned archive, checks `check.signature`, applies
`minimal.diff` when the package has one, and apelinks one fat binary.
They stay off the default `cli` aggregate, and each one waits for
`lang/rust`.

```sh
bash ./.github/scripts/collectbuild cli/rg
bash ./.github/scripts/collectbuild cli/fd
bash ./.github/scripts/collectbuild cli/hexyl
bash ./.github/scripts/collectbuild cli/jaq
```

The results are `results/bin/rg.com`, `results/bin/fd.com`,
`results/bin/hexyl.com`, and `results/bin/jaq.com`, plus the x86_64
and aarch64 ELF slices. `rg` is ripgrep 14.1.1, `fd` is 10.2.0,
`hexyl` is 0.16.0, and `jaq` is 3.1.2.

`jaq` is the one meant to be wrapped by another language. It is a
jq-compatible filter with `--from` and `--to` for JSON, YAML, TOML,
XML, CBOR, and CSV, so a generated binding can offer that conversion
without a C library in the host language.

`minimal.diff` for `rg` and `fd` turns off jemalloc. The cosmo target
reports `env=musl`, which is the switch those projects use to compile
jemalloc, and cargo_cosmo does not retarget a C allocator once per
architecture. libcosmo remains the allocator. hexyl needs no patch.
`jaq` defaults to mimalloc, which is the same kind of C allocator, so
its patch leaves that feature out.

`cli/build-ape` also sets `profile.release.strip=false`. fd's release
profile sets `strip = true`, and that removes the ELF symbol table
before `fixupobj` rewrites the image.

## What the recipe pins

Stock superconfigure downloads the cargo_cosmo archive as
`sources.tar.gz`, checks `lang/rust/check.signature`, and applies
`lang/rust/minimal.diff` with `patch -p0`. The signature is the
SHA-256 of that archive. The extracted root is
`cargo_cosmo-c41e7a2df8967c6d551d5686e3392958f597c9ce`.

`minimal.diff` teaches the sockopt shim that Windows `SO_REUSEADDR`
is `-5` (`SO_EXCLUSIVEADDRUSE`). Without that, `TcpListener::bind`
returns `ENOPROTOOPT` before `bind`.

The cosmocc 4.0.2 zip is the toolchain cargo_cosmo measured, not the
package archive. `configure` downloads it and checks
`lang/rust/cosmocc.sha256`. The nightly channel is `nightly-2026-08-23`,
read from the archive's `rust-toolchain.toml`.
