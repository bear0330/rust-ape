# fd 10.2.0. One cargo cosmo build apelinks both architectures.
# lang/rust provides the toolchain. fd stays off the default cli aggregate.

FD_SRC := https://github.com/sharkdp/fd/archive/refs/tags/v10.2.0.tar.gz

$(eval $(call DOWNLOAD_SOURCE,cli/fd,$(FD_SRC)))
$(eval $(call SPECIFY_DEPS,cli/fd,lang/rust))

o/cli/fd/patched: PATCH_FILE = $(BASELOC)/cli/fd/minimal.diff
o/cli/fd/patched: $(BASELOC)/cli/fd/minimal.diff

o/cli/fd/configured.x86_64: CONFIG_COMMAND = $(DUMMYLINK0)
o/cli/fd/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/cli/fd/built.x86_64: BUILD_COMMAND = $(BASELOC)/cli/build-ape build fd fd-10.2.0 fd
o/cli/fd/built.aarch64: BUILD_COMMAND = $(DUMMYLINK0)
o/cli/fd/built.aarch64: o/cli/fd/built.x86_64

o/cli/fd/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/cli/fd/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/cli/fd/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/build-ape fatten fd fd-10.2.0 fd
o/cli/fd/built.fat: $(BASELOC)/cli/build-ape $(BASELOC)/cli/fd/smoke
