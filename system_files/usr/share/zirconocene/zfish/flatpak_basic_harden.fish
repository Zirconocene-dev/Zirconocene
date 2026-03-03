#!/bin/env fish

set supported_micros (/usr/lib64/ld-linux-x86-64.so.2 --help | grep --perl-regexp "^\s*(x86-64-v\d+).*\(supported, searched\)" | sed 's/(supported, searched)//;s/\s//g')

set hmalloc_path "$(find /usr/ -iname $supported_micros[1] 2>/dev/null)/libhardened_malloc.so" # just incase hmalloc gets built for aarch64 and other architectures lol

echo found hmalloc!: $hmalloc_path

set overrides_to_apply "--filesystem=host-os:ro" \
    "--env=LD_PRELOAD=/run/host$hmalloc_path" \
    "--env=ELECTRON_OZONE_PLATFORM_HINT=auto"

flatpak override --user $overrides_to_apply
