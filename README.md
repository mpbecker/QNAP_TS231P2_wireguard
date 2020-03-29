# Cross compile Wireguard (and possibly others) kernel module for QNAP NAS

This short manual should provide you with the necessary information on how to cross compile the wireguard kernel module for your arm based QNAP NAS. It was tested on a QNAP TS-231P2 with QNAP OS version 4.4.1


**Please be aware that you should regularly check for new wireguard releases to keep the module up to date!**

## Prerequisites

- Check running QNAP OS e.g. from the web interface. Then download the corresponding OS Image file for your model from qnap.com
- Check running Kernel version on QNAP NAS with `uname -r` (possible output: `4.2.8`)
- Download Kernel sources from https://mirrors.edge.kernel.org/pub/linux/kernel/ and extract them
- Check toolchain/compiler the kernel was build with on your QNAP NAS: `cat /proc/version` (possible output: `Linux version 4.2.8 (root@U16BuildServer48) (gcc version 4.8.2 20131014 (prerelease) (crosstool-NG linaro-1.13.1-4.8-2013.10 - Linaro GCC 2013.10) ) #2 SMP Fri Feb 14 10:05:10 CST 2020`)
- Get the toolchain. E.g. if the output was something like `crosstool-NG linaro-1.13.1-4.8-2013.10` get the linaro toolchain from https://releases.linaro.org/archive/13.10/components/toolchain/binaries/
- Download the wireguard sources from https://www.wireguard.com/compilation/

## Cross compile the kernel

1. Extract kernel config from QNAP NAS by copying `/proc/config.gz` from NAS (e.g. with `scp`) and extract it to the extracted kernel folder as `.config`
2. To build the kernel the initramfs needs to be extracted from the QNAP OS image file. First extract the .img file from the previously downloaded .zip file. Then use the `PC1` tool to decrypt the encrypted image. For this purpose you can copy the .img file to your NAS (e.g. by using `scp`) and decrypt it by running\
`PC1 d QNAPNASVERSION4 IMAGE_FILENAME.img /mnt/HDA_ROOT/IMAGE_FILENAME.tgz`\
Please note that you should extract to the disk because the internal storage size is limited and otherwise you could end up with a corrupted file.\
You could also decrypt the encrypted .img file on your host machine by getting the source code for the `PC1` tool from https://sites.google.com/site/nliaudat/nas/test2/qnap401t-decryptencryptfirmware and compile it yourself.
3. Next extract the initramfs from the extracted QNAP NAS OS image by using the provided script:\
`extract_uImage.sh EXTRACTED_IMAGE_FOLDER/uImage`\
You should end up with a file named `initramfs_qnap.cpio.gz`. This file needs to be copied to the kernel source files into the `usr` folder.
4. Just to make sure all needed kernel config entries are set run\
`make ARCH=arm CROSS_COMPILE=folder/to/toolchain/your-compiler-prefix- oldconfig`\
(e.g. `make ARCH=arm CROSS_COMPILE=folder/to/toolchain/arm-linux-gnueabihf- oldconfig`)\
This will check the provided `.config` file for missing entries and ask for your input if there are any missing config entries found. Normally there should be none to some questions asked - normally they can be answered with default values.
5. Compile the kernel by running\
`make ARCH=arm CROSS_COMPILE=folder/to/toolchain/your-compiler-prefix-`

## Build the wireguard module

1. Edit the `Makefile` in `src`. Just comment the lines `KERNELRELEASE` and `KERNELDIR` out.
2. Run the make file with additional arguments:\
`make ARCH=arm CROSS_COMPILE=/ABSOLUTE/PATH/TO/CROSS/COMPILER/your-compiler-prefix- KERNELRELEASE=X.Y.Z KERNELDIR=/ABSOLUTE/PATH/TO/KERNEL/DIR -C src/`\
(e.g. `make ARCH=arm CROSS_COMPILE=/home/user/QNAP/gcc-linaro-arm-linux-gnueabihf-4.8-2013.11_linux/bin/arm-linux-gnueabihf- KERNELRELEASE=4.2.8 KERNELDIR=/home/user/QNAP/linux-4.2.8 -C src/`)
3. Copy the generated `wireguard.ko` in the `src` folder to `/lib/modules/X.Y.Z` (e.g. `/lib/modules/4.2.8`) on your QNAP NAS and load them by running `insmod /lib/modules/X.Y.Z/wireguard.ko`
