FROM tumbleweed:latest

RUN zypper dup -y
RUN zypper in -y wine winetricks xorg-x11-server-Xvfb
RUN useradd -m user

USER user
ENV HOME /home/user
WORKDIR /home/user
VOLUME /home/user/Steam

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xz

# Get's killed at the end
RUN ./steamcmd.sh +login anonymous +quit || :
USER root
# RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

EXPOSE 30000/udp
EXPOSE 30001/udp
EXPOSE 30002/udp

HEALTHCHECK --interval=60s --timeout=15s CMD echo 0

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
