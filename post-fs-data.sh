(

mount /data
mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# run
FILE=$MODPATH/sepolicy.sh
if [ -f $FILE ]; then
  sh $FILE
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
  if ! echo "$MODEL" | grep -Eq "MI 3" && ! echo "$MODEL" | grep -Eq "MI 4"; then
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

# public libraries
DES=public.libraries.txt
FILE=$MODETC/$DES
#prm -f $FILE
#pcp -f $ETC/$DES $MODETC

# patch public libraries
NAME="libnativehelper.so
      libcutils.so
      libutils.so
      libc++.so
      libandroidfw.so
      libui.so
      libandroid_runtime.so
      libbinder.so"
#pfor NAMES in $NAME; do
#p  echo $NAMES >> $FILE
#pdone

# vendor public libraries
FILE=$MODVETC/$DES
rm -f $FILE
cp -f $VETC/$DES $MODVETC

# patch public libraries
NAME=libOpenCL.so
for NAMES in $NAME; do
  echo $NAMES >> $FILE
done

# permission
if [ ! -f $VETC/$DES ]; then
  chmod 0644 $FILE
fi
if [ ! -f $VETC/$DES ] && [ "$API" -ge 26 ]; then
  magiskpolicy "dontaudit vendor_configs_file labeledfs filesystem associate"
  magiskpolicy "allow     vendor_configs_file labeledfs filesystem associate"
  magiskpolicy "dontaudit init vendor_configs_file file relabelfrom"
  magiskpolicy "allow     init vendor_configs_file file relabelfrom"
  chcon u:object_r:vendor_configs_file:s0 $FILE
  magiskpolicy --live "type vendor_configs_file"
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  sh $FILE
  rm -f $FILE
fi

) 2>/dev/null





