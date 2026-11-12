#!/system/bin/sh
# Runs before zygote, so SystemUI starts with the module mounts in place.
MODDIR=${0%/*}
sh "$MODDIR/sysui_profile.sh" on
