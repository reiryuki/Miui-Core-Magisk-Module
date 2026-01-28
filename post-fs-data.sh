mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`
FIRARCH=`getprop ro.bionic.arch`
SECARCH=`getprop ro.bionic.2nd_arch`
ABILIST=`getprop ro.product.cpu.abilist`
if [ ! "$ABILIST" ]; then
  ABILIST=`getprop ro.system.product.cpu.abilist`
fi
if [ "$FIRARCH" == arm64 ]\
&& ! echo "$ABILIST" | grep -q arm64-v8a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,arm64-v8a"
  else
    ABILIST=arm64-v8a
  fi
fi
if [ "$FIRARCH" == x64 ]\
&& ! echo "$ABILIST" | grep -q x86_64; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86_64"
  else
    ABILIST=x86_64
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi"
  else
    ABILIST=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi-v7a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi-v7a"
  else
    ABILIST=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST" | grep -q x86; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86"
  else
    ABILIST=x86
  fi
fi
if [ -L $MODPATH/system/vendor ]; then
  mkdir -p $MODPATH/vendor
fi
if [ ! -d $MODPATH/vendor ]\
|| [ -L $MODPATH/vendor ]; then
  MODSYSTEM=/system
fi

# function
permissive() {
if [ "`toybox cat $FILE`" = 1 ]; then
  chmod 640 $FILE
  chmod 440 $FILE2
  echo 0 > $FILE
fi
}
magisk_permissive() {
if [ "`toybox cat $FILE`" = 1 ]; then
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
FILE=/sys/fs/selinux/enforce
FILE2=/sys/fs/selinux/policy
#1permissive
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#2magisk_permissive
FILE=$MODPATH/sepolicy.rule
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
  chcon -R u:object_r:vendor_file:s0 $MODPATH$MODSYSTEM/vendor
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH$MODSYSTEM/vendor/etc
fi

# function
patch_public_libraries() {
for NAME in $NAMES; do
  for FILE in $FILES; do
    if ! grep $NAME $FILE; then
      if echo "$ABILIST" | grep arm64-v8a\
      && ! echo "$ABILIST" | grep armeabi-v7a; then
        echo "$NAME 64" >> $FILE
      else
        echo $NAME >> $FILE
      fi
    fi
  done
done
if [ ! "$DUPS" ]; then
  for FILE in $FILES; do
    chmod 0644 $FILE
  done
fi
}
patch_public_libraries_nopreload() {
for NAME in $NAMES; do
  for FILE in $FILES; do
    if ! grep $NAME $FILE; then
      if echo "$ABILIST" | grep arm64-v8a\
      && ! echo "$ABILIST" | grep armeabi-v7a; then
        echo "$NAME 64 nopreload" >> $FILE
      else
        echo "$NAME nopreload" >> $FILE
      fi
    fi
  done
done
if [ ! "$DUPS" ]; then
  for FILE in $FILES; do
    chmod 0644 $FILE
  done
fi
}

# patch public libraries
MODID=`basename "$MODPATH"`
ETC=/system/etc
VETC=/vendor/etc
MODETC=$MODPATH$ETC
MODVETC=$MODPATH$MODSYSTEM$VETC
DES=public.libraries.txt
rm -f `find $MODPATH -type f -name $DES`
NAMES="libnativehelper.so libnativeloader.so libcutils.so
       libutils.so libc++.so libandroidfw.so libui.so
       libandroid_runtime.so libbinder.so"
DUPS=`find /data/adb/modules/*$ETC ! -path "*/$MODID/*" -maxdepth 1 -type f -name $DES`
if [ "$DUPS" ]; then
  FILES=$DUPS
else
#p  cp -af $ETC/$DES $MODETC
  FILES=$MODETC/$DES
fi
#ppatch_public_libraries
NAMES="libmiui_runtime.so libmiuiblursdk.so libmiuinative.so
       libmiuiblur.so libthemeutils_jni.so libshell_jni.so libshell.so
       libmiuixlog.so libimage_arcsoft_4plus.so libstlport_shared.so"
#ppatch_public_libraries_nopreload
NAMES="libcdsprpc.so libadsprpc.so libOpenCL.so
       libarcsoft_beautyshot.so libmpbase.so"
DUPS=`find /data/adb/modules/*$MODSYSTEM$VETC ! -path "*/$MODID/*" -maxdepth 1 -type f -name $DES`
if [ "$DUPS" ]; then
  FILES=$DUPS
else
#p  cp -af $VETC/$DES $MODVETC
  FILES=$MODVETC/$DES
fi
#ppatch_public_libraries
if [ "$API" -ge 26 ]; then
  for NAME in $NAMES; do
    chcon u:object_r:same_process_hal_file:s0 $MODPATH$MODSYSTEM/vendor/lib*/$NAME
  done
  if [ ! "$DUPS" ]; then
    for FILE in $FILES; do
      chcon u:object_r:vendor_configs_file:s0 $FILE
    done
  fi
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













