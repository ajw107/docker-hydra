FROM lsiobase/ubuntu:bionic
#FROM openjdk:jre-slim
MAINTAINER sparklyballs, ajw107 (Alex Wood)

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HYDRA_VER
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# set python to use utf-8 rather than ascii
ENV PYTHONIOENCODING="UTF-8"
#add extra environment settings
ENV CONFIG="/config"
ENV APPDIRNAME="hydra"
ENV APP_ROOT="/app"
#ENV APP_OPTS="--nobrowser --config=${CONFIG}/settings.cfg --database=${CONFIG}/nzbhydra.db --logfile=${CONFIG}/nzbhydra.log"
ENV APP_OPTS="--nobrowser --datafolder ${CONFIG} --baseurl /nzbhydra"
#ENV APP_EXEC="nzbhydra2"
ENV APP_EXEC="nzbhydra2wrapper.py"
ENV APP_COMP="python"
#ENV GITURL="https://github.com/theotherp/nzbhydra2.git"
#ENV GITBRANCH="master"

#make life easy for yourself
RUN apt update && \
    apt install -y nano git curl unzip &&\
    apt install --no-install-recommends -y openjdk-11-jre-headless python
ENV TERM=xterm-color
#RUN echo $'#!/bin/bash\nls -alF --color=auto --group-directories-first --time-style=+"%H:%M %d/%m/%Y" --block-size="\'1" $@' > /usr/bin/ll

COPY get_version /get_version
VOLUME /VERSION
RUN \
  echo "**** install hydra2 ****" && \
  if [ -z ${HYDRA_VER+x} ]; \
  then \
#      HYDRA_VER=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" \
#          | awk '/tag_name/{print $4;exit}' FS='[""]'); \
#      HYDRA_VER=${HYDRA_VER#v}; \
       sh /get_version; \
       HYDRA_VER=$(cat /VERSION/HYDRA_VER); \
  fi && \
  echo "Hydra Ver: [${HYDRA_VER}]" && \
  curl -o \
  /tmp/hydra2.zip -L \
"https://github.com/theotherp/nzbhydra2/releases/download/v${HYDRA_VER}/nzbhydra2-${HYDRA_VER}-linux.zip" && \
  mkdir -p "${APP_ROOT}/${APPDIRNAME}" && \
  unzip /tmp/hydra2.zip -d "${APP_ROOT}/${APPDIRNAME}" && \
#  curl -o \
#    "${APP_ROOT}/${APPDIRNAME}/nzbhydra2wrapper.py" -L \
#	"https://raw.githubusercontent.com/theotherp/nzbhydra2/master/other/wrapper/nzbhydra2wrapper.py" && \
#  chmod +x "${APP_ROOT}/${APPDIRNAME}/nzbhydra2wrapper.py" && \
  echo "**** cleanup ****" && \
  rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
        /var/tmp/*

# copy local files
COPY root/ /
RUN chmod +x /usr/bin/ll

# ports and volumes
EXPOSE 5075
# WORKDIR /config/hydra
#VOLUME /config /downloads
VOLUME "${CONFIG}" /mnt
