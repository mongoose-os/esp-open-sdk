
# Whether to merge SDK into Xtensa toolchain, producing standalone
# ESP8266 toolchain. Use 'n' if you want generic Xtensa toolchain
# which can be used with multiple SDK versions.
STANDALONE = y

# NOTE: 4.8.5 has failing patches and 5.2.0 fails at GCC compile
# GCC_VERSION = 4.8.5
# GCC_VERSION = 5.2.0

# GCC_VERSION = 6.4.0
GCC_VERSION = 7.3.0
CT_GCC_VERSION = $(shell echo $(GCC_VERSION) | sed -e 's/\./_/g')

# Directory to install toolchain to, by default inside current dir.
TOOLCHAIN = $(TOP)/xtensa-lx106-elf

# NOTE: Leave this as-is and use full shas above to simplfiy things.
# Instead of all the makefile hacks that break every time, just
# always call it master, then d/l the SDK as a zip based on SHA.
VENDOR_SDK = master

########################### SDK Commit List ############################
## Pre-Krack      - 10aea1782b2cac518a1a30eb8b4e046ed76c8d7c           #
## Krack patch    - 61248df5f6d45d130313b412f7492f581fd4cadf           #
## master@10d7772 - 10d777260264f658965c5f323ae7f6741074d50e           #
## master@4899e50 - 4671b17cc9fc6ed6787c2d310daf8accccf29c8d           #
## master@4899e50 - 0e2308ff41578f6ad9a73f805ac4a441747d2a8e           #
## master@cab958d - 779294b0a220a6bd72c73963d890c2f1d9116b5e           #
## ------------------------- v2.2.0 release -------------------------- #
## master@fcdedd6 - f2c63854331c8d46f7ffe944f6697ab204a54379 <-- curr. #
########################################################################

REPO_TAG          :=v2.2.1
VENDOR_FULL_SHA   :=3ea90190d3092131505c97ac0ddb41d5e8bedefc
VENDOR_GIT_ZIP    :="ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA).zip"
VENDOR_ZIP_DL_URI :="https://github.com/someburner/ESP8266_NONOS_SDK/releases/download/$(REPO_TAG)/$(VENDOR_GIT_ZIP)"

