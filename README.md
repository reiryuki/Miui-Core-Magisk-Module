# Miui Core Magisk Module

## DISCLAIMER
- Miui apps and blobs are owned by Xiaomi™.
- The MIT license specified here is for the Magisk Module only, not for Miui apps and blobs.

## Descriptions
- System core framework library of Miui ROM ported from Xiaomi Mi 9 (cepheus) as a dependency of any Miui app and Miui Magisk Module
- With this module, you can even normal install any non-system Miui app: https://apkmirror.com/apk/xiaomi-inc

## For Miui App Porter
- You can declare this line in your app AndroidManifest.xml after `<application />` if you want to load classes from this Miui Core:

  `<uses-library android:name="miui" android:required="false" />`

- You can declare this line if you want to load classes from this Miui Core and also resources from miuisystem.apk (causes crash in some ROMs):

  `<uses-library android:name="com.miui.system" android:required="false" />`

- You can declare this line if you want to load resources from framework-ext-res.apk (causes crash in some ROMs):

  `<uses-library android:name="com.miui.rom" android:required="false" />`

- You can declare this line if you want to load resources from miui.apk (causes crash in some ROMs):

  `<uses-library android:name="com.miui.core" android:required="false" />`

- Do not white list those libraries with your own Magisk Module /system/etc/permissions/ because there might be a conflict.
- You don't need to declare all of those but just declare which is needed only.

## Sources
- https://dumps.tadiphone.dev/dumps/xiaomi/cepheus cepheus-user-11-RKQ1.200826.002-V12.5.3.0.RFACNXM-release-keys
- https://dumps.tadiphone.dev/dumps/redmi/alioth qssi-user-12-SKQ1.211006.001-22.1.19-release-keys
- libmiuiblur.so: https://github.com/dimasyudhaproject/packages_apps_ANXCamera
- libshellservice.so: https://github.com/mcfy49/MIUI-8-a3xeltexx
- system_10: https://dumps.tadiphone.dev/dumps/xiaomi/ginkgo ginkgo-user-10-QKQ1.200114.002-V12.0.6.0.QCOEUXM-release-keys
- libbccQTI.so: https://github.com/takumi021/vendor_realme_r5x
- librs_adreno_sha1.so: https://github.com/Aknx77/vendor_xiaomi_vince
- libmiui_runtime.so: https://dumps.tadiphone.dev/dumps/redmi/alioth qssi-user-12-SKQ1.211006.001-22.1.19-release-keys
- MiuiBooster.jar: https://dumps.tadiphone.dev/dumps/redmi/alioth missi_phoneext4_global-user-13-TKQ1.220829.002-V14.0.7.0.TKHMIXM-release-keys
- yellowpage-common.jar: https://github.com/respkirya/Miui-v6

## Requirements
- NOT in Miui ROM
- Architecture arm64 or arm
- Android 5 and up
- Magisk or KernelSU installed

## Installation Guide & Download Link
- Install this module https://www.pling.com/p/1537512/ via Magisk app or KernelSU app or Recovery if Magisk installed
- Install any Miui app or Miui Magisk Module which depends on this module
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (enable show system apps) and reboot after

## Miui Magisk Modules Available
- https://github.com/reiryuki/Mi-Music-Magisk-Module
- https://github.com/reiryuki/Mi-Sound-Redmi-K40-Magisk-Module
- https://github.com/reiryuki/Miui-Gallery-Magisk-Module
- https://github.com/reiryuki/Miui-Screen-Recorder-Magisk-Module
- https://github.com/reiryuki/Miui-Security-Center-Magisk-Module
- https://github.com/reiryuki/Miui-Home-Magisk-Module
- https://github.com/reiryuki/Miui-Clock-Magisk-Module
- https://github.com/iamr0s/MiShare-Magisk-Module

## Tested on
- Android 10 CrDroid ROM 
- Android 11 DotOS ROM
- Android 12 Ancient OS ROM
- Android 12.1 Nusantara ROM
- Android 13 Nusantara ROM, AOSP ROM, & CrDroid ROM

## Optionals
- https://t.me/androidryukimodsdiscussions/54012
- Global: https://t.me/androidryukimodsdiscussions/60861

## Troubleshootings
- Global: https://t.me/androidryukimodsdiscussions/29836

## Support & Bug Report
- https://t.me/androidryukimodsdiscussions/2618
- If you don't do above, issues will be closed immediately

## Credits and contributors
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Thanks for Donations
This Magisk Module is always will be free but you can however show us that you are care by making a donations:
- https://ko-fi.com/reiryuki
- https://www.paypal.me/reiryuki
- https://t.me/androidryukimodsdiscussions/2619


