mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
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

# etc
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`find /dev -mindepth 2 -maxdepth 2 -type d -name .magisk`
fi
ETC=$MAGISKTMP/mirror/system/etc
VETC=$MAGISKTMP/mirror/system/vendor/etc
MODETC=$MODPATH/system/etc
MODVETC=$MODPATH/system/vendor/etc

# cleaning
DES=public.libraries.txt
rm -f `find $MODPATH/system -type f -name $DES`

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
NAME="libnativehelper.so
      libcutils.so
      libutils.so
      libc++.so
      libandroidfw.so
      libui.so
      libandroid_runtime.so
      libbinder.so"
FILE=$MODETC/$DES
#pcp -f $ETC/$DES $MODETC
#ppatch_public_libraries

# patch public libraries
NAME=libOpenCL.so
FILE=$MODVETC/$DES
cp -f $VETC/$DES $MODVETC
patch_public_libraries
if [ "$API" -ge 26 ]; then
  chcon u:object_r:vendor_configs_file:s0 $FILE
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi


