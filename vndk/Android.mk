#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Android 10 (VNDK 29) copies of VNDK libraries whose ABI changed in
# Android 12. Blobs are pointed at them with patchelf in extract-files.sh.

LOCAL_PATH := prebuilts/vndk/v29/arm64

define cereus-vndk29-prebuilt
include $$(CLEAR_VARS)
LOCAL_MODULE := $(1)-v29
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_MULTILIB := both
LOCAL_SRC_FILES_arm := arch-arm-armv8-a/shared/$(2)/$(1).so
LOCAL_SRC_FILES_arm64 := arch-arm64-armv8-a/shared/$(2)/$(1).so
LOCAL_MODULE_TARGET_ARCH := arm arm64
LOCAL_CHECK_ELF_FILES := false
LOCAL_VENDOR_MODULE := true
include $$(BUILD_PREBUILT)
endef

$(eval $(call cereus-vndk29-prebuilt,libmedia_helper,vndk-core))
$(eval $(call cereus-vndk29-prebuilt,libprotobuf-cpp-lite,vndk-core))
$(eval $(call cereus-vndk29-prebuilt,libunwindstack,vndk-sp))
