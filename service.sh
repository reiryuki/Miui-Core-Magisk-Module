MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

# debug
exec 2>$MODPATH/debug.log
set -x

# function
run_service() {
PID=`pidof $FILE`
if [ ! "$PID" ]; then
  $FILE &
  PID=`pidof $FILE`
fi
}

# run
FILE=shelld
run_service

# wait
sleep 60

# allow
PKG=com.miui.system
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# allow
PKG=com.miui.rom
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# grant
PKG=com.miui.core
pm grant $PKG android.permission.READ_PHONE_STATE
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# allow
PKG=com.xiaomi.micloud.sdk
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi


