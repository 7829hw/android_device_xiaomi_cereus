/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "vendor.mediatek.hardware.mtkcodecservice@1.1-service"

#include <hidl/HidlTransportSupport.h>
#include <hidl/ServiceManagement.h>
#include <log/log.h>

using android::OK;
using android::sp;
using android::status_t;
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;
using android::hardware::details::getRawServiceInternal;
using android::hardware::details::registerAsServiceInternal;
using android::hidl::base::V1_0::IBase;

/*
 * The prebuilt service registers the passthrough implementation lazily.
 * Its interface library was generated for Android 10 and its stub lacks
 * the checkSubclass() override that libhidlbase now needs to recognise
 * the service in its client callback, so the service aborts as soon as
 * it gets a client. Register the same implementation as a regular,
 * always running service instead. The interface headers are not
 * available, so go through the descriptor.
 */
static constexpr char kDescriptor[] =
        "vendor.mediatek.hardware.mtkcodecservice@1.1::IMtkCodecService";
static constexpr char kInstance[] = "default";

int main() {
    configureRpcThreadpool(1, true /* callerWillJoin */);

    sp<IBase> service =
            getRawServiceInternal(kDescriptor, kInstance, true /* retry */, true /* getStub */);
    if (service == nullptr) {
        ALOGE("Could not get passthrough implementation for %s/%s", kDescriptor, kInstance);
        return 1;
    }

    status_t status = registerAsServiceInternal(service, kInstance);
    if (status != OK) {
        ALOGE("Could not register %s/%s: %d", kDescriptor, kInstance, status);
        return 1;
    }

    joinRpcThreadpool();
    return 1;  // joinRpcThreadpool() should never return
}
