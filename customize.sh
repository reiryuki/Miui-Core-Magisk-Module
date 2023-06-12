# space
ui_print " "

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
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# huskydg function
get_device() {
PAR="$1"
DEV="`cat /proc/self/mountinfo | awk '{ if ( $5 == "'$PAR'" ) print $3 }' | head -1 | sed 's/:/ /g'`"
}
mount_mirror() {
SRC="$1"
DES="$2"
RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
while [ -e /dev/$RAN ]; do
  RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
done
mknod /dev/$RAN b `get_device "$SRC"; echo $DEV`
if mount -t ext4 -o ro /dev/$RAN "$DES"\
|| mount -t erofs -o ro /dev/$RAN "$DES"\
|| mount -t f2fs -o ro /dev/$RAN "$DES"\
|| mount -t ubifs -o ro /dev/$RAN "$DES"; then
  blockdev --setrw /dev/$RAN
  rm -f /dev/$RAN
  return 0
fi
rm -f /dev/$RAN
return 1
}
unmount_mirror() {
DIRS="$MIRROR/system_root $MIRROR/system $MIRROR/vendor
      $MIRROR/product $MIRROR/system_ext $MIRROR/odm
      $MIRROR/my_product $MIRROR"
for DIR in $DIRS; do
  umount $DIR
done
}
mount_odm_to_mirror() {
DIR=/odm
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system_root$DIR ]; then
      ln -sf $MIRROR/system_root$DIR $MIRROR
    fi
  fi
  ui_print " "
fi
}
mount_my_product_to_mirror() {
DIR=/my_product
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system_root$DIR ]; then
      ln -sf $MIRROR/system_root$DIR $MIRROR
    fi
  fi
  ui_print " "
fi
}
mount_partitions_to_mirror() {
unmount_mirror
# mount system
if [ "$SYSTEM_ROOT" == true ]; then
  DIR=/system_root
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror / $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
    rm -rf $MIRROR/system
    ln -sf $MIRROR$DIR/system $MIRROR
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
  fi
else
  DIR=/system
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
  fi
fi
ui_print " "
# mount vendor
DIR=/vendor
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  ln -sf $MIRROR/system$DIR $MIRROR
fi
ui_print " "
# mount product
DIR=/product
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  ln -sf $MIRROR/system$DIR $MIRROR
fi
ui_print " "
# mount system_ext
DIR=/system_ext
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  if [ -d $MIRROR/system$DIR ]; then
    ln -sf $MIRROR/system$DIR $MIRROR
  fi
fi
ui_print " "
mount_odm_to_mirror
mount_my_product_to_mirror
}

# bit
if [ "$IS64BIT" != true ]; then
  ui_print "- 32 bit"
  rm -rf `find $MODPATH/system -type d -name *64`
else
  ui_print "- 64 bit"
fi
ui_print " "

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK API $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# magisk
MAGISKPATH=`magisk --path`
if [ "$BOOTMODE" == true ]; then
  if [ "$MAGISKPATH" ]; then
    mount -o rw,remount $MAGISKPATH
    MAGISKTMP=$MAGISKPATH/.magisk
    MIRROR=$MAGISKTMP/mirror
  else
    MAGISKTMP=/mnt
    mount -o rw,remount $MAGISKTMP
    MIRROR=$MAGISKTMP/mirror
    mount_partitions_to_mirror
  fi
fi

# path
SYSTEM=`realpath $MIRROR/system`
PRODUCT=`realpath $MIRROR/product`
VENDOR=`realpath $MIRROR/vendor`
SYSTEM_EXT=`realpath $MIRROR/system_ext`
if [ "$BOOTMODE" == true ]; then
  if [ ! -d $MIRROR/odm ]; then
    mount_odm_to_mirror
  fi
  if [ ! -d $MIRROR/my_product ]; then
    mount_my_product_to_mirror
  fi
