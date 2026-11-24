/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <string>
#include <string_view>

#include <android-base/file.h>

namespace android {
namespace base {

// libbase now takes std::string_view; the vendor libnvram was built against
// the older const std::string& overloads.
std::string Basename(const std::string& path) {
    return Basename(std::string_view(path));
}

std::string Dirname(const std::string& path) {
    return Dirname(std::string_view(path));
}

}  // namespace base
}  // namespace android
