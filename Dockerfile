FROM debian:sid

# versioning
ARG EXTERNAL_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add local files
COPY /root /

RUN \
 echo "**** install cacerts ****" && \
 apt-get update && \
 apt-get install -y \
	ca-certificates && \
 echo "**** add tails snapshot repo ****" && \
 echo "deb https://snapshot.debian.org/archive/debian/20191021T030120Z experimental main" >> /etc/apt/sources.list.d/tails.list && \
 echo "**** install deps ****" && \
 apt-get update -o Acquire::Check-Valid-Until=false && \
 apt-get install -o Acquire::Check-Valid-Until=false -y \
	curl \
	initramfs-tools \
	live-boot \
	p7zip-full \
	patch \
	pixz \
	psmisc \
	wget \
	xz-utils && \
 echo "**** patch live-boot ****" && \
 patch /lib/live/boot/9990-mount-http.sh < /patch && \
 echo "**** install kernel ****" && \
 apt-get install -y -o Acquire::Check-Valid-Until=false \
	linux-image-5.3.0-trunk-amd64 && \
 echo "**** clean up ****" && \
 mkdir /buildout && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

ENTRYPOINT [ "/build.sh" ]
