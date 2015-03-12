# Building Yocto for Gumstix

This writeup goes over some basics on how to build and install a Yocto Linux image for an Overo Gumstix board.  The Yocto build described in this document can be directly installed on a Gumstix board or you can utilize the kernel, modules and firmware it creates to construct other Linux distributions (Debian, Kali, Ubuntu, Fedora, etc) for your Gumstix board.

Here is a short summary of what this writeup covers:

1.  How to manually build and compile a Yocto image for a Gumstix Overo.
2.  A quick alternative way to build a Gumstix Yocto image.
3.  Where to download Yocto images if you are not interested in building them yourself.
4.  How to install a Linux image to an SD card for your Gumstix board.
5.  How to access your image after installation


### Overview
The Yocto Project is a framework for building custom Linux distributions for embedded systems.  As I come from a Linux background, I like to think of Yocto as the Gentoo for ARM systems.  These custom Linux distributions are typically stripped down to the bare necessities and configured to run as efficient as possible on the target hardware.  Hardware vendors that create ARM devices capable of supporting Linux typically recommend Yocto builds and provide full Yocto configurations for their hardware.  These Yocto configurations provided by hardware vendors typical include kernel configurations, kernel modules, kernel firmware and base system packages.

Gumstix provides a few different Yocto configurations for building different Linux images.  This documentation focuses on building the Gumstix Yocto console (command line only) image but the process for building their other images (such as the desktop XFCE image) is relatively similar.

 Another extremely helpful use for vendor supplied Yocto builds and configurations is using the kernel, modules and firmware produced by their Yocto builds with other Linux distributions.  If you are reading this article because of my work on the SEWiFi project, this is something I take advantage of in the project.  The Gumstix Yocto uBoot files, kernel, modules and firmware files are used to create a functioning Debian ARM distribution for the Gumstix Overo.  The follow up to this documentation will show how to use these Yocto files to run a Debian OS on the Gumstix Overo board.  Alternatively, these files can also be use to create other operating systems other than Debian. 

 There are two methods to obtain a Yocto build for the Gumstix Overo.  The first method is to download a pre compiled build directly from Gumstix.  The second method is to build it yourself.  The majority of this documentation focuses on manually building the Gumstix Overo Yocto build manually which has added benefits such as customization or adding additional binary packages to your base image.  I have also composed a bash file which scripts the manual build process which is referenced and explained at the end of this documentation.

 Finally, if you are interested in installing the Yocto Linux build on your Gumstix Overo board, I will briefly cover this process as well.  Installation of the Yocto image is not necessary if you are looking to use the Yocto kernel, modules and firmware to build a Debian (or other OS) image for your Gumstix board.  However, the Yocto image installation is almost identical to installing a Debian OS (which I will cover in future documentation), so you make find it useful to review. 

