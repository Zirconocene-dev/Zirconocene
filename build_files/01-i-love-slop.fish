#!/usr/bin/env fish

# Download form dnf download --arch $(uname -m) --resolve --best
# Install form --best
# BOTH: --repo=

# Disable cache after we are done
trap 'dnf config-manager setopt keepcache=0' EXIT

# Do all our work inside of here :3
pushd /ctx/build

set -a package_sets (sed '/#/d' packages)

for i in $package_sets
    set -l packages (echo $i | grep -oE '^"[^"]*"' | sed 's/"//g')
    set -l args (echo $i | grep -oE ':.*$' | sed 's/://')
    echo "Set ( $packages : $args )"
    dnf -y install $args -- $packages
end

{ # install usb-wakeup-control in the container :p
    echo cd /ctx/build/usb-wakeup-control/
    echo install -m0755 usb-wakeup-control.sh /usr/bin/usb-wakeup-control
    echo install -Dm644 usb-wakeup-control.service -t /etc/systemd/system
    echo systemctl enable usb-wakeup-control
}

{ # enable usbguard
    echo systemctl enable usbguard
}

{ # uninstall tailscale, i don't feel like using it
    echo dnf -y remove tailscale
}

# copyyyyyy
cp -avf "/ctx/files"/. /
