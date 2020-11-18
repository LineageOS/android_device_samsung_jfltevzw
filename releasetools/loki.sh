#!/sbin/sh
#
# This leverages the loki_patch utility created by djrbliss which allows us
# to bypass the bootloader checks on jfltevzw and jflteatt
# See here for more information on loki: https://github.com/djrbliss/loki
#
#
# Run loki patch on boot.img for locked bootloaders, found in loki_bootloaders
#

LOSRECOVERY=/sbin/toybox
egrep -q -f /system/etc/loki_bootloaders /proc/cmdline

if [ $? -eq 0 ];then
  echo '[*] Locked bootloader version detected.'
  export C=/tmp/loki_tmpdir
  mkdir -p $C
  dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img

  # Mount parittions
  if test -f "$LOSRECOVERY"; then
      toybox mount /dev/block/bootdevice/by-name/system -t ext4 /mnt/system
      toybox mount /dev/block/bootdevice/by-name/vendor -t ext4 /mnt/vendor
  else
      /tmp/toybox mount /dev/block/bootdevice/by-name/system -t ext4 /mnt/system
      /tmp/toybox mount /dev/block/bootdevice/by-name/vendor -t ext4 /mnt/vendor
  fi

  echo '[*] Patching boot.img to with loki.'
  /system/bin/loki_tool patch boot $C/aboot.img /tmp/boot.img $C/boot.lok || exit 1
  echo '[*] Flashing modified boot.img to device.'
  /system/bin/loki_tool flash boot $C/boot.lok || exit 1
  rm -rf $C

  # Unmount partitions
  if test -f "$LOSRECOVERY"; then
      toybox umount /mnt/system
      toybox umount /mnt/vendor
  else
      /tmp/toybox umount /mnt/system
      /tmp/toybox umount /mnt/vendor
  fi
else
  echo '[*] Unlocked bootloader version detected.'
  echo '[*] Flashing unmodified boot.img to device.'
  dd if=/tmp/boot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot || exit 1
fi

exit 0
