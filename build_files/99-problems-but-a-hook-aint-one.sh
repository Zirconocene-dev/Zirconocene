#!/usr/bin/env bash

set -xeuo pipefail

sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Zirconocene\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Zirconocene\"|
EOF

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
chmod 644 /etc/ssh/ssh_config.d/20-systemd-ssh-proxy.conf
# ^ stupid fucking fix i shouldnt need to do but i fucking have to aaaaaa
