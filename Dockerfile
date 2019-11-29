FROM debian:sid

# versioning
ARG EXTERNAL_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add local files
COPY /root /

RUN \
 echo "**** install gnupg ****" && \
 apt-get update && \
 apt-get install -y \
	gnupg && \
 echo "**** add kali repo ****" && \
 echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list.d/kali.list && \
 apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6 && \
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
 echo "**** patch live-boot ****" && \
 patch /lib/live/boot/9990-mount-http.sh < /patch && \
 echo "**** install kernel ****" && \
 if [ -z ${EXTERNAL_VERSION+x} ]; then \
	EXTERNAL_VERSION=$(curl -sLX GET http://http.kali.org/kali/dists/kali-rolling/main/binary-amd64/Packages.gz | gunzip -c |grep -A 7 -m 1 "Package: linux-image-5.3.0-kali2-amd64" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 apt-get install -y \
	linux-image-5.3.0-kali2-amd64=${EXTERNAL_VERSION} && \
 echo "**** clean up ****" && \
 mkdir /buildout && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

ENTRYPOINT [ "/build.sh" ]
