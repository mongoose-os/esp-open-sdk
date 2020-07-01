# Build toolchain if necessary
BUILD_TOOLCHAIN ?= y

# Whether to merge SDK into Xtensa toolchain, producing standalone
# ESP8266 toolchain. Use 'n' if you want generic Xtensa toolchain
# which can be used with multiple SDK versions.
STANDALONE = y

# NOTE: 4.8.5 has failing patches and 5.2.0 fails at GCC compile
# GCC_VERSION = 4.8.5
# GCC_VERSION = 5.2.0

# GCC_VERSION = 6.4.0
# GCC_VERSION = 7.4.0
# GCC_VERSION = 8.2.0
GCC_VERSION = 9.2.0
CT_GCC_VERSION = $(shell echo $(GCC_VERSION) | sed -e 's/\./_/g')

# NOTE: comment out to disable building gdb (cuts down on build time)
CT_EN_GDB ?= yes

# NOTE: uncomment to configure newlib with --enable-newlib-reent-small
# CT_LIBC_EN_REENT ?= yes

# NOTE: uncomment to configure newlib with:
# --enable-newlib-io-long-long
# --enable-newlib-io-c99-formats
CT_LIBC_EN_IO_EXTRA ?= yes

# Directory to install toolchain to, by default inside current dir.
TOOLCHAIN = /opt/Espressif/xtensa-lx106-elf

# NOTE: Leave this as-is and use full shas above to simplfiy things.
# Instead of all the makefile hacks that break every time, just
# always call it master, then d/l the SDK as a zip based on SHA.
VENDOR_SDK = master

VENDOR_FULL_SHA   := a0b131126ba803d0069014698a07e9f2fd3decd6
VENDOR_GIT_ZIP    := "ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA).zip"
VENDOR_ZIP_DL_URI := "https://github.com/espressif/ESP8266_NONOS_SDK/archive/$(VENDOR_FULL_SHA).zip"

.PHONY: crosstool-ng esptool toolchain _libhal libs sdk liblwip lwip2 postbuild

TOP = $(PWD)
SHELL = /bin/bash
PATCH = patch -b -N
UNZIP = unzip -q -o
VENDOR_SDK_ZIP = $(VENDOR_SDK_ZIP_$(VENDOR_SDK))
VENDOR_SDK_DIR = $(VENDOR_SDK_DIR_$(VENDOR_SDK))
VENDOR_ZIP_DIR = $(VENDOR_ZIP_DIR_$(VENDOR_SDK))

VENDOR_SDK_ZIP_master = ESP8266_NONOS_SDK-master.zip
VENDOR_ZIP_DIR_master = ESP8266_NONOS_SDK-master
VENDOR_SDK_DIR_master = esp_nonos_sdk_master

all: toolchain esptool sdk libs postbuild
	@echo
	@echo "Xtensa toolchain is built, to use it:"
	@echo
	@echo 'export PATH=$(TOOLCHAIN)/bin:$$PATH'
	@echo
ifneq ($(STANDALONE),y)
	@echo "Espressif ESP8266 SDK is installed. Toolchain contains only Open Source components"
	@echo "To link external proprietary libraries add:"
	@echo
	@echo "xtensa-lx106-elf-gcc -I$(TOP)/sdk/include -L$(TOP)/sdk/lib"
	@echo
else
	@echo "Espressif ESP8266 SDK is installed, its libraries and headers are merged with the toolchain"
	@echo
endif

esptool: $(TOOLCHAIN)/bin/esptool.py

$(TOOLCHAIN)/bin/esptool.py:
	cp esptool/esptool.py $(TOOLCHAIN)/bin/

toolchain: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc

ifeq "$(BUILD_TOOLCHAIN)" "y"
$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc: crosstool-ng/ct-ng
	$(MAKE) -C crosstool-ng -f ../Makefile _toolchain
else
$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc:
	echo No tollchain and not allowed to build
	exit 1
endif

_toolchain:
	# Set GDB, newlib options before loading ct-ng sample
ifeq ($(CT_LIBC_EN_IO_EXTRA),yes)
	# echo "CT_LIBC_NEWLIB_IO_POS_ARGS=y" >> samples/xtensa-lx106-elf/crosstool.config
	echo "CT_LIBC_NEWLIB_IO_C99FMT=y" >> samples/xtensa-lx106-elf/crosstool.config
	echo "CT_LIBC_NEWLIB_IO_FLOAT=y" >> samples/xtensa-lx106-elf/crosstool.config
	echo "CT_LIBC_NEWLIB_IO_LL=y" >> samples/xtensa-lx106-elf/crosstool.config
	# echo "CT_LIBC_NEWLIB_IO_LDBL=y" >> samples/xtensa-lx106-elf/crosstool.config
