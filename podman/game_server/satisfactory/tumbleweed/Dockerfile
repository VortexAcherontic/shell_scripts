FROM tumbleweed:latest

RUN zypper dup -y
RUN zypper in -y wine winetricks
RUN useradd -m user

USER user
ENV HOME /home/user
WORKDIR /home/user
VOLUME /home/user/Steam

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xz

EXPOSE 7777/udp
EXPOSE 15000/udp
EXPOSE 15777/udp

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
