# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libgpg_error
$(PKG)_WEBSITE  := https://www.gnupg.org/related_software/libgpg-error/
$(PKG)_DESCR    := libgpg-error
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.54
$(PKG)_CHECKSUM := 607dcadfd722120188eca5cd07193158b9dd906b578a557817ec779bd5e16d0e
$(PKG)_SUBDIR   := libgpg-error-$($(PKG)_VERSION)
$(PKG)_FILE     := libgpg-error-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://gnupg.org/ftp/gcrypt/libgpg-error/$($(PKG)_FILE)
$(PKG)_URL_2    := https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/libgpg-error/$($(PKG)_FILE)
$(PKG)_DEPS     := cc gettext

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gnupg.org/ftp/gcrypt/libgpg-error/' | \
    $(SED) -n 's,.*libgpg-error-\([1-9]\.[1-9][0-9][^>]*\)\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(SOURCE_DIR)/src/syscfg' && ln -s lock-obj-pub.mingw32.h lock-obj-pub.mingw32.$(call merge,.,$(call rest,$(call split,.,$(TARGET)))).h
    cd '$(SOURCE_DIR)' && autoreconf -fi
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --disable-nls \
        --disable-languages \
        --enable-install-gpg-error-config
    $(SED) -i 's/host_os = mingw32.*/host_os = mingw32/' '$(BUILD_DIR)/src/Makefile'
    $(MAKE) -C '$(BUILD_DIR)/src' -j '$(JOBS)' bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    $(SED) -i 's/-lgpg-error/-lgpg-error -lintl -liconv -lws2_32/;' '$(BUILD_DIR)/src/gpg-error-config'
    $(MAKE) -C '$(BUILD_DIR)/src' -j 1 install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    ln -sf '$(PREFIX)/$(TARGET)/bin/gpg-error-config' '$(PREFIX)/bin/$(TARGET)-gpg-error-config'
endef
