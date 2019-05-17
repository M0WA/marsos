#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

set_image_hostname ${DISTFAKEROOT} ${DISTHOSTNAME}

cat > ${DISTFAKEROOT}/etc/fstab << "EOF"
# file system    mount point   type    options                  dump  pass
rootfs           /             auto    defaults                 1     1
proc             /proc         proc    defaults                 0     0
sysfs            /sys          sysfs   defaults                 0     0
EOF

cat > ${DISTFAKEROOT}/etc/apt/sources.list << EOF
deb-src ${DEBIANMIRROR}/ ${DEBIANRELEASE} main

deb http://security.debian.org/ ${DEBIANRELEASE}/updates main contrib non-free
deb-src http://security.debian.org/ ${DEBIANRELEASE}/updates main contrib non-free

# stretch-updates, previously known as 'volatile'
deb ${DEBIANMIRROR}/ stretch-updates main
deb-src ${DEBIANMIRROR}/ stretch-updates main contrib non-free
EOF

if [ "${DISTSETROOTPASSWORD}" == "1" ]; then
  passwd -R ${DISTFAKEROOT} root
fi


