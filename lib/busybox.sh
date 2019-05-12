#!/bin/bash

set -e

BUSYBOXTMP=${DISTBUILDDIR}/tmp/busybox-${BUSYBOXVERSION}

rm -rf ${BUSYBOXTMP}

download_and_verify ${BUSYBOXURL}/busybox-${BUSYBOXVERSION}.tar.bz2 ${BUSYBOXTMP}.tar.bz2
( cd ${DISTBUILDDIR}/tmp && tar xjf ${BUSYBOXTMP}.tar.bz2 )
( cd ${BUSYBOXTMP} && make CROSS_COMPILE="${DISTTARGET}-" defconfig && make ${GCCPARALLEL} CROSS_COMPILE="${DISTTARGET}-" && make CROSS_COMPILE="${DISTTARGET}-" CONFIG_PREFIX="${FAKEROOTDIR}" install )

cp -v ${BUSYBOXTMP}/examples/depmod.pl ${FAKEROOTDIR}/cross-tools/bin
chmod 755 ${FAKEROOTDIR}/cross-tools/bin/depmod.pl

cat > ${FAKEROOTDIR}/etc/init.d/rcS << "EOF"
#!/bin/sh

# Start all init scripts in /etc/init.d
# executing them in numerical order.
#
for i in /etc/init.d/S??* ;do

     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     $i start
done
EOF

chown 0:0 ${FAKEROOTDIR}/etc/init.d/rcS
chmod u+x ${FAKEROOTDIR}/etc/init.d/rcS