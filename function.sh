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
  BLOCK=/dev/block/bootdevice/by-name
  BLOCK2=/dev/block/mapper
  ui_print "- Recommended to mount all partitions first"
  ui_print "  before installing this module"
  ui_print " "
  DIR=/vendor
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR$SLOT $DIR\
    || mount -o rw -t auto $BLOCK2$DIR$SLOT $DIR\
    || mount -o rw -t auto $BLOCK/cust $DIR\
    || mount -o rw -t auto $BLOCK2/cust $DIR
  fi
  DIR=/product
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR$SLOT $DIR\
    || mount -o rw -t auto $BLOCK2$DIR$SLOT $DIR
  fi
  DIR=/system_ext
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR$SLOT $DIR\
    || mount -o rw -t auto $BLOCK2$DIR$SLOT $DIR
  fi
  DIR=/odm
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR$SLOT $DIR\
    || mount -o rw -t auto $BLOCK2$DIR$SLOT $DIR
  fi
  DIR=/my_product
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR $DIR\
    || mount -o rw -t auto $BLOCK2$DIR $DIR
  fi
  DIR=/data
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK/userdata $DIR\
    || mount -o rw -t auto $BLOCK2/userdata $DIR
  fi
  DIR=/cache
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR $DIR\
    || mount -o rw -t auto $BLOCK2$DIR $DIR
  fi
  DIR=/persist
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR $DIR\
    || mount -o rw -t auto $BLOCK2$DIR $DIR
  fi
  DIR=/metadata
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR $DIR\
    || mount -o rw -t auto $BLOCK2$DIR $DIR
  fi
  DIR=/cust
  if [ -d $DIR ] && ! is_mounted $DIR; then
    mount -o rw -t auto $BLOCK$DIR $DIR\
    || mount -o rw -t auto $BLOCK2$DIR $DIR
  fi
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
|| mount -t auto -o ro /dev/$RAN "$2"; then
  blockdev --setrw /dev/$RAN
  rm -f /dev/$RAN
  return 0
fi
rm -f /dev/$RAN
return 1
}
unmount_mirror() {
if [ "$BOOTMODE" == true ]\
&& [ "$HASMIRROR" == false ]; then
  FOLDS="$MIRROR/* $MIRROR"
  for FOLD in $FOLDS; do
    umount $FOLD
  done
  rm -rf $MIRROR/*
fi
}
remount_partitions() {
PARS="/ /system /vendor /product /system_ext /odm /my_product"
for PAR in $PARS; do
  mount -o ro,remount $PAR
done
}
mount_system_to_mirror() {
DIR=/system
if [ ! -d $MIRROR$DIR ]; then
  HASMIRROR=false
  remount_partitions
  unmount_mirror
  ui_print "- Mounting $MIRROR$DIR..."
  if [ "$SYSTEM_ROOT" == true ]\
  || [ "$SYSTEM_AS_ROOT" == true ]; then
    mkdir -p $MIRROR/system_root
    if mount_mirror / $MIRROR/system_root; then
      rm -rf $MIRROR$DIR
      ln -sf $MIRROR/system_root$DIR $MIRROR
    else
      ui_print "  ! Failed"
      rm -rf $MIRROR/system_root
    fi
  else
    mkdir -p $MIRROR$DIR
    if ! mount_mirror $DIR $MIRROR$DIR; then
      ui_print "  ! Failed"
      rm -rf $MIRROR$DIR
    fi
  fi
  ui_print " "
else
  HASMIRROR=true
fi
}
mount_vendor_to_mirror() {
DIR=/vendor
if [ -d $DIR ] && [ ! -d $MIRROR$DIR ]; then
  ui_print "- Mounting $MIRROR$DIR..."
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
mount_product_to_mirror() {
DIR=/product
if [ -d $DIR ] && [ ! -d $MIRROR$DIR ]; then
  ui_print "- Mounting $MIRROR$DIR..."
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
mount_system_ext_to_mirror() {
DIR=/system_ext
if [ -d $DIR ] && [ ! -d $MIRROR$DIR ]; then
  ui_print "- Mounting $MIRROR$DIR..."
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
if [ -d $DIR ] && [ ! -d $MIRROR$DIR ]; then
  ui_print "- Mounting $MIRROR$DIR..."
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
if [ -d $DIR ] && [ ! -d $MIRROR$DIR ]; then
  ui_print "- Mounting $MIRROR$DIR..."
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
mount_system_to_mirror
mount_vendor_to_mirror
mount_product_to_mirror
mount_system_ext_to_mirror
mount_odm_to_mirror
mount_my_product_to_mirror
}
magisk_setup() {
MAGISKTMP=`magisk --path`
if [ "$BOOTMODE" == true ]; then
  if [ "$MAGISKTMP" ]; then
    mount -o rw,remount $MAGISKTMP
    INTERNALDIR=$MAGISKTMP/.magisk
    MIRROR=$INTERNALDIR/mirror
  else
    INTERNALDIR=/mnt
    mount -o rw,remount $INTERNALDIR
    MIRROR=$INTERNALDIR/mirror
  fi
  mount_partitions_to_mirror
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












