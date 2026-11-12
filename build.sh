#!/bin/sh
# Builds the framework overlay APK and packages the KernelSU/Magisk module zip.
set -e
cd "$(dirname "$0")"

SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
BT="$SDK/build-tools/$(ls "$SDK/build-tools" | sort -V | tail -1)"
JAR="$SDK/platforms/$(ls "$SDK/platforms" | sort -V | tail -1)/android.jar"
KS="${KEYSTORE:-$HOME/.android/debug.keystore}"
VERSION=$(sed -n 's/^version=//p' module.prop)

OUT=build
rm -rf "$OUT" && mkdir -p "$OUT/flat" "$OUT/module/system/product/overlay"

"$BT/aapt2" compile --dir overlay/res -o "$OUT/flat"
"$BT/aapt2" link -I "$JAR" --manifest overlay/AndroidManifest.xml \
    -o "$OUT/unsigned.apk" "$OUT"/flat/*.flat
"$BT/zipalign" -f 4 "$OUT/unsigned.apk" "$OUT/aligned.apk"
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android --v4-signing-enabled false \
    --out "$OUT/module/system/product/overlay/PipResizeUnlockOverlay.apk" "$OUT/aligned.apk"

cp -r module.prop customize.sh post-fs-data.sh uninstall.sh sysui_profile.sh META-INF "$OUT/module/"
rm -f "moto-pip-resize-$VERSION.zip"
(cd "$OUT/module" && zip -qr "../../moto-pip-resize-$VERSION.zip" .)
echo "Built moto-pip-resize-$VERSION.zip"
