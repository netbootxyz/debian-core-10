#!/bin/bash
set -e
VERSION=$(curl -sfL https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current-live/amd64/iso-hybrid/MD5SUMS | grep 'standard+nonfree.iso' | grep -Po "(\d+\.)+\d+")
echo "${VERSION}"
