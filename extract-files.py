#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/xiaomi/cereus',
    'hardware/mediatek',
]

blob_fixups: blob_fixups_user_type = {
    (
        'vendor/etc/init/atcid.rc',
        'vendor/etc/init/em_hidl_user.rc',
        'vendor/etc/init/loghidlvendorservice.rc',
        'vendor/etc/init/md_monitor.rc',
        'vendor/etc/init/vendor.mediatek.hardware.log@1.0-service.rc',
    ): blob_fixup()
        # host_init_verifier rejects interfaces it has no HIDL definition for
        .regex_replace(r'(?m)^\s*interface vendor\.mediatek\..*\n', ''),
    (
        'vendor/etc/init/vendor.mediatek.hardware.keymaster_attestation@1.1-service.rc',
        'vendor/etc/init/vendor.mediatek.hardware.mms@1.5-service.rc',
    ): blob_fixup()
        # Without interface lines these lazy HALs can no longer be started
        # on demand, so start them with their class instead
        .regex_replace(r'(?m)^\s*(interface vendor\.mediatek\.|disabled|oneshot).*\n', '')
        .regex_replace(r'([^\n])\Z', '\\1\n'),
    'vendor/bin/mnld': blob_fixup()
        # The MediaTek GNSS library, not external/libmnl
        .replace_needed('libmnl.so', 'libmnl_mtk.so')
        .add_needed('libshim_sensors.so'),
    'vendor/lib64/libcam.utils.sensorprovider.so': blob_fixup()
        .add_needed('libshim_sensors.so'),
    (
        'vendor/lib/libnvram.so',
        'vendor/lib/libsysenv.so',
        'vendor/lib64/libnvram.so',
        'vendor/lib64/libsysenv.so',
    ): blob_fixup()
        .add_needed('libshim_base.so'),
    'vendor/etc/init/lbs_hidl_service.rc': blob_fixup()
        .regex_replace('\r\n', '\n'),
    (
        'vendor/lib/libudf.so',
        'vendor/lib64/libudf.so',
    ): blob_fixup()
        .replace_needed('libunwindstack.so', 'libunwindstack-v29.so'),
    (
        'vendor/lib/libaudioprimarydevicehalifclient.so',
        'vendor/lib/libspeechparser_vendor.so',
        'vendor/lib64/libaudioprimarydevicehalifclient.so',
        'vendor/lib64/libspeechparser_vendor.so',
    ): blob_fixup()
        .replace_needed('libmedia_helper.so', 'libmedia_helper-v29.so'),
    (
        'vendor/lib/hw/audio.primary.mt6765.so',
        'vendor/lib/hw/sound_trigger.primary.mt6765.so',
        'vendor/lib64/hw/audio.primary.mt6765.so',
        'vendor/lib64/hw/sound_trigger.primary.mt6765.so',
    ): blob_fixup()
        .replace_needed('libmedia_helper.so', 'libmedia_helper-v29.so')
        .remove_needed('android.hardware.bluetooth.a2dp@1.0.so'),
    (
        'vendor/lib/libmtkcam_stdutils.so',
        'vendor/lib64/libmtkcam_stdutils.so',
    ): blob_fixup()
        .add_needed('libshim_propertymap.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'cereus',
    'xiaomi',
    namespace_imports=namespace_imports,
    blob_fixups=blob_fixups,
    add_firmware_proprietary_file=False,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
