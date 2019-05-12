# marsOS

marsOS is a tiny busybox-based linux distribution that is mainly used for development and debugging tasks
for the mars block device kernel driver (https://github.com/schoebel/mars).

## prerequirements

the following applications are needed on the building host:

  * wget
  * (gnu-)tar
  * gcc,ld,ar
  * make
  * bash
  * git
  * m4
  * gawk
  * bison
  * perl
  * find
  * strip
  * mknod
  * losetup
  * dd
  * mkfs.ext4
  * grub-install
  
  the build system also needs access to the internet to be able to download
  source code.
  
  ## create a new image
  
  before you build a new marsOS image consult dist.conf in the root of the repo.
  it contains all neccessary configuration for building a marsOS image.
  
  when you are done with configuration finally build the image like so:
  
      ./build.sh
