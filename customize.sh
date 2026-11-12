#!/system/bin/sh
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/sysui_profile.sh" 0 0 0755
set_perm "$MODPATH/system/product/overlay/PipResizeUnlockOverlay.apk" 0 0 0644
if [ "$KSU" = true ]; then
    sh "$MODPATH/sysui_profile.sh" on
    ui_print "- Set SystemUI to keep module mounts (KernelSU app profile)."
fi
ui_print "- PiP Resize Unlock installed. Reboot to apply."
