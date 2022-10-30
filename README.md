# Miui Core Magisk Module

## Descriptions
- System core framework library of Miui ROM as a dependency of any ported Miui apps (non-Play Store version) Magisk modules.
- For Magisk module developers, your Miui app must declare these lines after `<application />` in the AndroidManifest.xml if you want to load classes from this Miui Core: (Do not do this if your app have it's own library!)

  `<uses-library android:name="com.miui.system" android:required="false" />`

  `<uses-library android:name="com.miui.rom" android:required="false" />`

  `<uses-library android:name="com.miui.core" android:required="false" />`

## Sources
- https://dumps.tadiphone.dev/dumps/xiaomi/cepheus cepheus-user-11-RKQ1.200826.002-V12.5.3.0.RFACNXM-release-keys
- libmiuiblur.so: https://github.com/dimasyudhaproject/packages_apps_ANXCamera/blob/f0f7012c045b2b9baa5e36aba3a8319512dfbdd3
- libshellservice.so: https://github.com/mcfy49/MIUI-8-a3xeltexx/blob/8f60fbb9cdeca47bffea429c86f4a02d9eecfdb8
- system_10: https://dumps.tadiphone.dev/dumps/xiaomi/ginkgo ginkgo-user-10-QKQ1.200114.002-V12.0.6.0.QCOEUXM-release-keys
- libbccQTI.so: https://github.com/takumi021/vendor_realme_r5x_11/blob/f49c65888b50d856f96ec86d043514f6ac8adb90
- librs_adreno_sha1.so: https://github.com/Aknx77/vendor_xiaomi_vince/blob/e864e2f88d4407ebf8ebdde8b79e6fab350a91be
- libmiui_runtime.so: https://dumps.tadiphone.dev/dumps/redmi/alioth qssi-user-12-SKQ1.211230.001-22.2.23-release-keys

## Requirements
- NOT in Miui ROM
- Android 5 and up
- Magisk installed

## Installation Guide & Download Link
- Install this module https://www.pling.com/p/1537512/ via Magisk app or recovery
- Install any Miui app Magisk Module bellow
- Reboot

## Miui Apps Magisk Modules Available
- https://github.com/reiryuki/Mi-Music-Magisk-Module
- https://github.com/reiryuki/Mi-Sound-Redmi-M2012K11AC-Magisk-Module
- https://github.com/reiryuki/Miui-Gallery-Magisk-Module
- https://github.com/reiryuki/Miui-Screen-Recorder-Magisk-Module
- https://github.com/reiryuki/Miui-Security-Center-Magisk-Module
- https://github.com/reiryuki/Miui-Home-Magisk-Module
- https://github.com/reiryuki/Miui-Clock-Magisk-Module

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


