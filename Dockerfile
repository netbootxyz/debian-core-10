FROM debian:buster

# versioning
ARG EXTERNAL_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add local files
COPY /root /

RUN \
 echo "**** install deps ****" && \
 apt-get update && \
 apt-get install -y \
	curl \
	initramfs-tools \
	live-boot \
	p7zip-full \
	patch \
	pixz \
	psmisc \
	wget && \
 echo "**** install kernel ****" && \
 if [ -z ${EXTERNAL_VERSION+x} ]; then \
	EXTERNAL_VERSION=$(curl -sX GET https://cloudfront.debian.net/debian/dists/buster/main/binary-amd64/Packages.gz | gunzip -c |grep -A 7 -m 1 "Package: linux-image-4.19.0-6-amd64" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 apt-get install -y \
	linux-image-4.19.0-6-amd64=${EXTERNAL_VERSION} && \
 echo "**** clean up ****" && \
 mkdir /buildout && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

ENTRYPOINT [ "/build.sh" ]
