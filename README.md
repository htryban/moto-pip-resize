# PiP Resize Unlock

A KernelSU / Magisk module that lets picture-in-picture windows (YouTube,
Maps, video players) be pinched much smaller than Android normally allows.

## What limits the size

SystemUI's window manager shell computes the smallest PiP size from three
values:

| Resource | Stock | This module |
| --- | --- | --- |
| `default_minimal_size_pip_resizable_task` (shortest edge floor) | 108dp | 48dp |
| `config_pipSystemPreferredMinimumSizePercent` (min as a share of max size) | 0.5 | 0.2 |
| `config_pipSystemPreferredMinimumSizePercentForSquareDisplay` | 0.4 | 0.15 |

The module lowers them with a static resource overlay on SystemUI.

On a Razr Fold 2026 the smallest 16:9 window goes from 505×284 px to
224×126 px on the cover screen, and from 1074×604 px to 430×242 px on the
inner screen.

Edit `overlay/res/values/pip.xml` and rebuild to choose other limits.

## KernelSU: SystemUI's app profile

KernelSU unmounts module files from app processes by default, and SystemUI
runs as an app, so it never sees the overlay. On KernelSU the module sets
SystemUI's app profile to keep module mounts. It does this at install, and
again before zygote on each boot if the setting was lost. Removing the module
puts the profile back to the default.

KernelSU saves app profiles and root grants to one file in the background,
whenever `init` next wakes up. Rebooting before that save finishes leaves the
file empty, and every app loses root. The module forces the save right away
and syncs it, so this can't happen after it changes the profile.

Magisk needs nothing extra, as long as SystemUI isn't on the DenyList.

## Install

Flash `moto-pip-resize-<version>.zip` from the KernelSU or Magisk manager and
reboot.

## Build

Requires the Android SDK (build-tools and a platform `android.jar`):

```sh
./build.sh
```

The overlay is signed with `~/.android/debug.keystore` unless `KEYSTORE` is
set.

## License

MIT
