#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from core base
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Inherit OrangeFox / TWRP configuration
$(call inherit-product, vendor/twrp/config/common.mk)

# Device identifier
PRODUCT_DEVICE := emerald
PRODUCT_NAME := twrp_emerald
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Note 13 Pro 4G
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME="emerald_global"
