# OrangeFox Recovery Device Tree for Xiaomi emerald (Redmi Note 13 Pro 4G / POCO M6 Pro)

```
#
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#
```

## Device Specifications

| Feature | Specification |
| :--- | :--- |
| **Chipset** | MediaTek Helio G99 Ultra (MT6789) |
| **CPU** | Octa-core (2x2.2 GHz Cortex-A76 & 6x2.0 GHz Cortex-A55) |
| **GPU** | Mali-G57 MC2 |
| **Display** | 1080 x 2400 AMOLED (120Hz, Punch Hole) |
| **Storage** | UFS 2.2 |
| **Architecture** | ARM64 (`arm64-v8a`) |
| **Virtual A/B** | Yes (Compressed Virtual A/B with LZ4) |
| **Dynamic Partitions** | Yes (Super: `system`, `vendor`, `product`, `system_ext`, `vendor_dlkm`, `system_dlkm`) |
| **Encryption** | File-Based Encryption v2 (FBE v2) + Metadata Encryption |
| **Release Date** | January 2024 |

---

## Partition Layout

* **Boot / Kernel:** `/dev/block/by-name/boot` (Slot-based `_a`/`_b`)
* **Vendor Boot / Recovery:** `/dev/block/by-name/vendor_boot` (Slot-based `_a`/`_b`)
* **DTBO:** `/dev/block/by-name/dtbo`
* **VBMeta:** `/dev/block/by-name/vbmeta`, `/dev/block/by-name/vbmeta_system`, `/dev/block/by-name/vbmeta_vendor`
* **Super (Dynamic):** `/dev/block/by-name/super` (7,515,144,192 bytes)
* **Metadata:** `/dev/block/by-name/metadata` (EXT4)
* **Userdata:** `/dev/block/by-name/userdata` (F2FS, FBE v2 inline encryption)

---

## Compilation

### 1. Initialize Sync
```bash
mkdir ~/orangefox && cd ~/orangefox
repo init --depth=1 -u https://gitlab.com/OrangeFox/manifest.git -b fox_12.1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
```

### 2. Clone Device Tree
```bash
git clone https://github.com/theilgar/device_xiaomi_emerald-recovery.git device/xiaomi/emerald
```

### 3. Build
```bash
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
lunch omni_emerald-eng
mka recoveryimage vendorbootimage -j$(nproc --all)
```

---

## Automated GitHub Actions Build
This repository includes a preconfigured GitHub Actions workflow in `.github/workflows/orangefox.yml`.
Simply trigger the workflow under the **Actions** tab on GitHub, and the recovery will be compiled and available for download in ~35-45 minutes.
