# Build Wireguard (and possibly others) kernel module for QNAP NAS

This short manual should provide you with the necessary information on how to cross compile the wireguard kernel module for your arm based QNAP NAS. It was tested on a QNAP TS-231P2 with QNAP OS version 4.4.1
**Please be aware that you should regularly check for new wireguard releases to keep the module up to date!**

## Prerequisites

- Check running QNAP OS e.g. from the web interface. Then download the corresponding OS Image file from qnap.com
- Check running Kernel version on QNAP NAS with `uname -r` (possible output: `4.2.8`)
- Check toolchain/compiler the kernel was build with on QNAP NAS: `cat /proc/version` (possible output: `Linux version 4.2.8 (root@U16BuildServer48) (gcc version 4.8.2 20131014 (prerelease) (crosstool-NG linaro-1.13.1-4.8-2013.10 - Linaro GCC 2013.10) ) #2 SMP Fri Feb 14 10:05:10 CST 2020`)

- Download Kernel sources from https://mirrors.edge.kernel.org/pub/linux/kernel/ and extract them
- Get the toolchain. E.g. if the output was something like `crosstool-NG linaro-1.13.1-4.8-2013.10` get the linaro toolchain from https://releases.linaro.org/archive/13.10/components/toolchain/binaries/
- Download the wireguard sources from https://www.wireguard.com/compilation/

## Cross compile the kernel

1. Extract kernel config from QNAP NAS by copying `/proc/config.gz` from NAS (e.g. with scp) and extract it to extracted kernel folder as `.config`
2. The initramfs needs to be extracted from the QNAP OS image file. To do this, first extract the .img file from the previously downloaded .zip file. Then use the PC1 tool to extract the encrypted image. You can copy the .img file to your NAS (e.g. by using scp) and decrypt with `PC1 d QNAPNASVERSION4 IMAGE_FILENAME.img /mnt/HDA_ROOT/IMAGE_FILENAME.tgz - please note that you should extract to the disks because the internal storage size is limited and you would end up with a corrupted file.
You could also extract the encrypted .img file on your host machine by gettin the source code from https://sites.google.com/site/nliaudat/nas/test2/qnap401t-decryptencryptfirmware and compile it yourself.
7. Next extract the initramfs from the extracted QNAP NAS OS image by using the provided script: `extract_uImage.sh EXTRACTED_IMAGE_FOLEDER/uImage`. You should end up with a file named `initramfs_qnap.cpio.gz`. This file needs to be copied to the kernel source files into the `usr` folder. 
6. Just to make sure all needed kernel config entries are set run `make ARCH=arm CROSS_COMPILE=folder/to/toolchain/arm-linux-gnueabihf- oldconfig`. This will check the provided `.config` file for missing entries and ask for your input if there are any missing config entries found. Normally there should be none to some questions asked - normally they can be answered with default values.
7. Compile the kernel by running `make ARCH=arm CROSS_COMPILE=folder/to/toolchain/arm-linux-gnueabihf-`

## Build the wireguard module

1. Edit the `Makefile` in `src`. Just comment the lines `KERNELRELEASE` and `KERNELDIR` out.
2. Run the make file with additional arguments: `make ARCH=arm CROSS_COMPILE=/ABSOLUTE/PATH/TO/CROSS/COMPILER/your-compiler-prefix- KERNELRELEASE=X.Y.Z KERNELDIR=/ABSOLUTE/PATH/TO/KERNEL/DIR -C src/` (e.g. `make ARCH=arm CROSS_COMPILE=/home/user/QNAP/gcc-linaro-arm-linux-gnueabihf-4.8-2013.11_linux/bin/arm-linux-gnueabihf- KERNELRELEASE=4.2.8 KERNELDIR=/home/user/QNAP/linux-4.2.8 -C src/`)
3. Copy the generated `wireguard.ko` in the `src` folder to `/lib/modules/X.Y.Z` (e.g. `/lib/modules/4.2.8`) on your QNAP NAS and load them by running `insmod /lib/modules/X.Y.Z/wireguard.ko`
