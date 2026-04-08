#!/bin/fish
# NEEDS to be run INSIDE of zirconocene, cus it requires gpg keys to be present in /usr/etc/pki/rpm-gpg/

set fish_trace 1
mkdir -p output

sudo podman run \
    --rm -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t -v "./iso.toml:/config.toml:ro" \
    -v ./output/:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v /usr/etc/pki/rpm-gpg/:/etc/pki/rpm-gpg/:ro \
    quay.io/centos-bootc/bootc-image-builder:latest --type iso --rootfs btrfs --use-librepo=True \
    quay.io/fluoritebyte/zirconocene
