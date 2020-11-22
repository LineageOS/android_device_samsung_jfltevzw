#!/system/bin/sh
#
# This leverages the loki_patch utility created by djrbliss
# See here for more information on loki: https://github.com/djrbliss/loki
#

RECSIZE=$1
RECSHA1=$2
BOOTSIZE=$3
BOOTSHA1=$4

if getrop ro.twrp.version
  egrep -q -f /system/etc/loki_bootloaders /proc/cmdline
else
  egrep -q -f /mnt/system/system/etc/loki_bootloaders /proc/cmdline
fi

if [ $? -eq 0 ]; then
  need_lok=1
  export C=/tmp/loki_tmpdir
  rm -rf $C
  mkdir -p $C
  dd if=/dev/block/platform/msm_sdcc.1/by-name/recovery of=$C/recovery.lok
  if getrop ro.twrp.version
  then
    /system/bin/loki_tool unlok $C/recovery.lok $C/recovery
  else
    /mnt/system/system/bin/loki_tool unlok $C/recovery.lok $C/recovery
  fi
else
  export C=/dev/block/platform/msm_sdcc.1/by-name/
fi

if ! applypatch -c EMMC:$C/recovery:$RECSIZE:$RECSHA1; then
  if [ $need_lok -eq 1 ]; then
    log -t recovery "recovery is outdated. unloki-ing all the things"
    dd if=/dev/block/platform/msm_sdcc.1/by-name/boot of=$C/boot.lok
    dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img
    if getprop ro.twrp.version
    then
      /system/bin/loki_tool unlok $C/boot.lok $C/boot
    else
      /mnt/system/system/bin/loki_tool unlok $C/boot.lok $C/boot
    fi
  fi
  log -t recovery "Installing new recovery image"
  if getprop ro.twrp.version
  then
    applypatch -b /system/etc/recovery-resource.dat EMMC:$C/boot:$BOOTSIZE:$BOOTSHA1 EMMC:$C/recovery $RECSHA1 $RECSIZE $BOOTSHA1:/system/recovery-from-boot.p || exit 1
  else
    applypatch -b /mnt/system/system/etc/recovery-resource.dat EMMC:$C/boot:$BOOTSIZE:$BOOTSHA1 EMMC:$C/recovery $RECSHA1 $RECSIZE $BOOTSHA1:/mnt/system/system/recovery-from-boot.p || exit 1
  fi
  if [ $need_lok -eq 1 ]; then
    if getprop ro.twrp.version
    then
      /system/bin/loki_tool patch recovery $C/aboot.img $C/recovery $C/recovery.lok || exit 1
      /system/bin/loki_tool flash recovery $C/recovery.lok || exit 1
    else
      /mnt/system/system/bin/loki_tool patch recovery $C/aboot.img $C/recovery $C/recovery.lok || exit 1
      /mnt/system/system/bin/loki_tool flash recovery $C/recovery.lok || exit 1
  fi

else
  log -t recovery "Recovery image already installed"
fi

if [ $need_lok -eq 1 ]; then
  rm -rf $C
fi

exit 0
