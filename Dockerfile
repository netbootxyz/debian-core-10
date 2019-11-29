FROM debian:buster

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
	ca-certificates \
	curl \
	gnupg && \
 echo "**** add tails/snapshot repo ****" && \
 echo "deb https://snapshot.debian.org/archive/debian/20191021T030120Z experimental main" >> /etc/apt/sources.list.d/tails.list && \
 echo "deb http://deb.debian.org/debian sid main contrib" >> /etc/apt/sources.list.d/sid.list && \
 echo "deb https://deb.tails.boum.org 4.0 main contrib" >> /etc/apt/sources.list.d/tails.list && \
 apt-key add tails.gpg && \
 echo "**** install deps ****" && \
 apt-get update -o Acquire::Check-Valid-Until=false && \
 apt-get install -o Acquire::Check-Valid-Until=false -y \
	apparmor \
	aufs-dkms \
	curl \
	initramfs-tools \
	live-boot \
	p7zip-full \
	patch \
	pixz \
	plymouth \
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
