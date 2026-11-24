/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "vendor.mediatek.hardware.power@2.1-service"

#include <hidl/HidlTransportSupport.h>
#include <hidl/LegacySupport.h>
#include <log/log.h>

using android::OK;
using android::status_t;
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;
using android::hardware::registerPassthroughServiceImplementation;

// Serve the prebuilt vendor.mediatek.hardware.power@2.1-impl over hwbinder.
// The camera HAL waits for this IPower before it registers its provider.
int main() {
    configureRpcThreadpool(1, true /* callerWillJoin */);

    status_t status = registerPassthroughServiceImplementation(
            "vendor.mediatek.hardware.power@2.1::IPower", "default");
    if (status != OK) {
        ALOGE("Could not register IPower: %d", status);
        return 1;
    }

    joinRpcThreadpool();
    return 1;
}
