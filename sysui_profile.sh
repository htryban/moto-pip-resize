#!/system/bin/sh
# KernelSU unmounts module files from app processes by default, and SystemUI
# runs as an app. Without its module mounts it can't open the overlay APK, so
# the PiP size change never reaches it. This sets SystemUI's KernelSU app
# profile to keep module mounts (on), or back to the default (off).
#
# Usage: sysui_profile.sh on|off
# Magisk needs nothing here: SystemUI isn't on the DenyList by default.

KSUD=/data/adb/ksu/bin/ksud
PKG=com.android.systemui
[ -x "$KSUD" ] || exit 0

if [ "$1" = on ]; then
    USE_DEFAULT=false; UMOUNT=false
else
    USE_DEFAULT=true; UMOUNT=true
fi

CUR=$("$KSUD" profile get $PKG 2>/dev/null | tr -d ' \n')
[ -n "$CUR" ] || exit 0
case "$CUR" in
    *"\"use_default\":$USE_DEFAULT,\"umount_modules\":$UMOUNT"*) exit 0 ;;
esac
UID_=$(echo "$CUR" | sed -n 's/.*"uid":\([0-9]*\).*/\1/p')
ALLOWLIST=/data/adb/ksu/.allowlist
OLD=$(stat -c %Y "$ALLOWLIST" 2>/dev/null)
sleep 1  # make sure the save gets a newer mtime
echo "{\"key\":\"$PKG\",\"uid\":$UID_,\"allow_su\":false,\"non_root\":{\"use_default\":$USE_DEFAULT,\"umount_modules\":$UMOUNT}}" \
    | "$KSUD" profile set -

# KernelSU saves its allowlist file (every app's root grant and profile)
# from init's context, the next time init wakes up, which can be seconds or
# minutes later. A reboot before then loses every root grant. Setting a
# property wakes init, so the save happens now; wait for it, then flush it.
setprop debug.moto_pip_resize.flush "$(date +%s)"
i=0
while [ $i -lt 20 ] && [ "$(stat -c %Y "$ALLOWLIST" 2>/dev/null)" = "$OLD" ]; do
    sleep 0.5; i=$((i + 1))
done
sync
