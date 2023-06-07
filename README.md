# Miui Core Magisk Module

## DISCLAIMER
- Miui apps and blobs are owned by Xiaomi™.
- The MIT license specified here is for the Magisk Module, not for Miui apps and blobs.

## Descriptions
- System core framework library of Miui ROM ported from Xiaomi Mi 9 (cepheus) as a dependency of any Miui app and Miui Magisk Module
- With this module, you can even normal install any non-system Miui app: apkmirror.com/apk/xiaomi-inc

## For Miui App Porter
- You can declare these lines bellow in your app AndroidManifest.xml after `<application />` if you want to load classes and resources from this Miui Core:

  `<uses-library android:name="com.miui.system" android:required="false" />`

  `<uses-library android:name="com.miui.rom" android:required="false" />`

  `<uses-library android:name="com.miui.core" android:required="false" />`
  
- Those libraries can even make your app crash in some ROMs caused by conflicted resources.
- If com.miui.system library causes your app crashed, then use this line instead:

  `<uses-library android:name="miui" android:required="false" />`

- Do not do above if your app have it's own libraries!
- Do not white list those libraries with your own Magisk Module /system/etc/permissions/ because there might be a conflict.
- You don't need to declare all of those but just declare which is needed.

## Sources
- https://dumps.tadiphone.dev/dumps/xiaomi/cepheus cepheus-user-11-RKQ1.200826.002-V12.5.3.0.RFACNXM-release-keys
- https://dumps.tadiphone.dev/dumps/redmi/alioth qssi-user-12-SKQ1.211006.001-22.1.19-release-keys
- libmiuiblur.so: https://github.com/dimasyudhaproject/packages_apps_ANXCamera
- libshellservice.so: https://github.com/mcfy49/MIUI-8-a3xeltexx
- system_10: https://dumps.tadiphone.dev/dumps/xiaomi/ginkgo ginkgo-user-10-QKQ1.200114.002-V12.0.6.0.QCOEUXM-release-keys
- libbccQTI.so: https://github.com/takumi021/vendor_realme_r5x
- librs_adreno_sha1.so: https://github.com/Aknx77/vendor_xiaomi_vince
- libmiui_runtime.so: https://dumps.tadiphone.dev/dumps/redmi/alioth qssi-user-12-SKQ1.211006.001-22.1.19-release-keys
- yellowpage-common.jar: https://github.com/respkirya/Miui-v6

## Requirements
- NOT in Miui ROM
- Architecture arm64 or arm
- Android 5 and up
- Magisk or KernelSU installed

## Installation Guide & Download Link
- Install this module https://www.pling.com/p/1537512/ via Magisk app or KernelSU app or Recovery (unless you are using KernelSU)
- Install any Miui app or Miui Magisk Module which depends on this module
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt and reboot after

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
- Android 13 Nusantara ROM
- Android 13 AOSP ROM
- Android 13 CrDroid ROM

## Optionals
- https://t.me/androidryukimodsdiscussions/60861

## Troubleshootings
- https://t.me/androidryukimodsdiscussions/29836

## Support & Bug Report
- https://t.me/androidryukimodsdiscussions/2618
- If you don't do above, issues will be closed immediately

## Credits and contributors
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Thanks for Donations
- This Magisk Module is always will be free but you can however show us that you are care by making a donations:
- https://ko-fi.com/reiryuki
- https://www.paypal.me/reiryuki
- https://t.me/androidryukimodsdiscussions/2619


