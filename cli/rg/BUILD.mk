# ripgrep 15.2.0. One cargo cosmo build apelinks both architectures.
# lang/rust provides the toolchain. Stock lib/pcre is PCRE2 10.42, built
# once per architecture into cosmos/. rg stays off the default cli aggregate.

RG_SRC := https://github.com/BurntSushi/ripgrep/archive/refs/tags/15.2.0.tar.gz
RG_COSMOCC := $(BASELOC)/o/lang/rust/cargo_cosmo-c41e7a2df8967c6d551d5686e3392958f597c9ce/toolchain/cosmocc

$(eval $(call DOWNLOAD_SOURCE,cli/rg,$(RG_SRC)))
$(eval $(call SPECIFY_DEPS,cli/rg,lang/rust lib/pcre))

# Stock lib recipes call cosmopolitan/cosmocc. This tree does not run
# setup; lang/rust already downloaded that compiler.
$(BASELOC)/cosmopolitan/cosmocc/bin/x86_64-unknown-cosmo-cc: o/lang/rust/installed.x86_64
	mkdir -p $(BASELOC)/cosmopolitan
	ln -sfn $(RG_COSMOCC) $(BASELOC)/cosmopolitan/cosmocc

o/lib/pcre/configured.x86_64: $(BASELOC)/cosmopolitan/cosmocc/bin/x86_64-unknown-cosmo-cc
o/lib/pcre/configured.aarch64: $(BASELOC)/cosmopolitan/cosmocc/bin/x86_64-unknown-cosmo-cc
# aarch64-unknown-cosmo-cc emits an ELF the build host cannot execute.
# Stock configure has no --host, so it treats that as a native failure.
o/lib/pcre/configured.aarch64: CONFIG_COMMAND = $(BASELOC)/o/lib/pcre/pcre*/configure --disable-shared --enable-static --without-pic --host=aarch64-unknown-linux-gnu --prefix=$(COSMOS) CFLAGS="-Os"

o/cli/rg/patched: PATCH_FILE = $(BASELOC)/cli/rg/minimal.diff
o/cli/rg/patched: $(BASELOC)/cli/rg/minimal.diff

o/cli/rg/configured.x86_64: CONFIG_COMMAND = $(DUMMYLINK0)
o/cli/rg/configured.aarch64: CONFIG_COMMAND = $(DUMMYLINK0)

# cargo cosmo links both architectures inside the x86_64 build step.
o/cli/rg/built.x86_64: o/lib/pcre/installed.aarch64
o/cli/rg/built.x86_64: BUILD_COMMAND = \
	PCRE2_SYS_STATIC=0 \
	LIBPCRE2_8_STATIC=1 \
	PKG_CONFIG_ALLOW_CROSS=1 \
	PKG_CONFIG_PATH_x86_64_unknown_cosmo=$(BASELOC)/cosmos/x86_64/lib/pkgconfig \
	PKG_CONFIG_PATH_aarch64_unknown_cosmo=$(BASELOC)/cosmos/aarch64/lib/pkgconfig \
	APE_FEATURES=pcre2 \
	$(BASELOC)/cli/build-ape build rg ripgrep-15.2.0 rg
o/cli/rg/built.aarch64: BUILD_COMMAND = $(DUMMYLINK0)
o/cli/rg/built.aarch64: o/cli/rg/built.x86_64

o/cli/rg/installed.x86_64: INSTALL_COMMAND = $(DUMMYLINK0)
o/cli/rg/installed.aarch64: INSTALL_COMMAND = $(DUMMYLINK0)

o/cli/rg/built.fat: FATTEN_COMMAND = $(BASELOC)/cli/build-ape fatten rg ripgrep-15.2.0 rg
o/cli/rg/built.fat: $(BASELOC)/cli/build-ape $(BASELOC)/cli/rg/smoke
