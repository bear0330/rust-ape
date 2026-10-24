# ShieldedLabs cargo_cosmo 10.0.0, commit c41e7a2.
# DOWNLOAD_SOURCE saves sources.tar.gz, check_sha.sh checks
# check.signature, and the patch step applies minimal.diff with patch -p0.
# The driver builds both architectures and apelinks them. The aarch64
# make stages wait for that single build and only check its ELF.

RUST_SRC := https://github.com/ShieldedLabs/cargo_cosmo/archive/c41e7a2df8967c6d551d5686e3392958f597c9ce.tar.gz

$(eval $(call DOWNLOAD_SOURCE,lang/rust,$(RUST_SRC)))

# The generic patch rule has no implicit patch-file lookup.
# Re-extract first: patched is a stamp, and a changed diff must not
# be applied on top of an already patched tree.
o/lang/rust/patched: PATCH_FILE = $(BASELOC)/lang/rust/minimal.diff
o/lang/rust/patched: $(BASELOC)/lang/rust/minimal.diff $(BASELOC)/lang/rust/patch-wrapper
o/lang/rust/patched: PATCH_COMMAND = $(BASELOC)/lang/rust/patch-wrapper

o/lang/rust/configured.x86_64: CONFIG_COMMAND = $(BASELOC)/lang/rust/stage configure
o/lang/rust/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/lang/rust/built.x86_64: BUILD_COMMAND = $(BASELOC)/lang/rust/stage build
o/lang/rust/built.aarch64: BUILD_COMMAND = $(BASELOC)/lang/rust/stage build-aarch64
o/lang/rust/built.aarch64: o/lang/rust/built.x86_64

o/lang/rust/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/lang/rust/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/lang/rust/built.fat: FATTEN_COMMAND = $(BASELOC)/lang/rust/stage fatten
o/lang/rust/built.fat: $(BASELOC)/lang/rust/stage $(BASELOC)/lang/rust/patch-wrapper

# One cargo_cosmo driver apelinks both architectures. Stay off the
# default lang aggregate; the installer only adds the include line.
rust: o/lang/rust/built.fat

.PHONY: rust
