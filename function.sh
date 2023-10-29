# function
remove_cache() {
FILES=`find $MODPATH -type f -name *.apk | sed 's|.apk||g'`
APPS=`for FILE in $FILES; do basename $FILE; done`
for APP in $APPS; do
  rm -f `find /data/system/package_cache\
   /data/dalvik-cache /data/resource-cache\
   -type f -name *$APP*`
done
}
mount_partitions_in_recovery() {
if [ "$BOOTMODE" != true ]; then
  DIR=/dev/block/bootdevice/by-name
  DIR2=/dev/block/mapper
  mount -o rw -t auto $DIR/vendor$SLOT /vendor\
  || mount -o rw -t auto $DIR2/vendor$SLOT /vendor\
  || mount -o rw -t auto $DIR/cust /vendor\
  || mount -o rw -t auto $DIR2/cust /vendor
  mount -o rw -t auto $DIR/product$SLOT /product\
  || mount -o rw -t auto $DIR2/product$SLOT /product
  mount -o rw -t auto $DIR/system_ext$SLOT /system_ext\
  || mount -o rw -t auto $DIR2/system_ext$SLOT /system_ext
  mount -o rw -t auto $DIR/odm$SLOT /odm\
  || mount -o rw -t auto $DIR2/odm$SLOT /odm
  mount -o rw -t auto $DIR/my_product /my_product\
  || mount -o rw -t auto $DIR2/my_product /my_product
  mount -o rw -t auto $DIR/userdata /data\
  || mount -o rw -t auto $DIR2/userdata /data
  mount -o rw -t auto $DIR/cache /cache\
  || mount -o rw -t auto $DIR2/cache /cache
  mount -o rw -t auto $DIR/persist /persist\
  || mount -o rw -t auto $DIR2/persist /persist
  mount -o rw -t auto $DIR/metadata /metadata\
  || mount -o rw -t auto $DIR2/metadata /metadata
  mount -o rw -t auto $DIR/cust /cust\
  || mount -o rw -t auto $DIR2/cust /cust
fi
}
get_device() {
DEV="`cat /proc/self/mountinfo | awk '{ if ( $5 == "'$1'" ) print $3 }' | head -1 | sed 's/:/ /g'`"
}
mount_mirror() {
RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
while [ -e /dev/$RAN ]; do
  RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
done
mknod /dev/$RAN b `get_device "$1"; echo $DEV`
if mount -t ext4 -o ro /dev/$RAN "$2"\
|| mount -t erofs -o ro /dev/$RAN "$2"\
|| mount -t f2fs -o ro /dev/$RAN "$2"\
|| mount -t ubifs -o ro /dev/$RAN "$2"; then
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
mount_vendor_to_mirror() {
DIR=/vendor
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  Creating symlink instead"
    rm -rf $MIRROR$DIR
    ln -sf $MIRROR/system$DIR $MIRROR
  fi
  ui_print " "
fi
}
mount_product_to_mirror() {
DIR=/product
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  Creating symlink instead"
    rm -rf $MIRROR$DIR
    ln -sf $MIRROR/system$DIR $MIRROR
  fi
  ui_print " "
fi
}
mount_system_ext_to_mirror() {
DIR=/system_ext
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  Creating symlink instead"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system$DIR ]; then
      ln -sf $MIRROR/system$DIR $MIRROR
    fi
  fi
  ui_print " "
fi
}
mount_odm_to_mirror() {
DIR=/odm
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  Creating symlink instead"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system_root$DIR ]; then
      ln -sf $MIRROR/system_root$DIR $MIRROR
    elif [ -d $MIRROR/vendor$DIR ]; then
      ln -sf $MIRROR/vendor$DIR $MIRROR
    elif [ -d $MIRROR/system/vendor$DIR ]; then
      ln -sf $MIRROR/system/vendor$DIR $MIRROR
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
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  Creating symlink instead"
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
if [ "$SYSTEM_ROOT" == true ]; then
  DIR=/system_root
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror / $MIRROR$DIR; then
    rm -rf $MIRROR/system
    ln -sf $MIRROR$DIR/system $MIRROR
  else
    ui_print "  ! Failed"
    rm -rf $MIRROR$DIR
  fi
else
  DIR=/system
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if ! mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  ! Failed"
    rm -rf $MIRROR$DIR
  fi
fi
ui_print " "
mount_vendor_to_mirror
mount_product_to_mirror
mount_system_ext_to_mirror
mount_odm_to_mirror
mount_my_product_to_mirror
}
magisk_setup() {
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
}
remove_sepolicy_rule() {
rm -rf /metadata/magisk/"$MODID"\
 /mnt/vendor/persist/magisk/"$MODID"\
 /persist/magisk/"$MODID"\
 /data/unencrypted/magisk/"$MODID"\
 /cache/magisk/"$MODID"\
 /cust/magisk/"$MODID"
}












