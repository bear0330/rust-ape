# ShieldedLabs cargo_cosmo 10.0.0, commit c41e7a2.
# The driver builds both architectures and apelinks them. The aarch64
# make stages wait for that single build and only check its ELF.

o/lang/rust/downloaded: DL_COMMAND = $(BASELOC)/lang/rust/stage download
o/lang/rust/checked: CHECK_COMMAND = $(BASELOC)/lang/rust/stage check
o/lang/rust/patched: PATCH_COMMAND = $(BASELOC)/lang/rust/stage patch

o/lang/rust/configured.x86_64: CONFIG_COMMAND = $(BASELOC)/lang/rust/stage configure
o/lang/rust/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/lang/rust/built.x86_64: BUILD_COMMAND = $(BASELOC)/lang/rust/stage build
o/lang/rust/built.aarch64: BUILD_COMMAND = $(BASELOC)/lang/rust/stage build-aarch64
o/lang/rust/built.aarch64: o/lang/rust/built.x86_64

o/lang/rust/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/lang/rust/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/lang/rust/built.fat: FATTEN_COMMAND = $(BASELOC)/lang/rust/stage fatten
o/lang/rust/built.fat: $(BASELOC)/lang/rust/stage

# One cargo_cosmo driver apelinks both architectures. Stay off the
# default lang aggregate; the installer only adds the include line.
rust: o/lang/rust/built.fat

.PHONY: rust
