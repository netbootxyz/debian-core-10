#! /bin/sh

set -e
set -u

echo "Building the aufs module"

# aufs build needs fs/mount.h, which is in linux-source-* but not
# in linux-headers-*, so we'll symlink it.
tar --directory=/usr/src \
    -xf "/usr/src/linux-source-5.3"*.tar.*

arch=amd64
ln -s \
   "/usr/src/linux-source-5.3"*/fs \
   "/usr/src/linux-headers-5.3.0-trunk-amd64/fs"
(
   cd /usr/src/aufs-standalone
   perl -pi -E \
        's{\A CONFIG_AUFS_DEBUG \s* = \s* y $}{CONFIG_AUFS_DEBUG =}xms' \
        config.mk
   KDIR="/usr/src/linux-headers-5.3.0-trunk-amd64"
   make clean   KDIR="$KDIR"
   make install KDIR="$KDIR"
)

for modules_dir in /lib/modules/*/extra ; do
   if [ ! -f "${modules_dir}/aufs.ko" ]; then
       echo "Can not find aufs.ko module in '${modules_dir}" >&2
       exit 1
   fi
done

strip --strip-debug /lib/modules/*/extra/aufs.ko

depmod "5.3.0-trunk-amd64"
