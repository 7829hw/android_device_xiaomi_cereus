#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=cereus
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/etc/init/atcid.rc|\
        vendor/etc/init/em_hidl_user.rc|\
        vendor/etc/init/loghidlvendorservice.rc|\
        vendor/etc/init/md_monitor.rc|\
        vendor/etc/init/vendor.mediatek.hardware.log@1.0-service.rc)
            # host_init_verifier rejects interfaces it has no HIDL definition for
            sed -i '/^\s*interface vendor\.mediatek\./d' "${2}"
            ;;
        vendor/etc/init/vendor.mediatek.hardware.keymaster_attestation@1.1-service.rc|\
        vendor/etc/init/vendor.mediatek.hardware.mms@1.5-service.rc)
            # Without interface lines these lazy HALs can no longer be started
            # on demand, so start them with their class instead
            sed -i -e '/^\s*interface vendor\.mediatek\./d' -e '/^\s*disabled/d' -e '/^\s*oneshot/d' -e '$a\' "${2}"
            ;;
        vendor/etc/init/lbs_hidl_service.rc)
            sed -i 's/\r$//' "${2}"
            ;;
        vendor/lib/libaedv.so|vendor/lib64/libaedv.so|\
        vendor/lib/libladder.so|vendor/lib64/libladder.so|\
        vendor/lib/libudf.so|vendor/lib64/libudf.so)
            "${PATCHELF}" --replace-needed "libunwindstack.so" "libunwindstack-v29.so" "${2}"
            ;;
        vendor/lib/hw/android.hardware.audio@5.0-impl-mediatek.so|vendor/lib64/hw/android.hardware.audio@5.0-impl-mediatek.so|\
        vendor/lib/hw/audio.primary.mt6765.so|vendor/lib64/hw/audio.primary.mt6765.so|\
        vendor/lib/hw/sound_trigger.primary.mt6765.so|vendor/lib64/hw/sound_trigger.primary.mt6765.so|\
        vendor/lib/libaudioprimarydevicehalifclient.so|vendor/lib64/libaudioprimarydevicehalifclient.so|\
        vendor/lib/libspeechparser_vendor.so|vendor/lib64/libspeechparser_vendor.so)
            "${PATCHELF}" --replace-needed "libmedia_helper.so" "libmedia_helper-v29.so" "${2}"
            ;;
        vendor/lib/libmtkcam_stdutils.so|vendor/lib64/libmtkcam_stdutils.so)
            "${PATCHELF}" --add-needed "libshim_propertymap.so" "${2}"
            ;;
        vendor/lib/libwvhidl.so|vendor/lib64/libwvhidl.so|\
        vendor/lib/mediadrm/libwvdrmengine.so|vendor/lib64/mediadrm/libwvdrmengine.so)
            "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
