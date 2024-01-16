mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`

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

# list
PKGS="`cat $MODPATH/package.txt`
       com.miui.rom:ui"
for PKG in $PKGS; do
  magisk --denylist rm $PKG 2>/dev/null
  magisk --sulist add $PKG 2>/dev/null
done
if magisk magiskhide sulist; then
  for PKG in $PKGS; do
    magisk magiskhide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk magiskhide rm $PKG
  done
fi

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
    echo $NAME >> $FILE
  fi
done
chmod 0644 $FILE
}
patch_public_libraries_nopreload() {
for NAME in $NAMES; do
  if ! grep $NAME $FILE; then
    echo "$NAME nopreload" >> $FILE
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
NAMES="libmiuiblursdk.so libmiuinative.so libmiuiblur.so
       libthemeutils_jni.so libshell_jni.so libshell.so libmiuixlog.so
       libimage_arcsoft_4plus.so libstlport_shared.so"
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

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE\.txt
fi













