# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0
FIRARCH=`grep_get_prop ro.bionic.arch`
SECARCH=`grep_get_prop ro.bionic.2nd_arch`
ABILIST=`grep_get_prop ro.product.cpu.abilist`
if [ ! "$ABILIST" ]; then
  ABILIST=`grep_get_prop ro.system.product.cpu.abilist`
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
ABILIST32=`grep_get_prop ro.product.cpu.abilist32`
if [ ! "$ABILIST32" ]; then
  ABILIST32=`grep_get_prop ro.system.product.cpu.abilist32`
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi"
  else
    ABILIST32=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi-v7a; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi-v7a"
  else
    ABILIST32=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST32" | grep -q x86; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,x86"
  else
    ABILIST32=x86
  fi
fi
if [ ! "$ABILIST32" ]; then
  [ -f /system/lib/libandroid.so ] && ABILIST32=true
fi

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# architecture
if [ "$ABILIST" ]; then
  ui_print "- $ABILIST architecture"
  ui_print " "
fi
NAME=arm64-v8a
NAME2=armeabi-v7a
if ! echo "$ABILIST" | grep -Eq "$NAME|$NAME2"; then
  if [ "$BOOTMODE" == true ]; then
    ui_print "! This ROM doesn't support $NAME"
    ui_print "  nor $NAME2 architecture"
  else
    ui_print "! This Recovery doesn't support $NAME"
    ui_print "  nor $NAME2 architecture"
    ui_print "  Try to install via Magisk app instead"
  fi
  abort
fi
if ! echo "$ABILIST" | grep -q $NAME; then
  rm -rf `find $MODPATH/system -type d -name *64*`\
   $MODPATH/system*/bin
  if [ "$BOOTMODE" != true ]; then
    ui_print "! This Recovery doesn't support $NAME architecture"
    ui_print "  Try to install via Magisk app instead"
    ui_print " "
  fi
fi
if ! echo "$ABILIST" | grep -q $NAME2; then
  rm -rf $MODPATH/system*/lib\
   $MODPATH/system*/vendor/lib
  if [ "$BOOTMODE" != true ]; then
    ui_print "! This Recovery doesn't support $NAME2 architecture"
    ui_print "  Try to install via Magisk app instead"
    ui_print " "
  fi
fi

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# recovery
mount_partitions_in_recovery

# magisk
magisk_setup

# path
SYSTEM=`realpath $MIRROR/system`
VENDOR=`realpath $MIRROR/vendor`
PRODUCT=`realpath $MIRROR/product`
SYSTEM_EXT=`realpath $MIRROR/system_ext`
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# function
file_check_system() {
for FILE in $FILES; do
  DESS="$SYSTEM$FILE $SYSTEM_EXT$FILE"
  for DES in $DESS; do
    if [ -f $DES ]; then
      ui_print "- Detected"
      ui_print "$DES"
      rm -f $MODPATH/system*$FILE
      ui_print " "
    fi
  done
done
}
file_check_vendor() {
for FILE in $FILES; do
  DESS="$VENDOR$FILE $ODM$FILE"
  for DES in $DESS; do
    if [ -f $DES ]; then
      ui_print "- Detected"
      ui_print "$DES"
      rm -f $MODPATH/system*/vendor$FILE
      ui_print " "
    fi
  done
done
}

# check
FILES="/bin/shelld /bin/miuibooster"
file_check_system
if [ "$IS64BIT" == true ]; then
  LISTS=`ls $MODPATH/system/lib64`
  FILES=`for LIST in $LISTS; do echo /lib64/$LIST; done`
  file_check_system
  LISTS=`ls $MODPATH/system/vendor/lib64`
  FILES=`for LIST in $LISTS; do echo /lib64/$LIST; done`
  file_check_vendor
fi
if [ "$ABILIST32" ]; then
  LISTS=`ls $MODPATH/system/lib`
  FILES=`for LIST in $LISTS; do echo /lib/$LIST; done`
  file_check_system
  LISTS=`ls $MODPATH/system/vendor/lib`
  FILES=`for LIST in $LISTS; do echo /lib/$LIST; done`
  file_check_vendor
fi

# function
check_function() {
ui_print "- Checking"
ui_print "$NAME"
ui_print "  function at"
ui_print "$FILE"
ui_print "  Please wait..."
if ! grep -q $NAME $FILE; then
  ui_print "  Function not found"
  SYSTEM_10=true
fi
ui_print " "
}

