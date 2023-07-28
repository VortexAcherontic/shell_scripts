FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    bzip2 \
    wget \
    libc6 \
    libgcc-s1 \
    zlib1g \
    && apt-get clean

#https://kumisystems.dl.sourceforge.net/project/sauerbraten/sauerbraten/2020_11_29/sauerbraten_2020_12_29_linux.tar.bz2

RUN wget -qO /sb.tar.bz2 "https://downloads.sourceforge.net/project/sauerbraten/sauerbraten/2020_11_29/sauerbraten_2020_12_29_linux.tar.bz2?ts=1467054652&use_mirror=netcologne" \
    && cd / \
    && tar xvjf /sb.tar.bz2 --exclude="packages" \
    && rm /sb.tar.bz2 \
    && rm -rf /sauerbraten/packages \
    && chown -R root:root /sauerbraten

COPY docker-entrypoint.sh /sauerbraten/docker-entrypoint.sh

RUN cp /sauerbraten/server-init.cfg /sauerbraten/server-init.cfg.orig

EXPOSE 28785/udp 28785/tcp

ENTRYPOINT [ "/sauerbraten/docker-entrypoint.sh" ]
