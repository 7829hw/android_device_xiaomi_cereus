#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# LK boots the header dtb only when it is a DT table holding the mt6765
# base dtb, the format of the stock ALPS boot.img. Build that instead of
# the default concatenation of every dtb, which puts the certus overlay
# first.

CEREUS_MKDTBOIMG := $(HOST_OUT_EXECUTABLES)/mkdtboimg$(HOST_EXECUTABLE_SUFFIX)
CEREUS_BASE_DTB := $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts/mediatek/mt6765.dtb

$(DTB_OUT):
	mkdir -p $(DTB_OUT)

$(INSTALLED_DTBIMAGE_TARGET): $(DTC) $(CEREUS_MKDTBOIMG) $(DTB_OUT)
	@echo "Building dtb.img"
	$(hide) find $(DTB_OUT)/arch/$(KERNEL_ARCH)/boot/dts -type f -name "*.dtb" | xargs rm -f
	$(call make-dtb-target,$(KERNEL_DEFCONFIG))
	$(call make-dtb-target,mediatek/mt6765.dtb)
	$(CEREUS_MKDTBOIMG) create $@ --page_size=$(BOARD_KERNEL_PAGESIZE) $(CEREUS_BASE_DTB)
	$(hide) touch -c $(DTB_OUT)
