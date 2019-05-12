#!/bin/bash

set -e

if [ "${DISTBUILDVERBOSE}" == "1" ]; then
  set -x
fi

if [ "${FORCEREBUILD}" == "1"  ]; then
  rm -rf ${BUSYBOXTMP}
fi

download_and_verify ${BUSYBOXURL}/busybox-${BUSYBOXVERSION}.tar.bz2 ${BUSYBOXTMP}.tar.bz2

if [ ! -d "${BUSYBOXTMP}" ]; then
  ( cd ${DISTBUILDDIR}/tmp && tar xjf ${BUSYBOXTMP}.tar.bz2 )
fi

( cd ${BUSYBOXTMP} && make CROSS_COMPILE="${DISTTARGET}-" defconfig && make ${GCCPARALLEL} CROSS_COMPILE="${DISTTARGET}-" && make CROSS_COMPILE="${DISTTARGET}-" CONFIG_PREFIX="${FAKEROOTDIR}" install )

cp -v ${BUSYBOXTMP}/examples/depmod.pl ${FAKEROOTDIR}/cross-tools/bin
chmod 755 ${FAKEROOTDIR}/cross-tools/bin/depmod.pl

mkdir -p ${FAKEROOTDIR}/etc/rc.d
cat > ${FAKEROOTDIR}/etc/rc.d/startup << "EOF"
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

chown 0:0 ${FAKEROOTDIR}/etc/rc.d/startup
chmod u+x ${FAKEROOTDIR}/etc/rc.d/startup