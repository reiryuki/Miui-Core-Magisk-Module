# Miui Core Magisk Module

## DISCLAIMER
- Miui apps and blobs are owned by Xiaomi™.
- The MIT license specified here is for the Magisk Module, not for Miui apps and blobs.

## Descriptions
- System core framework library of Miui ROM ported from Xiaomi Mi 9 (cepheus) as a dependency of any Miui app and Miui Magisk Module.
- For Miui apps porter, your app must declare these lines after `<application />` in the AndroidManifest.xml if you want to load classes from this Miui Core: (Do not do this if your app have it's own library!)

  `<uses-library android:name="com.miui.system" android:required="false" />`

  `<uses-library android:name="com.miui.rom" android:required="false" />`

  `<uses-library android:name="com.miui.core" android:required="false" />`

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
- Android 5 and up
- Magisk installed

## Installation Guide & Download Link
- Install this module https://www.pling.com/p/1537512/ via Magisk app or recovery
- Install any Miui app Magisk Module bellow
- Reboot

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