.PHONY: crosstool-ng esptool toolchain _libhal libs sdk liblwip postbuild

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
VENDOR_SDK_ZIP_2.1.0 = ESP8266_NONOS_SDK-2.1.0.zip
VENDOR_ZIP_DIR_2.1.0 = ESP8266_NONOS_SDK-2.1.0
VENDOR_SDK_DIR_2.1.0 = esp_nonos_sdk_v2.1.0
VENDOR_SDK_ZIP_2.0.0 = ESP8266_NONOS_SDK_V2.0.0_16_08_10.zip
VENDOR_ZIP_DIR_2.0.0 = ESP8266_NONOS_SDK_V2.0.0_16_08_10
VENDOR_SDK_DIR_2.0.0 = esp_nonos_sdk_v2.0.0
VENDOR_SDK_ZIP_1.5.4 = ESP8266_NONOS_SDK_V1.5.4_16_05_20.zip
VENDOR_ZIP_DIR_1.5.4 = ESP8266_NONOS_SDK_V1.5.4_16_05_20
VENDOR_SDK_DIR_1.5.4 = esp_nonos_sdk_v1.5.4
VENDOR_SDK_ZIP_1.5.3 = ESP8266_NONOS_SDK_V1.5.3_16_04_18.zip
VENDOR_ZIP_DIR_1.5.3 = ESP8266_NONOS_SDK_V1.5.3_16_04_18/ESP8266_NONOS_SDK
VENDOR_SDK_DIR_1.5.3 = esp_nonos_sdk_v1.5.3
VENDOR_SDK_ZIP_1.5.2 = ESP8266_NONOS_SDK_V1.5.2_16_01_29.zip
VENDOR_SDK_DIR_1.5.2 = esp_iot_sdk_v1.5.2
VENDOR_SDK_ZIP_1.5.1 = ESP8266_NONOS_SDK_V1.5.1_16_01_08.zip
VENDOR_SDK_DIR_1.5.1 = esp_iot_sdk_v1.5.1
VENDOR_SDK_ZIP_1.5.0 = esp_iot_sdk_v1.5.0_15_11_27.zip
VENDOR_SDK_DIR_1.5.0 = esp_iot_sdk_v1.5.0
VENDOR_SDK_ZIP_1.4.0 = esp_iot_sdk_v1.4.0_15_09_18.zip
VENDOR_SDK_DIR_1.4.0 = esp_iot_sdk_v1.4.0
VENDOR_SDK_ZIP_1.3.0 = esp_iot_sdk_v1.3.0_15_08_08.zip
VENDOR_SDK_DIR_1.3.0 = esp_iot_sdk_v1.3.0
VENDOR_SDK_ZIP_1.2.0 = esp_iot_sdk_v1.2.0_15_07_03.zip
VENDOR_SDK_DIR_1.2.0 = esp_iot_sdk_v1.2.0
VENDOR_SDK_ZIP_1.1.2 = esp_iot_sdk_v1.1.2_15_06_12.zip
VENDOR_SDK_DIR_1.1.2 = esp_iot_sdk_v1.1.2
VENDOR_SDK_ZIP_1.1.1 = esp_iot_sdk_v1.1.1_15_06_05.zip
VENDOR_SDK_DIR_1.1.1 = esp_iot_sdk_v1.1.1
VENDOR_SDK_ZIP_1.1.0 = esp_iot_sdk_v1.1.0_15_05_26.zip
VENDOR_SDK_DIR_1.1.0 = esp_iot_sdk_v1.1.0
# MIT-licensed version was released without changing version number
#VENDOR_SDK_ZIP_1.1.0 = esp_iot_sdk_v1.1.0_15_05_22.zip
#VENDOR_SDK_DIR_1.1.0 = esp_iot_sdk_v1.1.0
VENDOR_SDK_ZIP_1.0.1 = esp_iot_sdk_v1.0.1_15_04_24.zip
VENDOR_SDK_DIR_1.0.1 = esp_iot_sdk_v1.0.1
VENDOR_SDK_ZIP_1.0.1b2 = esp_iot_sdk_v1.0.1_b2_15_04_10.zip
VENDOR_SDK_DIR_1.0.1b2 = esp_iot_sdk_v1.0.1_b2
VENDOR_SDK_ZIP_1.0.1b1 = esp_iot_sdk_v1.0.1_b1_15_04_02.zip
VENDOR_SDK_DIR_1.0.1b1 = esp_iot_sdk_v1.0.1_b1
VENDOR_SDK_ZIP_1.0.0 = esp_iot_sdk_v1.0.0_15_03_20.zip
VENDOR_SDK_DIR_1.0.0 = esp_iot_sdk_v1.0.0
VENDOR_SDK_ZIP_0.9.6b1 = esp_iot_sdk_v0.9.6_b1_15_02_15.zip
VENDOR_SDK_DIR_0.9.6b1 = esp_iot_sdk_v0.9.6_b1
VENDOR_SDK_ZIP_0.9.5 = esp_iot_sdk_v0.9.5_15_01_23.zip
VENDOR_SDK_DIR_0.9.5 = esp_iot_sdk_v0.9.5
VENDOR_SDK_ZIP_0.9.4 = esp_iot_sdk_v0.9.4_14_12_19.zip
VENDOR_SDK_DIR_0.9.4 = esp_iot_sdk_v0.9.4
VENDOR_SDK_ZIP_0.9.3 = esp_iot_sdk_v0.9.3_14_11_21.zip
VENDOR_SDK_DIR_0.9.3 = esp_iot_sdk_v0.9.3
VENDOR_SDK_ZIP_0.9.2 = esp_iot_sdk_v0.9.2_14_10_24.zip
VENDOR_SDK_DIR_0.9.2 = esp_iot_sdk_v0.9.2

all: toolchain esptool sdk libs liblwip postbuild
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
#	cp strip_libgcc_funcs.txt $(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/
#	cd $(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libgcc_funcs.txt; rm strip_libgcc_funcs.txt
#	cp strip_libc_funcs.txt $(TOOLCHAIN)/xtensa-lx106-elf/lib
#	cd $(TOOLCHAIN)/xtensa-lx106-elf/lib; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libc_funcs.txt; rm strip_libc_funcs.txt

$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc: crosstool-ng/ct-ng
	$(MAKE) -C crosstool-ng -f ../Makefile _toolchain

_toolchain:
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
	cd $(@D); cp -f libgcc.a libgcc.a.orig; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libgcc_funcs.txt; rm strip_libgcc_funcs.txt

$(TOOLCHAIN)/xtensa-lx106-elf/lib/libc.a.orig: $(TOOLCHAIN)/xtensa-lx106-elf/lib/libc.a
	cp strip_libc_funcs.txt $(TOOLCHAIN)/xtensa-lx106-elf/lib
	cd $(TOOLCHAIN)/xtensa-lx106-elf/lib; cp -f libc.a libc.a.orig; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar -M < strip_libc_funcs.txt; rm strip_libc_funcs.txt

