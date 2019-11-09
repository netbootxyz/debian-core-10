#! /bin/bash

# Copy initrd and kernel
mv /boot/initrd.img-* /buildout/initrd
mv /boot/vmlinuz-* /buildout/vmlinuz
chmod 777 /buildout/*

exit 0