endif
ifeq ($(CT_LIBC_EN_REENT),yes)
	echo "CT_LIBC_NEWLIB_REENT_SMALL=y" >> samples/xtensa-lx106-elf/crosstool.config
endif
ifeq ($(CT_EN_GDB),yes)
	echo "CT_DEBUG_GDB=y" >> samples/xtensa-lx106-elf/crosstool.config
endif
	# load sample ct-ng
	./ct-ng xtensa-lx106-elf
	sed -r -i.org s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR="$(TOOLCHAIN)"% .config
	sed -r -i s%CT_PREFIX_DIR_RO=y%"#"CT_PREFIX_DIR_RO=y% .config
	@echo "Setting CT_GCC Version: $(GCC_VERSION)"
	# Clear autogenerated GCC settings
	sed -r -i s%CT_GCC_V_.*=y%% .config
	sed -r -i s%CT_GCC_VERSION=.*%% .config
	sed -r -i s%"# "CT_GCC_V_$(CT_GCC_VERSION)" is not set"%% .config
	# Set GCC version
	echo "CT_GCC_V_$(CT_GCC_VERSION)=y" >> .config
	echo "CT_CC_GCC_V_$(CT_GCC_VERSION)=y" >> .config
	echo "CT_GCC_VERSION=\"$(GCC_VERSION)\"" >> .config
	# Append overrides
	cat ../crosstool-config-overrides >> .config
	# Patches
	cp ../9000-newlib-*.patch local-patches/newlib/2.0.0
	cp ../9000-libgcc-*.patch local-patches/gcc/$(GCC_VERSION)
	# Build
	./ct-ng build

crosstool-ng: crosstool-ng/ct-ng

crosstool-ng/ct-ng: crosstool-ng/bootstrap
	$(MAKE) -C crosstool-ng -f ../Makefile _ct-ng

_ct-ng:
	./bootstrap
	./configure --prefix=`pwd`
	$(MAKE) MAKELEVEL=0
	$(MAKE) install MAKELEVEL=0

crosstool-ng/bootstrap:
	@echo "You cloned without --recursive, fetching submodules for you."
	git submodule update --init --recursive

