# hexyl 0.16.0. One cargo cosmo build apelinks both architectures.
# No patch: the crate is already pure Rust. hexyl stays off the default
# cli aggregate.

HEXYL_SRC := https://github.com/sharkdp/hexyl/archive/refs/tags/v0.16.0.tar.gz

$(eval $(call DOWNLOAD_SOURCE,cli/hexyl,$(HEXYL_SRC)))
$(eval $(call SPECIFY_DEPS,cli/hexyl,lang/rust))

o/cli/hexyl/configured.x86_64: CONFIG_COMMAND = $(DUMMYLINK0)
o/cli/hexyl/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/cli/hexyl/built.x86_64: BUILD_COMMAND = $(BASELOC)/cli/build-ape build hexyl hexyl-0.16.0 hexyl
o/cli/hexyl/built.aarch64: BUILD_COMMAND = $(DUMMYLINK0)
o/cli/hexyl/built.aarch64: o/cli/hexyl/built.x86_64

o/cli/hexyl/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/cli/hexyl/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/cli/hexyl/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/build-ape fatten hexyl hexyl-0.16.0 hexyl
o/cli/hexyl/built.fat: $(BASELOC)/cli/build-ape $(BASELOC)/cli/hexyl/smoke
