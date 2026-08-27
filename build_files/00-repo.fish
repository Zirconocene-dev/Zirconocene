#!/usr/bin/env fish

set fish_trace 1

# Pre-setup
dnf config-manager setopt keepcache=1
dnf config-manager setopt fastestmirror=True

# Do all our work inside of here :3
pushd /ctx/build

{ # Repo setup
    # "borrowing" some stuff from https://github.com/tulilirockz/sysext-trivalent/blob/main/install-trivalent.sh

    for i in (find gpgKeys/ -name '*.gpg')
        rpmkeys --import $i
    end
    curl -fLsS --retry 5 -o /etc/yum.repos.d/repo.secureblue.dev.secureblue.repo https://repo.secureblue.dev/secureblue.repo

    dnf -y copr enable secureblue/packages "fedora-43-$(arch)"
}
