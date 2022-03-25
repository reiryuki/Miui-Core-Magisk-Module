PKG="com.miui.rom
     com.miui.core
     com.miui.system
     com.xiaomi.micloud.sdk"
for PKGS in $PKG; do
  rm -rf /data/user/*/$PKGS/cache/*
done


