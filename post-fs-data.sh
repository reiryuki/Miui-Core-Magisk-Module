mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  . $FILE
fi

# context
if [ "$API" -ge 26 ]; then
  chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
  chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
fi

# property
PROP=`getprop ro.build.characteristics`
if [ ! "$PROP" ]; then
  resetprop ro.build.characteristics default
fi

# property
DEVICE=`getprop ro.product.device`
MODEL=`getprop ro.product.model`
if [ "$DEVICE" == cancro ]; then
  if ! echo "$MODEL" | grep "MI 3" && ! echo "$MODEL" | grep "MI 4"; then
    resetprop ro.product.model "MI 4"
  fi
fi

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`realpath /dev/*/.magisk`
fi

# path
MIRROR=$MAGISKTMP/mirror
SYSTEM=`realpath $MIRROR/system`
VENDOR=`realpath $MIRROR/vendor`
ETC=$SYSTEM/etc
VETC=$VENDOR/etc
MODETC=$MODPATH/system/etc
MODVETC=$MODPATH/system/vendor/etc

# function
patch_public_libraries() {
for NAMES in $NAME; do
  if ! grep $NAMES $FILE; then
    echo $NAMES >> $FILE
  fi
done
chmod 0644 $FILE
}

# patch public libraries
DES=public.libraries.txt
rm -f `find $MODPATH/system -type f -name $DES`
NAME="libnativehelper.so libnativeloader.so libcutils.so
      libutils.so libc++.so libandroidfw.so libui.so
      libandroid_runtime.so libbinder.so"
FILE=$MODETC/$DES
cp -f $ETC/$DES $MODETC
patch_public_libraries
NAME="libadsprpc.so libcdsprpc.so libOpenCL.so
      libarcsoft_beautyshot.so libmpbase.so"
FILE=$MODVETC/$DES
cp -f $VETC/$DES $MODVETC
patch_public_libraries
if [ "$API" -ge 26 ]; then
  chcon u:object_r:vendor_configs_file:s0 $FILE
  for NAMES in $NAME; do
    chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/$NAMES
  done
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  rm -f $FILE
fi


