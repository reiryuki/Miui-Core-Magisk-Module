mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`
ABILIST=`getprop ro.product.cpu.abilist`
ABILIST32=`getprop ro.product.cpu.abilist32`
if [ ! "$ABILIST32" ]; then
  [ -f /system/lib/libandroid.so ] && ABILIST32=true
fi

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# property
PROP=`getprop ro.build.characteristics`
if [ ! "$PROP" ]; then
  resetprop -n ro.build.characteristics default
fi

# property
DEVICE=`getprop ro.product.device`
MODEL=`getprop ro.product.model`
if [ "$DEVICE" == cancro ]; then
  if ! echo "$MODEL" | grep "MI 3"\
  && ! echo "$MODEL" | grep "MI 4"; then
    resetprop -n ro.product.model "MI 4"
  fi
fi

# permission
chmod 0751 $MODPATH/system/bin
FILES=`find $MODPATH/system/bin -type f`
for FILE in $FILES; do
  chmod 0755 $FILE
done
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/system/bin\
             $MODPATH/vendor\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  FILES=`find $MODPATH/system/bin -type f`
  for FILE in $FILES; do
    chown 0.2000 $FILE
  done
  chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
  else
    chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
  fi
fi

# path
ETC=/system/etc
VETC=/vendor/etc
MODETC=$MODPATH$ETC
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  MODVETC=$MODPATH$VETC
else
  MODVETC=$MODPATH/system$VETC
fi

# function
patch_public_libraries() {
for NAME in $NAMES; do
  if ! grep $NAME $FILE; then
    if echo "$ABILIST" | grep arm64-v8a\
    && ! echo "$ABILIST" | grep armeabi-v7a; then
      echo "$NAME 64" >> $FILE
    else
      echo $NAME >> $FILE
    fi
  fi
done
chmod 0644 $FILE
}
patch_public_libraries_nopreload() {
for NAME in $NAMES; do
  if ! grep $NAME $FILE; then
    if echo "$ABILIST" | grep arm64-v8a\
    && ! echo "$ABILIST" | grep armeabi-v7a; then
      echo "$NAME 64 nopreload" >> $FILE
    else
      echo "$NAME nopreload" >> $FILE
    fi
  fi
done
chmod 0644 $FILE
}

# patch public libraries
DES=public.libraries.txt
rm -f `find $MODPATH -type f -name $DES`
NAMES="libnativehelper.so libnativeloader.so libcutils.so
       libutils.so libc++.so libandroidfw.so libui.so
       libandroid_runtime.so libbinder.so"
FILE=$MODETC/$DES
#pcp -af $ETC/$DES $MODETC
#ppatch_public_libraries
NAMES="libmiui_runtime.so libmiuiblursdk.so libmiuinative.so
       libmiuiblur.so libthemeutils_jni.so libshell_jni.so libshell.so
       libmiuixlog.so libimage_arcsoft_4plus.so libstlport_shared.so"
#ppatch_public_libraries_nopreload
NAMES="libcdsprpc.so libadsprpc.so libOpenCL.so
       libarcsoft_beautyshot.so libmpbase.so"
FILE=$MODVETC/$DES
#pcp -af $VETC/$DES $MODVETC
#ppatch_public_libraries
if [ "$API" -ge 26 ]; then
  chcon u:object_r:vendor_configs_file:s0 $FILE
  for NAME in $NAMES; do
    if [ -L $MODPATH/system/vendor ]\
    && [ -d $MODPATH/vendor ]; then
      chcon u:object_r:same_process_hal_file:s0 $MODPATH/vendor/lib*/$NAME
    else
      chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/$NAME
    fi
  done
fi

# directory
DIR=/data/system/theme
mkdir -p $DIR/fonts
#chmod 0775 $DIR
#chown 9801.9801 $DIR
#chcon u:object_r:theme_data_file:s0 $DIR
chmod -R 0777 $DIR
chown -R 1000.1000 $DIR
chcon -R u:object_r:system_data_file:s0 $DIR

# directory
DIR=/data/system/theme_magic
mkdir -p $DIR/video
#chmod 0775 $DIR
#chown 9801.9801 $DIR
#chcon u:object_r:theme_data_file:s0 $DIR
chmod -R 0777 $DIR
chown -R 1000.1000 $DIR
chcon -R u:object_r:system_data_file:s0 $DIR

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE.txt
fi













