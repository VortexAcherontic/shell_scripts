FROM tumbleweed:latest

RUN zypper dup -y
RUN zypper in -y wine winetricks
RUN useradd -m user

USER user
ENV HOME /home/user
WORKDIR /home/user
VOLUME /home/user/Steam

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xz

EXPOSE 27015/udp
EXPOSE 27015/tcp

HEALTHCHECK CMD /usr/bin/echo 0

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