fi
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# optionals
OPTIONALS=/sdcard/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# mount
if [ "$BOOTMODE" != true ]; then
  if [ -e /dev/block/bootdevice/by-name/vendor ]; then
    mount -o rw -t auto /dev/block/bootdevice/by-name/vendor /vendor
  else
    mount -o rw -t auto /dev/block/bootdevice/by-name/cust /vendor
  fi
  mount -o rw -t auto /dev/block/bootdevice/by-name/product /product
  mount -o rw -t auto /dev/block/bootdevice/by-name/system_ext /system_ext
  mount -o rw -t auto /dev/block/bootdevice/by-name/odm /odm
  mount -o rw -t auto /dev/block/bootdevice/by-name/my_product /my_product
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# function
check_function() {
ui_print "- Checking"
ui_print "$NAME"
ui_print "  function at"
ui_print "$FILE"
ui_print "  Please wait..."
if ! grep -q $NAME $FILE; then
  ui_print "  Using legacy libraries"
  cp -rf $MODPATH/system_10/* $MODPATH/system
fi
ui_print " "
}

# check
NAME=_ZN7android23sp_report_stack_pointerEv
DES="$MODPATH/system/bin/shelld
      $MODPATH/system/lib/libexmedia.so
      $MODPATH/system/lib/libmiuiblur.so
      $MODPATH/system/lib/libshell.so
      $MODPATH/system/vendor/lib/libcdsprpc.so"
LISTS=`strings $DES | grep ^lib | grep .so\
       | sed -e 's|libshellservice.so||g' -e 's|libshell_jni.so||g'\
       -e 's|libexmedia.so||g' -e 's|libmiuiblur.so||g'\
       -e 's|libshell.so||g' -e 's|libcdsprpc.so||g'\
       -e 's|lib%s_skel.so||g'`
FILE=`for LIST in $LISTS; do echo $SYSTEM/lib/$LIST; done`
check_function
if [ "$IS64BIT" == true ]; then
  DES="$MODPATH/system/lib64/libexmedia.so
        $MODPATH/system/lib64/libmiuiblur.so
        $MODPATH/system/lib64/libshell.so
        $MODPATH/system/vendor/lib64/libcdsprpc.so"
  LISTS=`strings $DES | grep ^lib | grep .so\
         | sed -e 's|libexmedia.so||g' -e 's|libmiuiblur.so||g'\
         -e 's|libshell.so||g' -e 's|libcdsprpc.so||g'\
         -e 's|lib%s_skel.so||g'`
  FILE=`for LIST in $LISTS; do echo $SYSTEM/lib64/$LIST; done`
  check_function
fi
rm -rf $MODPATH/system_10

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
PKG=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKGS in $PKG; do
    RES=`pm uninstall $PKGS 2>/dev/null`
  done
fi
rm -rf $MODPATH/unused
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "
# power save
FILE=$MODPATH/system/etc/sysconfig/*
if [ "`grep_prop power.save $OPTIONALS`" == 1 ]; then
  ui_print "- $MODNAME will not be allowed in power save."
  ui_print "  It may save your battery but decreasing $MODNAME performance."
  for PKGS in $PKG; do
    sed -i "s|<allow-in-power-save package=\"$PKGS\"/>||g" $FILE
    sed -i "s|<allow-in-power-save package=\"$PKGS\" />||g" $FILE
  done
  ui_print " "
fi

# function
conflict() {
for NAMES in $NAME; do
  DIR=/data/adb/modules_update/$NAMES
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAMES
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAMES/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAMES
  rm -rf /mnt/vendor/persist/magisk/$NAMES
  rm -rf /persist/magisk/$NAMES
  rm -rf /data/unencrypted/magisk/$NAMES
  rm -rf /cache/magisk/$NAMES
done
}

# conflict
NAME=MIUICore
conflict

# function
permissive_2() {
sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  magiskpolicy --live "permissive *"\
fi\' $MODPATH/post-fs-data.sh
}
permissive() {
SELINUX=`getenforce`
if [ "$SELINUX" == Enforcing ]; then
  setenforce 0
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    setenforce 1
    sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
  fi
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

# function
file_check_bin() {
for NAMES in $NAME; do
  FILE=`realpath $SYSTEM/*bin/$NAMES`
  FILE2=`realpath $SYSTEM_EXT/*bin/$NAMES`
  FILE3=`realpath $VENDOR/*bin/$NAMES`
  if [ "$FILE" ] || [ "$FILE2" ] || [ "$FILE3" ]; then
    ui_print "- Detected $NAMES"
    ui_print " "
    rm -f $MODPATH/system/bin/$NAMES
    rm -f $MODPATH/system/vendor/bin/$NAMES
  fi
done
}
file_check_system() {
for NAMES in $NAME; do
  if [ "$IS64BIT" == true ]; then
    FILE=$SYSTEM/lib64/$NAMES
    FILE2=$SYSTEM_EXT/lib64/$NAMES
    if [ -f $FILE ] || [ -f $FILE2 ]; then
      ui_print "- Detected $NAMES 64"
      ui_print " "
      rm -f $MODPATH/system/lib64/$NAMES
    fi
  fi
  FILE=$SYSTEM/lib/$NAMES
  FILE2=$SYSTEM_EXT/lib/$NAMES
  if [ -f $FILE ] || [ -f $FILE2 ]; then
    ui_print "- Detected $NAMES"
    ui_print " "
    rm -f $MODPATH/system/lib/$NAMES
  fi
done
}
file_check_vendor() {
for NAMES in $NAME; do
  if [ "$IS64BIT" == true ]; then
    FILE=$VENDOR/lib64/$NAMES
    FILE2=$ODM/lib64/$NAMES
    if [ -f $FILE ] || [ -f $FILE2 ]; then
      ui_print "- Detected $NAMES 64"
      ui_print " "
      rm -f $MODPATH/system/vendor/lib64/$NAMES
    fi
  fi
  FILE=$VENDOR/lib/$NAMES
  FILE2=$ODM/lib/$NAMES
  if [ -f $FILE ] || [ -f $FILE2 ]; then
    ui_print "- Detected $NAMES"
    ui_print " "
    rm -f $MODPATH/system/vendor/lib/$NAMES
  fi
done
}
file_check_vendor_grep() {
for NAMES in $NAME; do
  if [ "$IS64BIT" == true ]; then
    FILE=$VENDOR/lib64/$NAMES
    FILE2=$ODM/lib64/$NAMES
    SRC=$MODPATH/system/vendor/lib64/$NAMES
    if [ -f $FILE ] || [ -f $FILE2 ]; then
      ui_print "- Detected $NAMES 64"
      ui_print " "
      rm -f $SRC
    else
      TARGET="$VENDOR/lib64/$DES $ODM/lib64/$DES"
      if ! grep -q $NAMES $TARGET; then
        rm -f $SRC
      fi
    fi
  fi
  FILE=$VENDOR/lib/$NAMES
  FILE2=$ODM/lib/$NAMES
  SRC=$MODPATH/system/vendor/lib/$NAMES
  if [ -f $FILE ] || [ -f $FILE2 ]; then
    ui_print "- Detected $NAMES"
    ui_print " "
    rm -f $SRC
  else
    TARGET="$VENDOR/lib/$DES $ODM/lib/$DES"
    if ! grep -q $NAMES $TARGET; then
      rm -f $SRC
    fi
  fi
done
}

# check
NAME=shelld
file_check_bin
NAME=`ls $MODPATH/system/lib`
file_check_system
NAME=`ls $MODPATH/system/vendor/lib`
file_check_vendor

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

# unmount
if [ "$BOOTMODE" == true ] && [ ! "$MAGISKPATH" ]; then
  unmount_mirror
fi
















