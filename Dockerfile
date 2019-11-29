FROM debian:buster

# versioning
ARG EXTERNAL_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add local files
COPY /root /

RUN \
 echo "**** install build-deps ****" && \
 apt-get update && \
 apt-get install -y \
	ca-certificates \
	curl \
	git \
	gnupg \
	kmod \
	p7zip-full \
	patch \
	pixz \
	psmisc \
	wget \
	xz-utils && \
 echo "**** add snapshot/sid repo ****" && \
 echo "deb https://snapshot.debian.org/archive/debian/20191021T030120Z experimental main" >> /etc/apt/sources.list.d/snapshot.list && \
 echo "deb http://deb.debian.org/debian sid main contrib" >> /etc/apt/sources.list.d/sid.list && \
 echo "**** Build aufs module ****" && \
 apt-get update -o Acquire::Check-Valid-Until=false && \
 apt-get install -o Acquire::Check-Valid-Until=false -y \
        linux-headers-5.3.0-trunk-amd64 \
        linux-source-5.3 && \
 git clone https://github.com/sfjro/aufs5-standalone.git /usr/src/aufs-standalone && \
 cd /usr/src/aufs-standalone && \
 git checkout aufs5.3 && \
 /aufs.sh && \
 echo "**** add tails repo ****" && \
 echo "deb https://deb.tails.boum.org 4.0 main contrib" >> /etc/apt/sources.list.d/tails.list && \
 apt-key add /tails.gpg && \
 echo "**** install tails stuff ****" && \
 mv /etc/apt/new-preferences /etc/apt/preferences && \
 apt-get update -o Acquire::Check-Valid-Until=false && \
 apt-get install -o Acquire::Check-Valid-Until=false -y \
	apparmor \
	initramfs-tools \
	live-boot \
	plymouth && \
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