$(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/libgcc.a.orig: $(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/libgcc.a
	cp strip_libgcc_funcs.txt $(@D)
	cd $(@D); cp -f libgcc.a libgcc.a.orig; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libgcc_funcs.txt; rm strip_libgcc_funcs.txt; cp -f libgcc.a $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libgcc.a;

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a.orig: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a
	cp strip_libc_funcs.txt $(TOOLCHAIN)/xtensa-lx106-elf/lib
	cd $(TOOLCHAIN)/xtensa-lx106-elf/lib; cp -f libc.a libc.a.orig; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libc_funcs.txt; rm strip_libc_funcs.txt; cp -f libc.a $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/libc.a;

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a
	@echo "Creating irom version of libc..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text --rename-section .literal=.irom0.literal $(<) $(@);

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libmirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libm.a
	@echo "Creating irom version of libm..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text --rename-section .literal=.irom0.literal $(<) $(@);

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libhal.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C lx106-hal -f ../Makefile _libhal

_libhal:
	autoreconf -i
	PATH="$(TOOLCHAIN)/bin:$(PATH)" ./configure --host=xtensa-lx106-elf --prefix=$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr CFLAGS="-Os -ffunction-sections -fdata-sections -mlongcalls"
	PATH="$(TOOLCHAIN)/bin:$(PATH)" make
	PATH="$(TOOLCHAIN)/bin:$(PATH)" make install

liblwip: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/liblwip_open.a

$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/liblwip_open.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C esp-open-lwip -f Makefile.open all \
		CC=$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc \
		AR=$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar \
		PREFIX=$(TOOLCHAIN) \
		CFLAGS_EXTRA=-I$(TOP)/sdk/include
	cp esp-open-lwip/liblwip_open.a $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib
	cp -a esp-open-lwip/include/arch esp-open-lwip/include/lwip esp-open-lwip/include/netif esp-open-lwip/include/lwipopts.h \
		$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/

libs: $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libhal.a $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a.orig $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libcirom.a $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libmirom.a $(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/libgcc.a.orig

sdk: .sdk_dir_$(VENDOR_SDK) .sdk_patch_$(VENDOR_SDK)
	ln -snf $(VENDOR_SDK_DIR) sdk
ifeq ($(STANDALONE), y)
	@echo "Installing vendor SDK headers into toolchain sysroot"
	@cp -Rf sdk/include/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/
	@echo "Installing vendor SDK libs into toolchain sysroot"
	@cp -Rf sdk/lib/* $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/
	@echo "Installing vendor SDK linker scripts into toolchain sysroot"
	@sed -e 's/\r//' sdk/ld/eagle.app.v6.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.app.v6.ld
	@sed -e 's/\r//' sdk/ld/eagle.rom.addr.v6.ld >$(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/eagle.rom.addr.v6.ld
else
	cp -Rf $(VENDOR_SDK_DIR) $(TOP)/$(VENDOR_SDK_DIR)
	rm -f $(TOP)/$(VENDOR_SDK_DIR)/lib/libgcc.a
	rm -f $(TOP)/$(VENDOR_SDK_DIR)/lib/libc.a
	ln -snf $(TOP)/$(VENDOR_SDK_DIR) $(TOP)/sdk
endif

lwip2/makefiles/Makefile.defs.orig:
	patch -p 0 -b < 9000-lwip2.patch
	cp -v lwip-err-t.h lwip2/glue-lwip/lwip-err-t.h

lwip2: lwip2/makefiles/Makefile.defs.orig
	$(MAKE) -C lwip2 -f Makefile.open install PREFIX=$(TOOLCHAIN)

lwip2-install:
	$(MAKE) -C lwip2 -f Makefile.open install

lwip2-clean:
	$(MAKE) -C lwip2 -f Makefile.open clean

postbuild:
	@echo "Installing xtensa includes into sysroot"
	@cp -f $(TOP)/lx106-hal/include/xtensa/corebits.h $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/xtensa/

clean-sdk-build:
	rm -f .sdk_dir_$(VENDOR_SDK) .sdk_patch_$(VENDOR_SDK)
	$(shell [[ -L sdk ]] && unlink sdk)
	rm -f $(VENDOR_GIT_ZIP)
	rm -rf $(VENDOR_SDK_DIR)

clean: clean-sdk-build
	rm -f .sdk_patch_$(VENDOR_SDK)
	rm -f user_rf_cal_sector_set.o empty_user_rf_pre_init.o
	$(MAKE) -C esp-open-lwip -f Makefile.open clean
	$(MAKE) -C lwip2 -f Makefile.open clean PREFIX=$(TOOLCHAIN)
	rm -f .sdk_dir_$(VENDOR_SDK)

distclean: clean
	$(MAKE) -C crosstool-ng clean MAKELEVEL=0
	(cd crosstool-ng; git checkout -- samples/xtensa-lx106-elf/crosstool.config; cd ..)
	-rm -f crosstool-ng/.config.org
	-rm -rf crosstool-ng/lib
	-rm -rf crosstool-ng/share
	rm -rf crosstool-ng/local-patches/*/*/9000-*

fullclean: distclean
	-rm -rf crosstool-ng/.build

empty_user_rf_pre_init.o: empty_user_rf_pre_init.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

user_rf_cal_sector_set.o: user_rf_cal_sector_set.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

.sdk_dir_$(VENDOR_SDK): $(VENDOR_SDK_ZIP)
	-mv -f $(VENDOR_ZIP_DIR) $(VENDOR_SDK_DIR)
	@touch $@

.sdk_patch_master: user_rf_cal_sector_set.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 020100" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	printf '\n%s "%s"' '#define ESP8266_NONOS_SDK_SHA' "$(VENDOR_FULL_SHA)" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99_sdk_2.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR)/lib/libmain.a user_rf_cal_sector_set.o
	@touch $@

ESP8266_NONOS_SDK-master.zip:
	wget --content-disposition "$(VENDOR_ZIP_DL_URI)"
	rm -rf 'ESP8266_NONOS_SDK-master/*'
	mkdir -p 'ESP8266_NONOS_SDK-master'
	unzip $(VENDOR_GIT_ZIP)
	cp -a ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA)/* ESP8266_NONOS_SDK-master/
	rm -rf ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA)
