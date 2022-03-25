(

MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`

if ! getprop | grep -Eq init.svc.shelld; then
  shelld &
  resetprop init.svc.shelld running
fi

if ! getprop | grep -Eq init.svc_debug_pid.shelld; then
  PID=`pidof shelld`
  resetprop init.svc_debug_pid.shelld $PID
fi

sleep 60

PKG=com.miui.system
if [ "$API" -gt 29 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

PKG=com.miui.rom
if [ "$API" -gt 29 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

PKG=com.miui.core
pm grant $PKG android.permission.READ_PHONE_STATE
if [ "$API" -gt 29 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

PKG=com.xiaomi.micloud.sdk
if [ "$API" -gt 29 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

) 2>/dev/null


