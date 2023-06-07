mount -o rw,remount /data
MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug-pfsd.log
set -x

# run
FILE=$MODPATH/sepolicy.pfsd
if [ -f $FILE ]; then
  magiskpolicy --live --apply $FILE
fi

# list
(
PKGS="`cat $MODPATH/package.txt`
       com.miui.rom:ui"
for PKG in $PKGS; do
  magisk --denylist rm $PKG
  magisk --sulist add $PKG
done
FILE=$MODPATH/tmp_file
magisk --hide sulist 2>$FILE
if [ "`cat $FILE`" == 'SuList is enforced' ]; then
  for PKG in $PKGS; do
    magisk --hide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk --hide rm $PKG
  done
fi
rm -f $FILE
) 2>/dev/null

# property
PROP=`getprop ro.build.characteristics`
if [ ! "$PROP" ]; then
  resetprop ro.build.characteristics default
fi

# property
DEVICE=`getprop ro.product.device`
MODEL=`getprop ro.product.model`
if [ "$DEVICE" == cancro ]; then
  if ! echo "$MODEL" | grep "MI 3"\
  && ! echo "$MODEL" | grep "MI 4"; then
    resetprop ro.product.model "MI 4"
  fi
fi

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  rm -f $FILE
fi

# permission
chmod 0751 $MODPATH/system/bin
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  chmod 0751 $MODPATH/vendor/bin
else
  chmod 0751 $MODPATH/system/vendor/bin
fi
FILES=`find $MODPATH/system/bin\
            $MODPATH/vendor/bin\
            $MODPATH/system/vendor/bin -type f`
for FILE in $FILES; do
  chmod 0755 $FILE
done
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/system/bin\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  FILES=`find $MODPATH/system/bin\
              $MODPATH/system/vendor/bin -type f`
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
cp -af $ETC/$DES $MODETC
patch_public_libraries
NAMES="libmiuiblursdk.so libmiuinative.so libmiuiblur.so
       libthemeutils_jni.so libshell_jni.so libshell.so libmiuixlog.so
       libimage_arcsoft_4plus.so libstlport_shared.so"
patch_public_libraries_nopreload
NAMES="libadsprpc.so libcdsprpc.so libOpenCL.so
       libarcsoft_beautyshot.so libmpbase.so"
FILE=$MODVETC/$DES
cp -af $VETC/$DES $MODVETC
patch_public_libraries
if [ "$API" -ge 26 ]; then
  chcon u:object_r:vendor_configs_file:s0 $FILE
  for NAME in $NAMES; do
    chcon u:object_r:same_process_hal_file:s0 $MODPATH/system/vendor/lib*/$NAME
  done
fi














