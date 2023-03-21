mount -o rw,remount /data
if [ ! "$MODPATH" ]; then
  MODPATH=${0%/*}
fi
if [ ! "$MODID" ]; then
  MODID=`echo "$MODPATH" | sed 's|/data/adb/modules/||' | sed 's|/data/adb/modules_update/||'`
fi

# cleaning
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app` framework-ext-res"
for APPS in $APP; do
  rm -f `find /data/system/package_cache -type f -name *$APPS*`
  rm -f `find /data/dalvik-cache /data/resource-cache -type f -name *$APPS*.apk`
done
PKG=`cat $MODPATH/package.txt`
for PKGS in $PKG; do
  rm -rf /data/user*/*/$PKGS
done
rm -rf /metadata/magisk/"$MODID"
rm -rf /mnt/vendor/persist/magisk/"$MODID"
rm -rf /persist/magisk/"$MODID"
rm -rf /data/unencrypted/magisk/"$MODID"
rm -rf /cache/magisk/"$MODID"


