ARG KICAD_VERSION="9.0"

FROM kicad/kicad:${KICAD_VERSION}

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yqq --no-install-recommends poppler-utils librsvg2-bin

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/

ENTRYPOINT ["/entrypoint.sh"]
