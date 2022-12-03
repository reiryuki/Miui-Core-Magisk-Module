# space
if [ "$BOOTMODE" == true ]; then
  ui_print " "
fi

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`realpath /dev/*/.magisk`
fi

# path
if [ "$BOOTMODE" == true ]; then
  MIRROR=$MAGISKTMP/mirror
else
  MIRROR=
fi
SYSTEM=`realpath $MIRROR/system`
PRODUCT=`realpath $MIRROR/product`
VENDOR=`realpath $MIRROR/vendor`
SYSTEM_EXT=`realpath $MIRROR/system_ext`
if [ -d $MIRROR/odm ]; then
  ODM=`realpath $MIRROR/odm`
else
  ODM=`realpath /odm`
fi
if [ -d $MIRROR/my_product ]; then
  MY_PRODUCT=`realpath $MIRROR/my_product`
else
  MY_PRODUCT=`realpath /my_product`
fi

# optionals
OPTIONALS=/sdcard/optionals.prop

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
ui_print " MagiskVersion=$MAGISK_VER"
ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
ui_print " "

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

# mount
if [ "$BOOTMODE" != true ]; then
  mount -o rw -t auto /dev/block/bootdevice/by-name/cust /vendor
  mount -o rw -t auto /dev/block/bootdevice/by-name/vendor /vendor
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi

# sepolicy.rule
FILE=$MODPATH/sepolicy.sh
DES=$MODPATH/sepolicy.rule
if [ -f $FILE ] && [ "`grep_prop sepolicy.sh $OPTIONALS`" != 1 ]; then
  mv -f $FILE $DES
  sed -i 's/magiskpolicy --live "//g' $DES
  sed -i 's/"//g' $DES
fi

# function
NAME=_ZN7android23sp_report_stack_pointerEv
FILE=$SYSTEM/lib/libandroid_runtime.so
FILE2=$SYSTEM/lib64/libandroid_runtime.so
if [ "$IS64BIT" == true ]; then
  ui_print "- Checking $NAME function..."
  if ! grep -Eq $NAME $FILE\
  || ! grep -Eq $NAME $FILE2; then
    ui_print "  Using legacy libraries"
    cp -rf $MODPATH/system_10/* $MODPATH/system
  fi
else
  ui_print "- Checking $NAME function..."
  if ! grep -Eq $NAME $FILE; then
    ui_print "  Using legacy libraries"
    cp -rf $MODPATH/system_10/* $MODPATH/system
  fi
fi
rm -rf $MODPATH/system_10
ui_print " "

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
PKG="com.miui.rom
     com.miui.core
     com.miui.system
     com.xiaomi.micloud.sdk"
if [ "$BOOTMODE" == true ]; then
  for PKGS in $PKG; do
    RES=`pm uninstall $PKGS`
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
    sed -i "s/<allow-in-power-save package=\"$PKGS\"\/>//g" $FILE
    sed -i "s/<allow-in-power-save package=\"$PKGS\" \/>//g" $FILE
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
hide_oat() {
for APPS in $APP; do
  mkdir -p `find $MODPATH/system -type d -name $APPS`/oat
  touch `find $MODPATH/system -type d -name $APPS`/oat/.replace
done
}

# hide
APP="`ls $MODPATH/system/priv-app`
     `ls $MODPATH/system/app` framework-ext-res"
hide_oat

# move
if [ "`grep_prop miui.public $OPTIONALS`" != 0 ]; then
  ui_print "- Using vendor public libraries method"
  NAME="libmiuinative.so libmiuiblur.so libthemeutils_jni.so
        libshell_jni.so libshell.so libmiuixlog.so
        libimage_arcsoft_4plus.so libstlport_shared.so"
  for NAMES in $NAME; do
    mv -f $MODPATH/system/lib/$NAMES $MODPATH/system/vendor/lib
    mv -f $MODPATH/system/lib64/$NAMES $MODPATH/system/vendor/lib64
  done
  cp -f $MODPATH/system/vendor/lib/libshell_jni.so $MODPATH/system/lib/modshell_jni.so
  cp -f $MODPATH/system/vendor/lib64/libshell_jni.so $MODPATH/system/lib64/modshell_jni.so
  FILE="$MODPATH/system/bin/shelld
        $MODPATH/system/lib*/modshell_jni.so"
  sed -i 's/libshell_jni.so/modshell_jni.so/g' $FILE
  cp -f $MODPATH/system/vendor/lib/libshell.so $MODPATH/system/lib/modshell.so
  cp -f $MODPATH/system/vendor/lib64/libshell.so $MODPATH/system/lib64/modshell.so
  sed -i 's/libshell.so/modshell.so/g' $MODPATH/system/lib*/*shell*.so
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
      if ! grep -Eq $NAMES $TARGET; then
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
    if ! grep -Eq $NAMES $TARGET; then
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

# permission
ui_print "- Setting permission..."
FILE=`find $MODPATH/system/bin\
           $MODPATH/system/vendor/bin -type f`
for FILES in $FILE; do
  chmod 0755 $FILES
done
chmod 0751 $MODPATH/system/bin
chmod 0751 $MODPATH/system/vendor/bin
if [ "$API" -ge 26 ]; then
  DIR=`find $MODPATH/system/bin\
            $MODPATH/system/vendor -type d`
  for DIRS in $DIR; do
    chown 0.2000 $DIRS
  done
  FILE=`find $MODPATH/system/bin\
             $MODPATH/system/vendor/bin -type f`
  for FILES in $FILE; do
    chown 0.2000 $FILES
  done
fi
ui_print " "


