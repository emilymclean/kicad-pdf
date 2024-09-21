FROM ubuntu:22.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yqq software-properties-common python3
RUN add-apt-repository --yes ppa:kicad/kicad-8.0-releases
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -yqq --no-install-recommends kicad kicad-footprints kicad-libraries poppler-utils librsvg2-bin

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/

ENTRYPOINT ["/entrypoint.sh"]