# Manually Building a Gumstix Overo Yocto Image
* If you decided to not to Download the pre-built Yocto images and want to build it yourself from scratch, this section describes the process in detail.  Manually building the Yocto system has many benefits such as base image customizations and the ability to add your own packages.  I am not going to cover customization or package addition via bitbake (bitbake is very similar to Gentoo's ebuild package management system) here.  However, if you are interested in adding your own packages to the base system via bitbake, I will cover that process in a future post.  The process takes some time to complete but consecutive builds can be done much faster. Most of this is derived from the docs found [here](https://github.com/gumstix/Gumstix-YoctoProject-Repo)
* Also note, that if you want to build the Yocto system but don't want to manually type in all of the following commands, I provide a bash script which automatically runs all of these commands which is covered in the following section.

* Finally, this manual build process was tested on a minimal install Debian 7.7 system.  I also successfully tested the build on Kali Linux 1.0.9 but it will likely also build on past revisions. 

### Download the required packages for building 
* These packages are needed to build our base Yocto image
``` bash
sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath libsdl1.2-dev xterm curl
```

### Create a build directory and go there
* I like to create a directory structure to house my source code and projects.  You do not have to abide by my directory structure, but keep in mind that I will reference these directories throughout this and future documentation.
``` bash
mkdir -p ~/source/gumstix/yocto
cd ~/source/gumstix/yocto
```

### Download the repo command and add it to your system
* In order to download the Yocto configurations for the project, we must first install the repo command.  In short, repo is basically a wrapper around git which provides a simple way to bundle a bunch of different git repositories into one project.
* If you are interested in learning more about the repo command, this [link is a good start](http://xda-university.com/as-a-developer/repo-tips-tricks)
``` bash
curl -O http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo mv repo /usr/local/bin
```

### Initialize your yocto repo project
* Now that repo is installed, we are going to download all of the Yocto configs for our project.  The init command will take some time as it downloads all of the git repositories associated with the project.  The sync command is used to make sure all of your repos are up to date and is useful for updating your Yocto configs if you do a build at a later date.
``` bash
repo init -u git://github.com/gumstix/Gumstix-YoctoProject-Repo.git
repo sync
```

### Change into your yocto build environment
* Now that we have our base Yocto configs, we are going to enter our build environment.  If for some reason, you exit your bash shell before finishing your Yocto build, you will need to execute this command each time before being able to run all of the consecutive steps.  Keep in mind that this also applies to doing builds at a future date.
``` bash
export TEMPLATECONF=meta-gumstix-extras/conf
source ./poky/oe-init-build-env
```

### Build with bitbake
* Yocto projects utilize bitbake in order to compile your Yocto Linux image.  Bitbake basically just compiles your base OS, kernel, modules and all of the packages included in your target Linux OS.  A Yocto project contains a bunch of recipes (files with the extension bb) which define how each package gets downloaded and compiled.  Bitbake recipes are extremely similar to Gentoo ebuild files.  If you are interested in adding extra or custom applications to your base Yocto Linux OS you can add and link bitbake recipes to the Gumstix console image.  I will not cover adding and customizing bitbake here but it is something I plan to cover in future documentation.

* (Optional) If you are familiar with compiling via make, you can speed up the following compile process by telling bitbake to compile with more threads.  This step is not needed but if you are compiling on a system with a high end CPU with many cores, this will speed up your compile time.  Keep in mind that the rule of thumb here is you should not specify a -j value greater than the amount of CPU cores present on your build machine.
``` bash
export PARALLEL_MAKE="-j 8"
```

* (Optional) Before we kick off the build, I typically find it useful to download all of the build sources first incase I lose network connectivity.  As a Yocto build can take a few hours, I find this extremely useful if I am going to be doing a build on my laptop.
``` bash
bitbake -c fetchall gumstix-console-image
```

* Now to build build the Yocto image.  Depending on the speed of your computer and how many threads you specified to build with, this step can take a few hours to complete.  When the build completes, you can use the image it creates in ~/source/gumstix/yocto/build/tmp/deploy/images/overo/ to either install the Yocto system or use the kernel, modules, firmware contained in the gumstix-console-image-overo-XXXXXXXXXXXXX.rootfs.tar.bz2 file to build a Debian (or other OS) Gumstix image.
``` bash
bitbake gumstix-console-image
```

# Gumstix Overo Yocto Scripted Build
* In order to speed up the Yocto Gumstix build process, I have composed a bash script from all of the manual build steps described above.  The script can be found [here](https://github.com/hackgnar/gumstix-overo-images/blob/master/yocto/build_gumstix_yocto.sh).  This script was tested on a base Debian 7.7 and Kali Linux 1.0.9 system.  The script should be run as a non root user but it will prompt you periodically for a root password when it needs to run privileged commands.  Because of this you should make sure that your root user has a password set.  The automated script provides very useful for building Yocto images on a clean system or of if you want to spin up a temporary EC2 instance for building.

### Download the Build Script
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/yocto_scripted_build.sh
````

### Run the Build Script
* The script should not be run as root.  Note however that you will be asked for the root password multiple times during the build process since the script utilizes the su command.
```` bash
bash yocto_scripted_build.sh
````

# Precompiled Image Build
If you are not interested in building Yocto from scratch, you can always download and install precompiled images.  The image provided below was generated by myself from the steps listed above.

### Download the base image uboot files
```` bash
mkdir myimage
cd myimage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/u-boot.img
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/gumstix-console-image-overo-20141218160757.rootfs.tar.bz2
````

# Install image to SD Card
Once you have built or downloaded your image, you can use the steps listed in this section to flash the image to an SD card.  You can then use the SD card to boot your Gumstix board.

* requires a linux machine

### Insert your SD Card
* note the device block it gets mapped to.  In most instances it will /dev/sdb

### Format your SD card
* in the command below, replace sdX with the device your SD card was mapped to which you noted in the previous step
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/mk2partsd
./mk2partsd /dev/sdX
````

### Copy uboot files to the SD card
* On a Debian system your SD card partitions should automatically get mounted to /media/boot and /media/root.  If this is not the case then make sure your SD cards are mounted and substitute the mount directory referenced in the instructions below.
```` bash
cp MLO /media/boot
cp uImage /media/boot
cp u-boot.img /media/boot
tar xaf yocto.tar.bz2 -C /media/rootfs
sync
umount /media/boot
umount /media/rootfs
````

# How to Access your image running on a Gumstix 
**NOTE:** there is no simple way to access a stock Yocto image via a networked USB interface.  In the future, Ill create some documentation on how to add USB network access to a stock Yocto Gumstix build prior to installation.  I will also update the stock image provided in this repository to have network access via USB by default.

### Recommended Method for Accessing Precompiled Images
* Access your Gumstix device via the USB console using a daughterboard such as the Tobi or Janus with minicom

### Credentials and IP Addresses for the Yocto Image
* The stock Yocto image has no password for the root user so you can simply log in via the USB console
* You may also SSH in if you are using a daughterboard with an ethernet adapter.

### Accessing the Installed Yocto Image
Here are the methods that you can use to access the image running on your Gumstix Board

* SSH to the ethernet interface if you are using a daughter board with ethernet capabilities (Tobi, etc).  The eth0 interface will pull a DHCP address.
* You may also alter the /etc/network/interfaces file before flashing your SD card.  If you are doing this, you can set network interface usb0 to a static IP address so you can ssh to it.  Note however, your base system will not pull a DHCP address unless you set up a DHCP service on the base OS.  Here is an example of how you could access your system via USB if you include usb0 with a static ip in your network interfaces file.

```` bash
# assume you set usb0 to static IP 172.16.1.2
# after your Gumstix which is connected via usb boots up, run this on your host computer
ifconfig eth0 172.16.1.3
ssh root@172.16.1.2
````
