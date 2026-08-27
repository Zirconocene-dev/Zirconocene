#!/usr/bin/env bash

# Pre-setup
dnf install -y dnf5-plugins
dnf config-manager setopt keepcache=1
dnf config-manager setopt fastestmirror=True
trap 'dnf config-manager setopt keepcache=0' EXIT

{ # Repo setup
    # "borrowing" some stuff from https://github.com/tulilirockz/sysext-trivalent/blob/main/install-trivalent.sh

    curl -fLsS --retry 5 -o /etc/yum.repos.d/repo.secureblue.dev.secureblue.repo https://repo.secureblue.dev/secureblue.repo

    secureblue_gpg_key_path="$(dnf repo info secureblue --json | jq -r '.[0].gpg_key.[0]')"

    rpmkeys --import "${secureblue_gpg_key_path}"

    dnf -y copr enable secureblue/packages "fedora-43-$(arch)"
}
