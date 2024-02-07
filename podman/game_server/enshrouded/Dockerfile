FROM tumbleweed:latest

RUN zypper dup -y
RUN zypper in -y wine winetricks
RUN useradd -m user

USER user
ENV HOME /home/user
WORKDIR /home/user
VOLUME /home/user/Steam

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xz

# Get's killed at the end
# RUN ./steamcmd.sh +login anonymous +quit || :
# USER root

EXPOSE 15636/udp
EXPOSE 15636/tcp
EXPOSE 15637/udp
EXPOSE 15637/tcp

HEALTHCHECK CMD /usr/bin/echo 0

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
