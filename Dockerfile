ARG KICAD_VERSION="9.0"

FROM debian:bookworm AS build

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yqq --no-install-recommends poppler-utils librsvg2-bin

FROM kicad/kicad:${KICAD_VERSION} AS runtime

COPY --from=build /usr/bin/rsvg-convert /usr/bin
COPY --from=build /usr/bin/pdfunite /usr/bin
COPY --from=build /lib /lib
COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/

ENTRYPOINT ["HOME=\"/home/kicad\"", "/entrypoint.sh"]
