#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

cat > ${DISTFAKEROOT}/etc/fstab << "EOF"
# file system    mount point   type    options                  dump  pass
rootfs           /             auto    defaults                 1     1
proc             /proc         proc    defaults                 0     0
sysfs            /sys          sysfs   defaults                 0     0
EOF

echo ${DISTHOSTNAME} > ${DISTFAKEROOT}/etc/hostname

cat > ${DISTFAKEROOT}/etc/hosts << EOF
127.0.0.1 localhost
127.0.1.1 ${DISTHOSTNAME}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

cat > ${DISTFAKEROOT}/etc/apt/sources.list << EOF
deb-src ${DEBIANMIRROR} ${DEBIANRELEASE} main

deb http://security.debian.org/ ${DEBIANRELEASE}/updates main
deb-src http://security.debian.org/ ${DEBIANRELEASE}/updates main
EOF

passwd -R ${DISTFAKEROOT} root


