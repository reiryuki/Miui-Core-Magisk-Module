# Miui Core Magisk Module

## Descriptions
- System core framework of Miui ROM ported for non-Miui ROM as a dependency of any Miui apps (non-Play Store version) Magisk modules.
- For developers, your Miui app must declare these lines after `<application />` in the AndroidManifest.xml if you want to load classes from this Miui Core: (Do not do this if your app have it's own classes!)

  `<uses-library android:name="com.miui.core" android:required="false" />`

  `<uses-library android:name="com.miui.system" android:required="false" />`

This line is only required for v2.4 and bellow:
  `<uses-library android:name="miuiframework" android:required="false" />`

## Requirements
- Not in Miui ROM
- Android 6 until 12
- Magisk installed

## Installation Guide
- Install via Magisk app or Recovery
- Install any of Miui app Magisk Module which depended with this Miui Core Magisk Module
- Reboot

## Miui Apps Magisk Modules Available
- https://github.com/reiryuki/Miui-Gallery-Magisk-Module
- https://github.com/reiryuki/Miui-Screen-Recorder-Magisk-Module
- https://github.com/reiryuki/Miui-Security-Center-Magisk-Module

## Tested on
- CrDroid ROM Android 10 arm64
- DotOS ROM Android 11 arm64

## Optional

## Troubleshootings

## Bug Report
- https://t.me/androidryukimodsdiscussions/2618
- If you don't do above, it will be closed immediately

## Credits and contributors
- Android Ryuki Mods Discussions Team
- https://t.me/androidryukimodsdiscussions/25188

## Thanks for Donations
- https://t.me/androidryukimodsdiscussions/2619
- https://www.paypal.me/reiryuki

## Download
- Tap here > https://www.pling.com/p/1537512/
- D version = using ro.product.device for detecting device specific
- N version = using ro.product.name for detecting device specific
- Use whichever version you want


