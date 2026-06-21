mount -o rw,remount /data
[ ! "$MODPATH" ] && MODPATH=${0%/*}
[ ! "$MODID" ] && MODID=`basename "$MODPATH"`
UID=`id -u`
[ ! "$UID" ] && UID=0

# log
DIR=/data/adb/logs
mkdir -p $DIR
exec 2>$DIR/$MODID\_uninstall.log
set -x

# run
. $MODPATH/function.sh

# cleaning
remove_cache
PKGS=`cat $MODPATH/package.txt`
for PKG in $PKGS; do
  rm -rf /data/user*/"$UID"/$PKG
done
remove_sepolicy_rule









