ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"
ARG BASE_IMAGE="${BASE_IMAGE:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY cosign.pub /files/usr/share/pki/containers/zirconocene.pub

FROM "${BASE_IMAGE}"
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

# programs i like :3
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    /ctx/build/00-i-love-slop.sh

# Guix step
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    /ctx/build/01-guix.slop


# post everything script
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --network=none \
    /ctx/build/99-problems-but-a-hook-aint-one.sh

# copy my files there
RUN setfattr -n user.component -v "zirconocene_files" \
    /usr/bin/usb-wakeup-control \
    /etc/systemd/system/usb-wakeup-control.service \
    /etc/containers/policy.json \
    /usr/bin/zfish /usr/share/zirconocene/
    
RUN setfattr -n user.component -v "Guix_files" \
    /usr/bin/guix-init.sh \
    /usr/lib/environment.d/99-guix.conf \
    /usr/lib/pki/environment.d/99-guix.conf \
    /usr/lib/sysusers.d/99-guix.conf \
    /usr/lib/guix-gpg/*.pub \
    /usr/lib/systemd/system/gnu.mount \
    /usr/lib/systemd/system/guix-daemon.service \
    /usr/lib/systemd/system/guix-first-boot.service
    
    
RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint

#Free yuri at yuri.gz
# gunzip it and then use a base64 to image thingy