$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libcirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/lib/libc.a
	@echo "Creating irom version of libc..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text --rename-section .literal=.irom0.literal $(<) $(@);

$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libmirom.a: $(TOOLCHAIN)/xtensa-lx106-elf/lib/libm.a
	@echo "Creating irom version of libm..."
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-objcopy --rename-section .text=.irom0.text --rename-section .literal=.irom0.literal $(<) $(@);

$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libhal.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C lx106-hal -f ../Makefile _libhal

_libhal:
	autoreconf -i
	PATH="$(TOOLCHAIN)/bin:$(PATH)" ./configure --host=xtensa-lx106-elf --prefix=$(TOOLCHAIN)/xtensa-lx106-elf/usr
	PATH="$(TOOLCHAIN)/bin:$(PATH)" make
	PATH="$(TOOLCHAIN)/bin:$(PATH)" make install

liblwip: $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/liblwip_open.a

$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/liblwip_open.a: $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	make -C esp-open-lwip -f Makefile.open all \
		CC=$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc \
		AR=$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar \
		PREFIX=$(TOOLCHAIN) \
		CFLAGS_EXTRA=-I$(TOP)/sdk/include
	cp esp-open-lwip/liblwip_open.a $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib
	cp -a esp-open-lwip/include/arch esp-open-lwip/include/lwip esp-open-lwip/include/netif esp-open-lwip/include/lwipopts.h \
		$(TOOLCHAIN)/xtensa-lx106-elf/usr/include/
	cp -a esp-open-lwip/include/arch esp-open-lwip/include/lwip esp-open-lwip/include/netif esp-open-lwip/include/lwipopts.h \
		$(TOOLCHAIN)/xtensa-lx106-elf/sys-include/

libs: $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libhal.a $(TOOLCHAIN)/xtensa-lx106-elf/lib/libc.a.orig $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libcirom.a $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libmirom.a $(TOOLCHAIN)/lib/gcc/xtensa-lx106-elf/$(GCC_VERSION)/libgcc.a.orig

sdk: .sdk_dir_$(VENDOR_SDK) .sdk_patch_$(VENDOR_SDK)
	ln -snf $(VENDOR_SDK_DIR) sdk
