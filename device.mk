# Copyright (C) 2013-2016 The CyanogenMod Project
# Copyright (C) 2017-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Inherit from jf-common
$(call inherit-product, device/samsung/jf-common/jf-common.mk)

# Also get non-open-source specific aspects if available
$(call inherit-product-if-exists, vendor/samsung/jfltevzw/jfltevzw-vendor.mk)

# Overlays
DEVICE_PACKAGE_OVERLAYS += device/samsung/jfltevzw/overlay

# Loki
PRODUCT_PACKAGES += \
    loki_tool \
    loki.sh \
    loki_bootloaders \
    recovery-transform.sh

PRODUCT_COPY_FILES += \
    device/samsung/jfltevzw/releasetools/loki.sh:install/bin/loki.sh

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml

# System Properties
$(call inherit-product, device/samsung/jfltevzw/system_prop.mk)

# Vendor security patch level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.lineage.build.vendor_security_patch=2017-01-05
