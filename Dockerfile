FROM kicad/kicad:${KICAD_VERSION}

ARG USER_NAME
USER root

RUN mkdir -p /github/workspace && chown -R ${USER_NAME}:${USER_NAME} /github
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yqq --no-install-recommends poppler-utils librsvg2-bin

USER ${USER_NAME}

COPY entrypoint.sh /entrypoint.sh
COPY wrapper.sh /wrapper.sh
COPY scripts/ /scripts/

ENTRYPOINT ["/wrapper.sh"]