# check
SYSTEM_10=false
NAME=_ZN7android23sp_report_stack_pointerEv
if [ "$IS64BIT" == true ]; then
  DES=$MODPATH/system/bin/shelld
  if [ -f $DES ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed -e 's|libshellservice.so||g' -e 's|libshell_jni.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/bin/miuibooster
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/lib64/libexmedia.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libexmedia.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/lib64/libmiuiblur.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libmiuiblur.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/lib64/libshell.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libshell.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/vendor/lib64/libcdsprpc.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed -e 's|libcdsprpc.so||g' -e 's|lib%s_skel.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    check_function
  fi
fi
if [ "$ABILIST32" ]; then
  DES=$MODPATH/system/lib/libexmedia.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libexmedia.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/lib/libmiuiblur.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
           | sed 's|libmiuiblur.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/lib/libshell.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
           | sed 's|libshell.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
    check_function
  fi
  DES=$MODPATH/system/vendor/lib/libcdsprpc.so
  if [ -f $DES ] && [ $SYSTEM_10 != true ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed -e 's|libcdsprpc.so||g' -e 's|lib%s_skel.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
    check_function
  fi
fi
if [ $SYSTEM_10 == true ]; then
  ui_print "- Using legacy libraries"
  cp -rf $MODPATH/system_10/* $MODPATH/system
  ui_print " "
fi

# check
NAME=_ZN7android7meminfo11ProcMemInfo18ForEachVmaFromMapsERKNSt3__18functionIFvRKNS0_3VmaEEEE
NAME2=_ZN7android7meminfo11ProcMemInfo18ForEachVmaFromMapsERKNSt3__18functionIFbRNS0_3VmaEEEE
if [ "$IS64BIT" == true ]; then
  DES=$MODPATH/system/lib64/libmiui_runtime.so
  if [ -f $DES ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libmiui_runtime.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
    ui_print "- Checking"
    ui_print "$NAME"
    ui_print "  function at"
    ui_print "$FILE"
    ui_print "  Please wait..."
    if ! grep -q $NAME $FILE; then
      ui_print "  Using modified libmiui_runtime.so"
      cp -rf $MODPATH/system_15/lib64 $MODPATH/system
    fi
    ui_print " "
  fi
fi
if [ "$ABILIST32" ]; then
  DES=$MODPATH/system/lib/libmiui_runtime.so
  if [ -f $DES ]; then
    LISTS=`strings $DES | grep ^lib | grep .so\
            | sed 's|libmiui_runtime.so||g'`
    FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
    ui_print "- Checking"
    ui_print "$NAME"
    ui_print "  function at"
    ui_print "$FILE"
    ui_print "  Please wait..."
    if ! grep -q $NAME $FILE; then
      ui_print "  Using modified libmiui_runtime.so"
      cp -rf $MODPATH/system_15/lib $MODPATH/system
    fi
    ui_print " "
  fi
fi

# extract
APP=miuisystem
ui_print "- Extracting..."
FILE=`find $MODPATH/system -type f -name $APP.apk`
DIR=$MODPATH/system/etc
DES=assets/*
unzip -d $TMPDIR -o $FILE $DES
cp -rf $TMPDIR/$DES $DIR
ui_print " "

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    FILE=`find /data/app -name *$PKG*`
    if [ "$FILE" ]; then
      RES=`pm uninstall $PKG 2>/dev/null`
    fi
  done
fi
rm -rf $MODPATH/system_* $MODPATH/unused
remove_sepolicy_rule
ui_print " "
# power save
FILE=$MODPATH/system/etc/sysconfig/*
if [ "`grep_prop power.save $OPTIONALS`" == 1 ]; then
  ui_print "- $MODNAME will not be allowed in power save."
  ui_print "  It may save your battery but decreasing $MODNAME performance."
  for PKG in $PKGS; do
    sed -i "s|<allow-in-power-save package=\"$PKG\"/>||g" $FILE
    sed -i "s|<allow-in-power-save package=\"$PKG\" />||g" $FILE
  done
  ui_print " "
fi

# function
conflict() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAME
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAME/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAME\
   /mnt/vendor/persist/magisk/$NAME\
   /persist/magisk/$NAME\
   /data/unencrypted/magisk/$NAME\
   /cache/magisk/$NAME\
   /cust/magisk/$NAME
done
}

# conflict
NAMES=MIUICore
conflict

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
SELINUX=`cat $FILE`
if [ "$SELINUX" == 1 ]; then
  if ! setenforce 0; then
    echo 0 > $FILE
  fi
  SELINUX=`cat $FILE`
  if [ "$SELINUX" == 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    if ! setenforce 1; then
      echo 1 > $FILE
    fi
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# public
FILE=$MODPATH/post-fs-data.sh
if [ "`grep_prop miui.public $OPTIONALS`" != 0 ]; then
  sed -i 's|#p||g' $FILE
else
  ui_print "- Does not patch public.libraries.txt"
  ui_print "  You will not be able to normal install Miui apps"
  ui_print " "
fi

# global
FILE=$MODPATH/service.sh
NAME=ro.product.mod_device
if [ "`grep_prop miui.global $OPTIONALS`" == 1 ]; then
  ui_print "- Global mode"
  sed -i "s|#resetprop -n $NAME|resetprop -n $NAME|g" $FILE
  ui_print " "
fi

# code
FILE=$MODPATH/service.sh
NAME=ro.miui.ui.version.code
if [ "`grep_prop miui.code $OPTIONALS`" == 0 ]; then
  ui_print "- Removing $NAME..."
  sed -i "s|resetprop -n $NAME|#resetprop -n $NAME|g" $FILE
  ui_print " "
fi

# media
if [ ! -d /product/media ] && [ -d /system/media ]; then
  ui_print "- Using /system/media instead of /product/media"
  mv -f $MODPATH/system/product/media $MODPATH/system
  rm -rf $MODPATH/system/product
  ui_print " "
elif [ ! -d /product/media ] && [ ! -d /system/media ]; then
  ui_print "! /product/media & /system/media not found"
  ui_print " "
fi

# copy
DIR=$MODPATH/system/system_ext/framework
mkdir -p $DIR
cp -f $MODPATH/system/framework/MiuiBooster.jar $DIR

# unmount
unmount_mirror
















