ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"
ARG BASE_IMAGE="${BASE_IMAGE:-}"

FROM scratch AS ctx

COPY build_files /build
COPY system_files /files
COPY cosign.pub /files/usr/share/pki/containers/zirconocene.pub

FROM "${BASE_IMAGE}"
ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    dnf -y install fish dnf5-plugins

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    /ctx/build/00-repo.fish

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=cache,dst=/var/cache/libdnf5 \
    /ctx/build/01-i-love-slop.fish

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/run \
    --mount=type=tmpfs,dst=/boot \
    --network=none \
    /ctx/build/99-problems-but-a-hook-aint-one.bash

RUN rm -rf /var/* && mkdir /var/tmp && bootc container lint

#Free yuri at yuri.gz
# gunzip it and then use a base64 to image thingy
