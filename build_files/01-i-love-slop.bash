#!/usr/bin/env bash

set -xeuo pipefail

( # install trivalent
    dnf --best --setopt=install_weak_deps=False --repo=secureblue -y install trivalent
)

( # stuff im taking from the secureblue project lol
    dnf -y install \
      hardened_malloc \
      no_rlimit_as \
      trivalent-subresource-filter
)

( # install fish! and other cli utils :3c
    dnf -y install fish bat wget # WHY IS WGET MISSING??????
)

( # install podman compose lol
    dnf -y install podman-compose
)

( # install usb-wakeup-control in the container :p
    cd /ctx/build/usb-wakeup-control/
    install -m0755 usb-wakeup-control.sh /usr/bin/usb-wakeup-control
    install -Dm644 usb-wakeup-control.service -t /etc/systemd/system
    systemctl enable usb-wakeup-control
)

( # install usb-guard
    dnf -y install usbguard usbguard-notifier usbguard-tools
    systemctl enable usbguard
)

( # install system-config-printer (only libs and udev by default for some reason???
    dnf -y install system-config-printer system-config-printer-applet
)

( # install nm-connection-editor
    dnf -y install nm-connection-editor-desktop nm-connection-editor
)

( # dnscrypt-proxy
    dnf -y install dnscrypt-proxy
)

( # uninstall tailscale, i don't feel like using it
    dnf -y remove tailscale
)

# copyyyyyy
cp -avf "/ctx/files"/. /
