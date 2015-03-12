# Building Debian Wheezy for Gumstix Overo

This writeup goes over details on how to build and install a Debian Wheezy Linux image for an Overo Gumstix board. The build notes and images in this post are for a stock Debian Wheezy OS configured for a Gumstix Overo device. The Debian image is configured for easy SSH network access over wired, wireless or USB when the Gumstix device is powered.

This Debian build utilizes the kernel, modules and firmware from the Gumstix Overo Yocto build.  You do not have to build your own Yocto image as this documentation utilizes a precompiled version, but if you are interested in building your own, you can check our my previous post ["Building Yocto Linux Images for the Gumstix Overo"](http://www.hackgnar.com/2015/03/building-yocto-linux-images-for-gumstix.html)

Here is a short summary of what this writeup covers:

1.  How to manually build a Debian Wheezy image for a Gumstix Overo.
2.  An alternative scripted method to build a Gumstix Debian image.
3.  Where to download precompiled Debian Wheezy Gumstix Overo image if you are not interested in building them yourself.
4.  How to install a Debian Wheezy image to an SD card for your Gumstix board.
5.  How to access your image after installation

-------------

# Manually Building a Gumstix Overo Debian Image
* These steps build a base Debian Wheezy OS for the Gumstix Overo board and uses files, kernel modules, firmware obtained from a Gumstix Overo Yocto build. You do not have to build your own Yocto image as this documentation utilizes a precompiled version, but if you are interested in building your own, you can check our my previous post ["Building Yocto Linux Images for the Gumstix Overo"](http://www.hackgnar.com/2015/03/building-yocto-linux-images-for-gumstix.html)

* These steps were tested on Debian 7.7, Ubuntu 14.04 and Kali Linux 1.0.9 system. 

* **NOTE: This documentation utilizes the deboostrap command so you will likely have to build this on a Debian or Ubuntu based system**.  There are some tricks to get around this, but they are not covered here.

### Create Your Build Directory
* First we will create a build directory.  It is not required that you follow the same directory build structure.  However, if you do use a different directory structure, you will have to substitute your directories in my build commands.
``` bash
mkdir -p gumstix/debian
cd gumstix/debian
```

### Install Build Dependancies
* We must first install these following applications in order to build our base OS
``` bash
sudo apt-get install -y debootstrap binfmt-support qemu qemu-user-static curl
```

### Create the Base ARM Debian OS (First Stage)
* In this step,  we create our base Debian OS with deboostrap.  This is often called "First Stage" build.
```
sudo debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano wheezy ./wheezy http://ftp.debian.org/debian/
```

### Download a Yocto Image to Utilize its Kernel Modules and Firmware
* This step utilizes a precompiled Yocto image I created.  Optionally, you can obtain one directly from Gumstix [here](https://www.gumstix.com/software/software-downloads/) or build your own using the steps I provide [here](http://www.hackgnar.com/2015/03/building-yocto-linux-images-for-gumstix.html).
```` bash
curl -O curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/gumstix-console-image-overo-20141218160757.rootfs.tar.bz2
mkdir yocto
tar xaf gumstix-console-image-overo-20141218160757.rootfs.tar.bz2 -C ./yocto
````

### Copy Over Your Yocto Kernel Modules, Firmware and Core System Files
* In this step, we copy over our Yocto kernel modules and system files we downloaded or built from the previous step.
``` bash
sudo mkdir -p wheezy/lib/modules
sudo mkdir -p wheezy/lib/firmware
sudo cp -r yocto/lib/modules/3.5.7-custom wheezy/lib/modules
sudo cp -r yocto/lib/firmware/* wheezy/lib/firmware
sudo cp yocto/etc/fstab  wheezy/etc/fstab
sudo cp yocto/etc/network/interfaces  wheezy/etc/network/
```

### Configure the Base ARM Debian OS (Second Stage)
* This is typically called "Second Stage" build.
* Here we configure all of the packages we installed from the First Stage
``` bash
sudo cp /usr/bin/qemu-arm-static wheezy/usr/bin
sudo chroot wheezy ./debootstrap/debootstrap --second-stage
```

### More Configuration for the Debian ARM OS (Third Stage)
* During this configuration stage, we set up more personal configurations such as passwords, hostnames, network addresses, etc
* this section is broken up into smaller subsections.
* During this stage, you may choose to customize network interfaces, passwords, etc.

#### Set the System Password
* Feel free to set your own password here, but remember it so you can ssh into your system after installation.
``` bash
sudo chroot wheezy /bin/bash -c 'echo "root:hackgnar" | chpasswd'
```

#### Set Up Our Remote Apt Repository
* Feel free to use a different core apt repository if you like.
* If you want backports, you can also add this line **deb http://http.debian.net/debian wheezy-backports main**
``` bash
cat <<EOF >> sources.list
deb http://http.debian.net/debian wheezy main non-free
EOF
sudo mv sources.list wheezy/etc/apt/sources.list
sudo chown root:root wheezy/etc/apt/sources.list
sudo chmod 644 wheezy/etc/apt/sources.list
```

#### Setup the WiFi Configuration for the Debian ARM System
* Here we set up our WiFi networks and passwords for the WiFi networks you would like your external interface to connect to.
``` bash
sudo sed -i -e "s/wlan/mlan/g" wheezy/etc/network/interfaces
sudo sed -i -e "s/wpa_supplicant.conf/wpa_supplicant\/wpa_supplicant.conf/g" wheezy/etc/network/interfaces
cat <<EOF >> wpa_supplicant.conf
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF
sudo mv wpa_supplicant.conf wheezy/etc/wpa_supplicant/wpa_supplicant.conf
sudo chown root:root wheezy/etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 644 wheezy/etc/wpa_supplicant/wpa_supplicant.conf
```

#### Setup the IP Address and Settings for the USB Network Interface
* In this step we setup our internal (USB) network interface.  Feel free to use a different static IP address and CIDR block if you prefer something different.
```` bash
cat wheezy/etc/network/interfaces >> interfaces
cat <<EOF >> interfaces
auto usb0
    iface usb0 inet static
    address 172.16.1.2
    netmask 255.255.255.0
EOF
sudo mv interfaces wheezy/etc/network/interfaces
sudo chown root:root wheezy/etc/network/interfaces
sudo chmod 644 wheezy/etc/network/interfaces
````

#### Setup the DHCP Settings for the USB Network Interface
* In this step we setup our internal (USB) network DHCP.  If you changed your IP address information in the step above, you will have to change the DHCP settings to match.
```` bash
cat <<EOF >> dnsmasq.conf
dhcp-range=usb0,172.16.1.10,172.16.1.50,12h
EOF
sudo mv dnsmasq.conf wheezy/etc/dnsmasq.conf
sudo chown root:root wheezy/etc/dnsmasq.conf
sudo chmod 644 wheezy/etc/dnsmasq.conf
````

#### Set the System Locale
* If you prefer a different locale, then change it accordingly.
```` bash
cat <<EOF >> locale
LANG=en_US.UTF-8
EOF
sudo mv locale wheezy/etc/default/locale
sudo chown root:root wheezy/etc/default/locale
sudo chmod 644 wheezy/etc/default/locale
````

#### Bundle the Root File System for Your New Debian OS
* Finally, we tar up our configured Debian filesystem.  This filesystem will be used during the install stage for our Gumstix SD card.
```` bash
cd wheezy
sudo tar -cjf ../wheezy.tar.bz2 *
cd ..
````

-------------------

# Gumstix Overo Debian Wheezy Scripted Build
* In order to speed up the Debian Gumstix build process, I have composed a bash script from all of the manual build steps described above.  The script can be found [here](https://github.com/hackgnar/gumstix-overo-images/blob/master/debian/build_gumstix_debian.sh).  This script was tested on a base Debian 7.7 , Ubuntu 14.04 and Kali Linux 1.0.9 system.  The script contains sudo commands so it will prompt you periodically for a root password when it needs to run privileged commands.

### Download the Build Script
* The build script that encapsulates all of the manual build steps can be obtained from by github repo as shown below.
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/debian_scripted_build.sh
````

### Run the Build Script
* Note this script assumes you are running as a normal user and will prompt you for a sudo password.
* You may find it useful to alter my bash script if you want custom configurations on your OS like root password, different network addresses, different hostname, etc
```` bash
bash debian_scripted_build.sh
````

-----------------------

# Precompiled Debian Wheezy Image Build
If you are not interested in building Debian from scratch, you can always download and install precompiled images.  The image provided below was generated by myself from the steps listed above.

### Download the Base Image and Uboot Files
````
mkdir -p gumstix/debian
cd gumstix/debian
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/u-boot.img
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/wheezy.tar.bz2.split-aa
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/wheezy.tar.bz2.split-ab
cat wheezy.tar.bz2.split* > wheezy.tar.bz2
````

-----------------------

# Install the Image to an SD Card
Once you have built or downloaded your Debian Wheezy Gumstix image, you can use the steps listed in this section to flash the image to an SD card.  You can then use the SD card to boot your Gumstix board.

* These steps require a Linux machine

### Insert Your SD Card
* Make sure to note the device block it gets mapped to.  In most instances it will /dev/sdb

### Format Your SD card
* In the command below, replace sdX with the device your SD card was mapped to which you noted in the previous step
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/mk2partsd
sudo umount /dev/sdX*
sudo ./mk2partsd /dev/sdX
````

### Download Uboot Files if you Don't Already Have Them.
* If you built your image manually and did not download it, you will have to obtain a MLO, uImage and u-boot.img file.  To get these you can grab them from a Yocto build or download them with the following commands. 
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/uboot_image/u-boot.img
````

### Copy Uboot Files and OS Filesystem to the SD Card
* On a Debian system your SD card partitions should automatically get mounted to /media/boot and /media/root.  If this is not the case then make sure your SD cards are mounted and substitute the mount directory referenced in the instructions below.
* On ubuntu 14.04 you may have to unplug and replug your SD card to make it remount after running mk2partsd from the step above. Also on Ubuntu 14.04 your mount locations may be /media/username/{boot,rootfs}
```` bash
cp MLO /media/boot
cp uImage /media/boot
cp u-boot.img /media/boot
sudo tar xaf wheezy.tar.bz2 -C /media/rootfs
sudo sync
sudo umount /media/boot
sudo umount /media/rootfs
````

-----------------

# How to Access the Debian Wheezy Image Running on a Gumstix 
The manual build steps above and the precompiled images set up the base Debian OS to be easily accessed via ssh over wifi, ethernet or USB networking.

**NOTE:** USB serial console support for the Debian image is not setup so you will not be able to log in via minicom, etc

### Recommended Method for Accessing Precompiled Images
* The easiest way to access your Debian system is via SSH over the USB network interface it provides.
* Plug in your Gumstix board which is attached to a daughter board with a usb device port (Tobi, Thumbo, etc) to your host computer.
* Once the Gumstix board finishes booting the OS you can ssh to it over USB with username:root password:hackgnar
````
ssh root@172.16.1.2
````

### Credentials and IP Addresses for the Debian Image
* The precompiled image (or images created with the build script) is setup with the password "hackgnar" for the root user.
* The ipaddress for the Gumstix USB network interface is 172.16.1.2

### Other Methods for Accessing the Installed Debian Image
Here are all of the  methods that you can use to access the image running on your Gumstix Board

* SSH to the usb network interface located at the address listed above.  The Debian image is configured to serve your host computer a DHCP address in the 172.16.1.0/24 block.
* SSH to the ethernet interface if you are using a daughter board with ethernet capabilities (Tobi, etc).  The eth0 interface will pull a DHCP address.
* SSH to the WiFi interface.  This will require that you setup your wpa supplicant file located at /etc/wpa_supplicatnt/wpa_supplicant.conf prior to flashing your SD card.
* NOTE: USB serial console support for the Debian image is not setup so you will not be able to log in via minicom, etc

# Summary

Hopefully you have found this document for installing Debian on a Gumstix Overo useful.  Many of the steps can be altered to install different operating systems.  With a little alteration of the debootstrap command, you should be able to install any OS supported by debootstrap.  This document can also be altered to install Debian based operating systems to different hardware such as the Gumstix DuoVero series.  As the only Gumstix product I own is an IronStorm-P COM with a Tobi board, this document only focuses on this hardware.

My next post will cover installing a Kali Linux OS to the Gumstix Overo board.  I have already tested this setup extensively and just need to finalize some documentation.  Other upcoming posts will cover other various operating systems such as the latest Ubuntu, Fedora, etc.

If you have any comments or questions please feel free to send them my way.  You can post comments here or contact me via Twitter @hackgnar.
