ARG BUILD_FLAVOR="${BUILD_FLAVOR:-}"
ARG BASE_IMAGE=ghcr.io/zirconium-dev/zirconium:latest

FROM "${BASE_IMAGE}" AS interim

# We seperate copies so we dont poison repo setup when modifying unrelated stuff

COPY build_files/00-Repo-setup.slop /build/00-Repo-setup.slop
RUN /build/00-Repo-setup.slop

COPY build_files/01-Download-progs.slop /build/01-Download-progs.slop
RUN /build/01-Download-progs.slop

FROM scratch
COPY --from=interim /var/cache/libdnf5 /

#Free yuri at yuri.gz
# gunzip it and then use a base64 to image thingy
