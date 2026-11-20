/*
 * Copyright (C) 2008 The Android Open Source Project
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 * android::PropertyMap used to be part of libutils. The Android 10 MTK
 * camera stack (libmtkcam_stdutils) still links against it there, but on
 * Android 12 it lives in libinput, which vendor code cannot use.
 *
 * Provide the subset the blobs need. The class layout (a single
 * KeyedVector<String8, String8>) is unchanged since Android 10, so this
 * is ABI compatible. Parsing from files is not needed and left out.
 */

#define LOG_TAG "PropertyMap"

#include <stdlib.h>

#include <log/log.h>
#include <utils/KeyedVector.h>
#include <utils/String8.h>

namespace android {

class PropertyMap {
  public:
    PropertyMap();
    ~PropertyMap();

    void clear();
    void addProperty(const String8& key, const String8& value);
    bool hasProperty(const String8& key) const;
    bool tryGetProperty(const String8& key, String8& outValue) const;
    bool tryGetProperty(const String8& key, bool& outValue) const;
    bool tryGetProperty(const String8& key, int32_t& outValue) const;
    bool tryGetProperty(const String8& key, float& outValue) const;
    void addAll(const PropertyMap* map);

  private:
    KeyedVector<String8, String8> mProperties;
};

PropertyMap::PropertyMap() {}

PropertyMap::~PropertyMap() {}

void PropertyMap::clear() {
    mProperties.clear();
}

void PropertyMap::addProperty(const String8& key, const String8& value) {
    mProperties.add(key, value);
}

bool PropertyMap::hasProperty(const String8& key) const {
    return mProperties.indexOfKey(key) >= 0;
}

bool PropertyMap::tryGetProperty(const String8& key, String8& outValue) const {
    ssize_t index = mProperties.indexOfKey(key);
    if (index < 0) {
        return false;
    }

    outValue = mProperties.valueAt(index);
    return true;
}

bool PropertyMap::tryGetProperty(const String8& key, bool& outValue) const {
    int32_t intValue;
    if (!tryGetProperty(key, intValue)) {
        return false;
    }

    outValue = intValue;
    return true;
}

bool PropertyMap::tryGetProperty(const String8& key, int32_t& outValue) const {
    String8 stringValue;
    if (!tryGetProperty(key, stringValue) || stringValue.length() == 0) {
        return false;
    }

    char* end;
    int value = strtol(stringValue.string(), &end, 10);
    if (*end != '\0') {
        ALOGW("Property key '%s' has invalid value '%s'.  Expected an integer.", key.string(),
              stringValue.string());
        return false;
    }
    outValue = value;
    return true;
}

bool PropertyMap::tryGetProperty(const String8& key, float& outValue) const {
    String8 stringValue;
    if (!tryGetProperty(key, stringValue) || stringValue.length() == 0) {
        return false;
    }

    char* end;
    float value = strtof(stringValue.string(), &end);
    if (*end != '\0') {
        ALOGW("Property key '%s' has invalid value '%s'.  Expected a float.", key.string(),
              stringValue.string());
        return false;
    }
    outValue = value;
    return true;
}

void PropertyMap::addAll(const PropertyMap* map) {
    for (size_t i = 0; i < map->mProperties.size(); i++) {
        mProperties.add(map->mProperties.keyAt(i), map->mProperties.valueAt(i));
    }
}

}  // namespace android
