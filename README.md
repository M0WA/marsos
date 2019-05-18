# marsOS

marsOS is a tiny debian-based linux distribution that is mainly used for development and debugging tasks
for the mars block device kernel driver (https://github.com/schoebel/mars).

## prerequirements

the following applications are needed on the building host:

  * wget
  * (gnu-)tar
  * gcc,ld,ar
  * make
  * bash
  * git
  * bc
  * m4
  * gawk
  * bison
  * perl
  * find
  * strip
  * mknod
  * losetup
  * dd
  * mkfs.ext3
  * grub-install
  * kpartx
  * fdisk
  
by default the build system needs access to the internet to download source code.

## configuration
  
before you build a new marsOS image you might want to have a look at conf/dist.conf located in this repo.
it contains all neccessary configuration for building a marsOS image.

## create a new image
    
depending on the configuration, you might be asked to enter a root password during the image building process.

use the following command to build the image:
  
    ./build.sh

if there is an error during the build process you might want to cleanup remaining
loopback devices (losetup + dmsetup).

## run the image

this will run the image with qemu.

    ./run.sh

## test-suite prerequirements

a few more applications have to be installed to run the test-suite:

  * qemu-static-${DISTARCH}
  * bridge-utils

the test script will setup a so-called host-only network for the virtuals machines
involved in the tests. this affects the hosts you are executing the tests on. make
sure that the ip address range configured in conf/test.conf is unused on your machine.

## execute test-suite

the test-suite uses configuration from conf/dist.conf as well as conf/test.conf.
running the following command will start up 2 qemu vms based on the current image.

    ./test.sh

one will be configured as master, the other as slave.