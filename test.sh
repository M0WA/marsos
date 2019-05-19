#!/bin/bash

set -e

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"

source ${SCRIPTPATH}/conf/dist.conf
source ${SCRIPTPATH}/conf/test.conf
source ${SCRIPTPATH}/lib/funcs.sh
source ${SCRIPTPATH}/test/funcs.sh

if [ "${TESTVERBOSE}" == "1" ]; then
  set -x
fi

mkdir -p ${TESTBUILDDIR}

# truncate log
echo -n > ${TESTLOG}

echo "configure qemu bridge permissions"
exec_script ${SCRIPTPATH} test/qemu_conf.sh ${TESTLOG}

echo "config vm images"
exec_script ${SCRIPTPATH} test/mars_config.sh ${TESTLOG}

echo "create bridge"
exec_script ${SCRIPTPATH} test/bridge_ifup.sh ${TESTLOG}

echo "start test vms"
exec_script ${SCRIPTPATH} test/run_vms.sh ${TESTLOG}

echo "do runtime configuration of vms"
exec_script ${SCRIPTPATH} test/vm_runtime_config.sh ${TESTLOG}

echo "the following vms have been started:"
exec_script ${SCRIPTPATH} test/print_vm_info.sh ${TESTLOG}
echo "press enter to continue"
read

echo "run test-suite"
exec_script ${SCRIPTPATH} test/run_testsuite.sh ${TESTLOG}

echo "test finished, press enter to continue"
read

echo "shutdown vms"
#TODO: we could do better here
killall qemu-system-${DISTARCH} | tee -a ${TESTLOG}
sleep 3

echo "destroy bridge"
exec_script ${SCRIPTPATH} test/bridge_ifdown.sh ${TESTLOG}