ifeq ($(STANDALONE), y)
	@echo "Installing vendor SDK headers into toolchain"
	@mkdir -p $(TOOLCHAIN)/xtensa-lx106-elf/usr/include
	@cp -Rf sdk/include/* $(TOOLCHAIN)/xtensa-lx106-elf/usr/include/
	@echo "Installing vendor SDK libs into toolchain"
	@cp -Rf $(VENDOR_SDK_DIR)/lib/* $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/
	@rm -f $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libgcc.a
	@rm -f $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libc.a
	@echo "Installing vendor SDK linker scripts into toolchain"
	@sed -e 's/\r//' $(VENDOR_SDK_DIR)/ld/eagle.app.v6.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/eagle.app.v6.ld
	@sed -e 's/\r//' $(VENDOR_SDK_DIR)/ld/eagle.rom.addr.v6.ld >$(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/eagle.rom.addr.v6.ld
else
	cp -Rf $(VENDOR_SDK_DIR) $(TOP)/$(VENDOR_SDK_DIR)
	rm -f $(TOP)/$(VENDOR_SDK_DIR)/lib/libgcc.a
	rm -f $(TOP)/$(VENDOR_SDK_DIR)/lib/libc.a
	ln -snf $(TOP)/$(VENDOR_SDK_DIR) $(TOP)/sdk
endif

postbuild:
	@echo "Installing vendor SDK headers into sysroot"
	@cp -f sdk/include/c_types.h $(TOOLCHAIN)/xtensa-lx106-elf/sys-include/
	@cp -f $(TOP)/esp-open-lwip/include/lwipopts.h $(TOOLCHAIN)/xtensa-lx106-elf/sys-include/
	@cp -Rf $(TOOLCHAIN)/xtensa-lx106-elf/usr/include/lwip $(TOOLCHAIN)/xtensa-lx106-elf/sys-include/
	@cp -Rf $(TOOLCHAIN)/xtensa-lx106-elf/usr/include/arch $(TOOLCHAIN)/xtensa-lx106-elf/sys-include/
	@cp -Rf $(TOOLCHAIN)/xtensa-lx106-elf/usr/include/xtensa/* $(TOOLCHAIN)/xtensa-lx106-elf/sys-include/xtensa/
	@echo "Installing vendor SDK libs into sysroot"
	@cp -f $(TOOLCHAIN)/xtensa-lx106-elf/usr/lib/libhal.a $(TOOLCHAIN)/xtensa-lx106-elf/lib/libhal.a

clean-sdk-build:
	rm -f .sdk_dir_$(VENDOR_SDK) .sdk_patch_$(VENDOR_SDK)
	$(shell [[ -L sdk ]] && unlink sdk)
	rm -f $(VENDOR_GIT_ZIP)
	rm -rf $(VENDOR_SDK_DIR)

clean: clean-sdk-build
	rm -f .sdk_patch_$(VENDOR_SDK)
	rm -f user_rf_cal_sector_set.o empty_user_rf_pre_init.o
	$(MAKE) -C esp-open-lwip -f Makefile.open clean
	rm -f .sdk_dir_$(VENDOR_SDK)

distclean: clean
	$(MAKE) -C crosstool-ng clean MAKELEVEL=0
	-rm -f crosstool-ng/.config.org
	-rm -rf crosstool-ng/lib
	-rm -rf crosstool-ng/share
	-rm -rf crosstool-ng/.build/src
	-rm -rf $(TOOLCHAIN)

empty_user_rf_pre_init.o: empty_user_rf_pre_init.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

user_rf_cal_sector_set.o: user_rf_cal_sector_set.c $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(VENDOR_SDK_DIR)
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc -O2 -I$(VENDOR_SDK_DIR)/include -c $<

.sdk_dir_$(VENDOR_SDK): $(VENDOR_SDK_ZIP)
	-mv -f $(VENDOR_ZIP_DIR) $(VENDOR_SDK_DIR)
	-mv License $(VENDOR_SDK_DIR)
	@touch $@

.sdk_patch_master: user_rf_cal_sector_set.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 020100" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99_sdk_2.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR)/lib/libmain.a user_rf_cal_sector_set.o
	@touch $@

.sdk_patch_2.0.0: ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip user_rf_cal_sector_set.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 020000" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip
	mv libmain.a libnet80211.a libpp.a $(VENDOR_SDK_DIR_2.0.0)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99_sdk_2.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR)/lib/libmain.a user_rf_cal_sector_set.o
	@touch $@

.sdk_patch_1.5.4:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010504" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.3:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010503" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.2: Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010502" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip
	mv libssl.a libnet80211.a libmain.a $(VENDOR_SDK_DIR_1.5.2)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.1:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010501" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.5.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010500" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	cd $(VENDOR_SDK_DIR)/lib; mkdir -p tmp; cd tmp; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar x ../libcrypto.a; cd ..; $(TOOLCHAIN)/bin/xtensa-lx106-elf-ar rs libwpa.a tmp/*.o
	@touch $@

.sdk_patch_1.4.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010400" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < dhcps_lease.patch
	@touch $@

.sdk_patch_1.3.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010300" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.2.0: lib_mem_optimize_150714.zip libssl_patch_1.2.0-2.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010200" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	#$(UNZIP) libssl_patch_1.2.0-2.zip
	#$(UNZIP) libsmartconfig_2.4.2.zip
	$(UNZIP) lib_mem_optimize_150714.zip
	#mv libsmartconfig_2.4.2.a $(VENDOR_SDK_DIR_1.2.0)/lib/libsmartconfig.a
	mv libssl.a libnet80211.a libpp.a libsmartconfig.a $(VENDOR_SDK_DIR_1.2.0)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.2.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.2: scan_issue_test.zip 1.1.2_patch_02.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010102" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) scan_issue_test.zip
	$(UNZIP) 1.1.2_patch_02.zip
	mv libmain.a libnet80211.a libpp.a $(VENDOR_SDK_DIR_1.1.2)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.2)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.1: empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010101" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.1)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.1.0: lib_patch_on_sdk_v1.1.0.zip empty_user_rf_pre_init.o
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010100" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libsmartconfig_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libsmartconfig.a
	mv libmain_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a
	mv libssl_patch_01.a $(VENDOR_SDK_DIR_1.1.0)/lib/libssl.a
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	$(TOOLCHAIN)/bin/xtensa-lx106-elf-ar r $(VENDOR_SDK_DIR_1.1.0)/lib/libmain.a empty_user_rf_pre_init.o
	@touch $@

.sdk_patch_1.0.1: libnet80211.zip esp_iot_sdk_v1.0.1/.dir
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libnet80211.a $(VENDOR_SDK_DIR_1.0.1)/lib/
	$(PATCH) -f -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b2: libssl.zip esp_iot_sdk_v1.0.1_b2/.dir
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(UNZIP) $<
	mv libssl/libssl.a $(VENDOR_SDK_DIR_1.0.1b2)/lib/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.1b1:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010001" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_1.0.0:
	echo -e "#undef ESP_SDK_VERSION\n#define ESP_SDK_VERSION 010000" >>$(VENDOR_SDK_DIR)/include/esp_sdk_ver.h
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.6b1:
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.5: sdk095_patch1.zip esp_iot_sdk_v0.9.5/.dir
	$(UNZIP) $<
	mv libmain_fix_0.9.5.a $(VENDOR_SDK_DIR)/lib/libmain.a
	mv user_interface.h $(VENDOR_SDK_DIR)/include/
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.4:
	$(PATCH) -d $(VENDOR_SDK_DIR) -p1 < c_types-c99.patch
	@touch $@

.sdk_patch_0.9.3: esp_iot_sdk_v0.9.3_14_11_21_patch1.zip esp_iot_sdk_v0.9.3/.dir
	$(UNZIP) $<
	@touch $@

.sdk_patch_0.9.2: FRM_ERR_PATCH.rar esp_iot_sdk_v0.9.2/.dir
	unrar x -o+ $<
	cp FRM_ERR_PATCH/*.a $(VENDOR_SDK_DIR)/lib/
	@touch $@

#######################################################################################################
# Presumes VENDOR_FULL_SHA is >= the SDK version
#######################################################################################################
ESP8266_NONOS_SDK-master.zip:
	wget --content-disposition "$(VENDOR_ZIP_DL_URI)"
	rm -rf 'ESP8266_NONOS_SDK-master/*'
	mkdir -p 'ESP8266_NONOS_SDK-master'
	unzip $(VENDOR_GIT_ZIP)
	cp -a ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA)/* ESP8266_NONOS_SDK-master/
	rm -rf ESP8266_NONOS_SDK-$(VENDOR_FULL_SHA)

#######################################################################################################
ESP8266_NONOS_SDK-2.1.0.zip:
	wget --content-disposition "https://github.com/espressif/ESP8266_NONOS_SDK/archive/v2.1.0.zip"
# The only change wrt to ESP8266_NONOS_SDK_V2.0.0_16_07_19.zip is licensing blurb in source/
# header files. Libs are the same (and patch is required just the same).
ESP8266_NONOS_SDK_V2.0.0_16_08_10.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1690"
ESP8266_NONOS_SDK_V2.0.0_16_07_19.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1613"
ESP8266_NONOS_SDK_V1.5.4_16_05_20.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1469"
ESP8266_NONOS_SDK_V1.5.3_16_04_18.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1361"
ESP8266_NONOS_SDK_V1.5.2_16_01_29.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1079"
ESP8266_NONOS_SDK_V1.5.1_16_01_08.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1046"
esp_iot_sdk_v1.5.0_15_11_27.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=989"
esp_iot_sdk_v1.4.0_15_09_18.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=838"
esp_iot_sdk_v1.3.0_15_08_08.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=664"
esp_iot_sdk_v1.2.0_15_07_03.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=564"
esp_iot_sdk_v1.1.2_15_06_12.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=521"
esp_iot_sdk_v1.1.1_15_06_05.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=484"
esp_iot_sdk_v1.1.0_15_05_26.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=425"
esp_iot_sdk_v1.1.0_15_05_22.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=423"
esp_iot_sdk_v1.0.1_15_04_24.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=325"
esp_iot_sdk_v1.0.1_b2_15_04_10.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=293"
esp_iot_sdk_v1.0.1_b1_15_04_02.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=276"
esp_iot_sdk_v1.0.0_15_03_20.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=250"
esp_iot_sdk_v0.9.6_b1_15_02_15.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=220"
esp_iot_sdk_v0.9.5_15_01_23.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=189"
esp_iot_sdk_v0.9.4_14_12_19.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=111"
esp_iot_sdk_v0.9.3_14_11_21.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=72"
esp_iot_sdk_v0.9.2_14_10_24.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=9"

FRM_ERR_PATCH.rar:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=10"
esp_iot_sdk_v0.9.3_14_11_21_patch1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=73"
sdk095_patch1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=190"
libssl.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=316"
libnet80211.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=361"
lib_patch_on_sdk_v1.1.0.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=432"
scan_issue_test.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=525"
1.1.2_patch_02.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=546"
libssl_patch_1.2.0-1.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=583" -O $@
libssl_patch_1.2.0-2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=586" -O $@
libsmartconfig_2.4.2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=585"
lib_mem_optimize_150714.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=594"
Patch01_for_ESP8266_NONOS_SDK_V1.5.2.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1168"
ESP8266_NONOS_SDK_V2.0.0_patch_16_08_09.zip:
	wget --content-disposition "http://bbs.espressif.com/download/file.php?id=1654"
