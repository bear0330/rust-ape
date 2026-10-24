# jaq 3.1.2, a jq-compatible query tool for JSON and the other formats
# other languages usually shell out for. One cargo cosmo build apelinks
# both architectures. lang/rust provides the toolchain. jaq stays off
# the default cli aggregate.

JAQ_SRC := https://github.com/01mf02/jaq/archive/refs/tags/v3.1.2.tar.gz

$(eval $(call DOWNLOAD_SOURCE,cli/jaq,$(JAQ_SRC)))
$(eval $(call SPECIFY_DEPS,cli/jaq,lang/rust))

o/cli/jaq/patched: PATCH_FILE = $(BASELOC)/cli/jaq/minimal.diff
o/cli/jaq/patched: $(BASELOC)/cli/jaq/minimal.diff

o/cli/jaq/configured.x86_64: CONFIG_COMMAND = $(DUMMYLINK0)
o/cli/jaq/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

o/cli/jaq/built.x86_64: BUILD_COMMAND = $(BASELOC)/cli/build-ape build jaq jaq-3.1.2 jaq
o/cli/jaq/built.aarch64: BUILD_COMMAND = $(DUMMYLINK0)
o/cli/jaq/built.aarch64: o/cli/jaq/built.x86_64

o/cli/jaq/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/cli/jaq/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/cli/jaq/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/build-ape fatten jaq jaq-3.1.2 jaq
o/cli/jaq/built.fat: $(BASELOC)/cli/build-ape $(BASELOC)/cli/jaq/smoke
