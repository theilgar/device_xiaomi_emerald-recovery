#!/usr/bin/env bash
#
# Sync prebuilt kernel, DTB, modules and touch firmware
# from theilgar/device_xiaomi_emerald-kernel (lineage-24.0)
# and theilgar/vendor_xiaomi_emerald (lineage-24.0)
# into device_xiaomi_emerald-recovery.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Search paths for emerald-kernel, vendor_xiaomi_emerald and device_xiaomi_emerald
LINEAGE_DEV_DIR=""
for cand in \
  "${DEVICE_DIR}/../emerald-lineage" \
  "${DEVICE_DIR}/../device_xiaomi_emerald" \
  "${DEVICE_DIR}/../emerald" \
  "${DEVICE_DIR}/../../device/xiaomi/emerald" \
  "/home/user/Desktop/lineage/device/xiaomi/emerald" \
  "${GITHUB_WORKSPACE:-/home/admin}/device/xiaomi/emerald-lineage" \
  "/home/admin/device_xiaomi_emerald"; do
  if [ -d "${cand}" ] && [ -f "${cand}/BoardConfig.mk" ]; then
    LINEAGE_DEV_DIR="$(cd "${cand}" && pwd)"
    break
  fi
done

KERNEL_DIR=""
for cand in \
  "${DEVICE_DIR}/../emerald-kernel" \
  "${DEVICE_DIR}/../device_xiaomi_emerald-kernel" \
  "${DEVICE_DIR}/../../device/xiaomi/emerald-kernel" \
  "/home/user/Desktop/lineage/device/xiaomi/emerald-kernel" \
  "${GITHUB_WORKSPACE:-/home/admin}/device/xiaomi/emerald-kernel" \
  "/home/admin/device_xiaomi_emerald-kernel"; do
  if [ -d "${cand}" ] && [ -f "${cand}/dtb/mt6789.dtb" ]; then
    KERNEL_DIR="$(cd "${cand}" && pwd)"
    break
  fi
done

VENDOR_DIR=""
for cand in \
  "${DEVICE_DIR}/../vendor_xiaomi_emerald" \
  "${DEVICE_DIR}/../../vendor/xiaomi/emerald" \
  "/home/user/Desktop/lineage/vendor/xiaomi/emerald" \
  "${GITHUB_WORKSPACE:-/home/admin}/vendor/xiaomi/emerald" \
  "/home/admin/vendor_xiaomi_emerald"; do
  if [ -d "${cand}/proprietary/vendor/firmware" ]; then
    VENDOR_DIR="$(cd "${cand}" && pwd)"
    break
  fi
done

echo "=== Syncing LineageOS 24.0 Prebuilts ==="
echo "Recovery Tree: ${DEVICE_DIR}"
echo "Lineage Tree:  ${LINEAGE_DEV_DIR:-NOT FOUND}"
echo "Kernel Tree:   ${KERNEL_DIR:-NOT FOUND}"
echo "Vendor Tree:   ${VENDOR_DIR:-NOT FOUND}"

# 1. Sync DTB
if [ -n "${KERNEL_DIR}" ] && [ -f "${KERNEL_DIR}/dtb/mt6789.dtb" ]; then
  echo "--> Updating DTB from kernel tree..."
  cp -f "${KERNEL_DIR}/dtb/mt6789.dtb" "${DEVICE_DIR}/prebuilt/dtb.img"
fi

# 2. Sync Touch Modules from kernel tree
if [ -n "${KERNEL_DIR}" ]; then
  echo "--> Updating kernel modules from kernel tree..."
  mkdir -p "${DEVICE_DIR}/recovery/root/lib/modules"
  mkdir -p "${DEVICE_DIR}/recovery/root/vendor/lib/modules"

  # Core touch modules from modules_dlkm
  for mod in xiaomi.ko switch_class.ko gt9916.ko ft3683g.ko touch_boost.ko mtk_ioctl_touch_boost.ko; do
    if [ -f "${KERNEL_DIR}/modules_dlkm/${mod}" ]; then
      cp -f "${KERNEL_DIR}/modules_dlkm/${mod}" "${DEVICE_DIR}/recovery/root/lib/modules/"
      cp -f "${KERNEL_DIR}/modules_dlkm/${mod}" "${DEVICE_DIR}/recovery/root/vendor/lib/modules/"
    fi
  done

  # Platform dependencies from modules_ramdisk
  for mod in hqsys_pcba.ko hqsysfs.ko miev.ko pd_dbg_info.ko tcpc_class.ko; do
    if [ -f "${KERNEL_DIR}/modules_ramdisk/${mod}" ]; then
      cp -f "${KERNEL_DIR}/modules_ramdisk/${mod}" "${DEVICE_DIR}/recovery/root/lib/modules/"
      cp -f "${KERNEL_DIR}/modules_ramdisk/${mod}" "${DEVICE_DIR}/recovery/root/vendor/lib/modules/"
    fi
  done
fi

# 3. Sync Touch Firmware from vendor tree
if [ -n "${VENDOR_DIR}" ]; then
  echo "--> Updating touch firmware from vendor tree..."
  mkdir -p "${DEVICE_DIR}/recovery/root/vendor/firmware"
  mkdir -p "${DEVICE_DIR}/recovery/root/lib/firmware"
  mkdir -p "${DEVICE_DIR}/recovery/root/system/etc/firmware"

  FW_SRC="${VENDOR_DIR}/proprietary/vendor/firmware"
  for fw in gt9916_ts_fw_visionox.bin goodix_cfg_group.bin focaltech_ts_fw_huaxing.bin focaltech_mp_fw_huaxin.ini; do
    if [ -f "${FW_SRC}/${fw}" ]; then
      cp -f "${FW_SRC}/${fw}" "${DEVICE_DIR}/recovery/root/vendor/firmware/"
      cp -f "${FW_SRC}/${fw}" "${DEVICE_DIR}/recovery/root/lib/firmware/"
      cp -f "${FW_SRC}/${fw}" "${DEVICE_DIR}/recovery/root/system/etc/firmware/"
    fi
  done
fi

# 4. Sync Recovery Configurations from LineageOS device tree
if [ -n "${LINEAGE_DEV_DIR}" ]; then
  echo "--> Updating configurations from LineageOS device tree..."
  if [ -f "${LINEAGE_DEV_DIR}/rootdir/etc/init.recovery.usb.rc" ]; then
    cp -f "${LINEAGE_DEV_DIR}/rootdir/etc/init.recovery.usb.rc" "${DEVICE_DIR}/recovery/root/init.recovery.usb.rc"
  fi
  if [ -f "${LINEAGE_DEV_DIR}/rootdir/etc/fstab.mt6789" ]; then
    mkdir -p "${DEVICE_DIR}/prebuilt"
    cp -f "${LINEAGE_DEV_DIR}/rootdir/etc/fstab.mt6789" "${DEVICE_DIR}/prebuilt/fstab.mt6789"
  fi
fi

echo "=== Synchronization complete! ==="
