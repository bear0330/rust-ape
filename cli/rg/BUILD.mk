# ripgrep 14.1.1. One cargo cosmo build apelinks both architectures.
# lang/rust provides the toolchain. rg stays off the default cli aggregate.

RG_SRC := https://github.com/BurntSushi/ripgrep/archive/refs/tags/14.1.1.tar.gz

$(eval $(call DOWNLOAD_SOURCE,cli/rg,$(RG_SRC)))
$(eval $(call SPECIFY_DEPS,cli/rg,lang/rust))

o/cli/rg/patched: PATCH_FILE = $(BASELOC)/cli/rg/minimal.diff
o/cli/rg/patched: $(BASELOC)/cli/rg/minimal.diff

o/cli/rg/configured.x86_64: CONFIG_COMMAND = $(DUMMYLINK0)
o/cli/rg/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/cli/rg/built.x86_64: BUILD_COMMAND = $(BASELOC)/cli/build-ape build rg ripgrep-14.1.1 rg
o/cli/rg/built.aarch64: BUILD_COMMAND = $(DUMMYLINK0)
o/cli/rg/built.aarch64: o/cli/rg/built.x86_64

o/cli/rg/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/cli/rg/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/cli/rg/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/build-ape fatten rg ripgrep-14.1.1 rg
o/cli/rg/built.fat: $(BASELOC)/cli/build-ape $(BASELOC)/cli/rg/smoke
