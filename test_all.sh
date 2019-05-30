#!/bin/bash

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/conf/test_all.conf
source ${SCRIPTPATH}/lib/funcs.sh

if [ "${TESTALLVERBOSE}" == "1" ]; then
  set -x
fi

TESTALLTMPLDIR=${SCRIPTPATH}/tmpl

mkdir -p ${TESTALLOUTDIR} ${TESTALLTMPLDIR}

echo "checkout mars"
if [ ! -d "${MARSTMP}" ]; then
  git clone ${MARSURL} ${MARSTMP}
  ( cd ${MARSTMP} && git checkout ${MARSBRANCH} )
fi

echo "generating configs for all available kernel versions"
generate_configs ${MARSTMP} ${TESTALLTMPLDIR} ${TESTALLOUTDIR}

echo "building images"
for FILE in ${TESTALLOUTDIR}/dist.*.conf; 
do
  TESTFILE=`echo ${FILE} | sed -e 's/dist/test/g'`
  /bin/bash -l ${SCRIPTPATH}/./build.sh -c ${FILE}
  /bin/bash -l ${SCRIPTPATH}/./test.sh -c ${FILE} -t ${TESTFILE}
done