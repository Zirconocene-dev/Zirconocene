#!/usr/bin/env bash

set -xeuo pipefail

dnf install -y dnf5-plugins

dnf config-manager setopt keepcache=1
dnf config-manager setopt fastestmirror=True
trap 'dnf config-manager setopt keepcache=0' EXIT

( # install trivalent
# "borrowing" from https://github.com/tulilirockz/sysext-trivalent/blob/main/install-trivalent.sh
    curl -fLsS --retry 5 -o /etc/yum.repos.d/repo.secureblue.dev.secureblue.repo https://repo.secureblue.dev/secureblue.repo

    dnf --best --repo=secureblue -y install trivalent

    secureblue_gpg_key_path="$(dnf repo info secureblue --json | jq -r '.[0].gpg_key.[0]')"

    rpmkeys --import "${secureblue_gpg_key_path}"
)

( # stuff im taking from the secureblue project lol
    dnf -y copr enable secureblue/packages "fedora-43-$(arch)"
    dnf -y install \
      hardened_malloc \
      no_rlimit_as \
      trivalent-subresource-filter
)

( # install fish! and other cli utils :3c
    dnf -y install fish bat
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

( # uninstall tailscale, i don't feel like using it
    dnf -y remove tailscale
)

# copyyyyyy
cp -avf "/ctx/files"/. /
