# Zirconocene, a loosely modified zirconium with my own thing

Mostly doing this to avoid rpm-ostree hell and to also make it push the images to quay :3

Includes some utils i use + useful scripts that i spend time writing and not proompting, unlike another distro, starting with an O

Inclusions include:
- trivalent
- h_malloc (not default)
- fish!
- podman-compose
- usb-wakeup-control
- usbguard
- default fedora printing util that some fedora spins has, (dms's is ass rn)
- nm-connection-editor because dms's connection editor is non existant x3

Build instructions:
```
git submodule init # unfortunately, --recursive still isn't default, just like sha256 repos :sob:
just build # :thumbsup:
```
