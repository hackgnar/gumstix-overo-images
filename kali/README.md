# Building Kali Linux for Gumstix Overo

This writeup goes over details on how to build and install a Kali Linux image for an Overo Gumstix board. The build notes and images in this post are for a stock Kali Linux OS configured for a Gumstix Overo device. The Kali image is configured for easy SSH network access over wired, wireless or USB when the Gumstix device is powered.

This Kali build utilizes the kernel, modules and firmware from the Gumstix Overo Yocto build.  You do not have to build your own Yocto image as this documentation utilizes a precompiled version, but if you are interested in building your own, you can check our my previous post ["Building Yocto Linux Images for the Gumstix Overo"](http://www.hackgnar.com/2015/03/building-yocto-linux-images-for-gumstix.html)

Here is a short summary of what this writeup covers:

1.  How to manually build a Kali Linux image for a Gumstix Overo.
2.  An alternative scripted method to build a Gumstix Kali image.
3.  Where to download a precompiled Kali Linux Gumstix Overo image if you are not interested in building them yourself.
4.  How to install a Kali Linux image to an SD card for your Gumstix board.
5.  How to access your Kali image after installation

-------------

# Manually Building a Gumstix Overo Kali Linux Image
* These steps build a base Kali Linux OS for the Gumstix Overo board and uses files, kernel modules, firmware obtained from a Gumstix Overo Yocto build. You do not have to build your own Yocto image as this documentation utilizes a precompiled version, but if you are interested in building your own, you can check our my previous post ["Building Yocto Linux Images for the Gumstix Overo"](http://www.hackgnar.com/2015/03/building-yocto-linux-images-for-gumstix.html)

* These build steps were tested on Debian 7.7, Ubuntu 14.04 and Kali Linux 1.0.9 host system. 

* **NOTE: This documentation utilizes the deboostrap command so you will likely have to build this on a Debian (Kali is Debian based) or Ubuntu based system**.  There are some tricks to get around this, but they are not covered here.

### Create Your Build Directory
* First we will create a build directory.  It is not required that you follow the same directory build structure.  However, if you do use a different directory structure, you will have to substitute your directories in my build commands.
``` bash
mkdir -p gumstix/kali
cd gumstix/kali
```

### Install Build Dependancies
* We must first install these following applications in order to build our base OS
``` bash
sudo apt-get install -y debootstrap binfmt-support qemu qemu-user-static curl
```

### Download and Install the Kali Linux Debootstrap Config File
* Debian and Ubuntu do not include a Kali Linux debootstrap file.  If you are doing this build on a Kali Linux host machine, you can skip this step.
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/kali_debootstrap
sudo mv kali_debootstrap /usr/share/debootstrap/scripts/kali
````

### Create the Base ARM Kali OS (First Stage)
* In this step,  we create our base Kali OS with deboostrap.  This is often called "First Stage" build.
``` bash
sudo debootstrap --foreign --arch armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano kali ./kali http://archive.kali.org/kali
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
sudo mkdir -p kali/lib/modules
sudo mkdir -p kali/lib/firmware
sudo cp -r yocto/lib/modules/3.5.7-custom kali/lib/modules
sudo cp -r yocto/lib/firmware/* kali/lib/firmware
sudo cp yocto/etc/fstab kali/etc/fstab
sudo cp yocto/etc/network/interfaces kali/etc/network/
```

### Configure the Base ARM Kali OS (Second Stage)
* This is typically called "Second Stage" build.
* Here we configure all of the packages we installed from the First Stage
``` bash
sudo cp /usr/bin/qemu-arm-static kali/usr/bin
sudo chroot kali ./debootstrap/debootstrap --second-stage
```

### More Configuration for the Debian ARM OS (Third Stage)
* During this configuration stage, we set up more personal configurations such as passwords, hostnames, network addresses, etc
* this section is broken up into smaller subsections.
* During this stage, you may choose to customize network interfaces, passwords, etc.

#### Set the System Password
* Feel free to set your own password here, but remember it so you can ssh into your system after installation.
``` bash
sudo chroot kali /bin/bash -c 'echo "root:toor" | chpasswd'
```

#### Set Up Our Remote Apt Repository
* Feel free to add more apt repositories if you like.
``` bash
cat << EOF >> sources.list
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
sudo mv sources.list kali/etc/apt/sources.list
sudo chown root:root kali/etc/apt/sources.list
sudo chmod 644 kali/etc/apt/sources.list
```

#### Set the Hostname for the Kali System
* Feel free to change this if you want something else
```` bash
cat << EOF >> hostname
kali
EOF
sudo mv hostname kali/etc/hostname
sudo chown root:root kali/etc/hostname
sudo chmod 644 kali/etc/hostname
````

#### Setup the WiFi Configuration for the Debian ARM System
* Here we set up our WiFi networks and passwords for the WiFi networks you would like your external interface to connect to.
``` bash
cat <<EOF >> wpa_supplicant.conf
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF
sudo mv wpa_supplicant.conf kali/etc/wpa_supplicant/wpa_supplicant.conf
sudo chown root:root kali/etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 644 kali/etc/wpa_supplicant/wpa_supplicant.conf
```

#### Setup the IP Address and Settings for the USB Network Interface
* In this step we setup our internal (USB) network interface.  Feel free to use a different static IP address and CIDR block if you prefer something different.
* You can also change eth0 or mlan0 to be a static IP instead of dhcp
```` bash
cat << EOF >> interfaces
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
auto usb0
    iface usb0 inet static
    address 172.16.1.2
    netmask 255.255.255.0
allow-hotplug mlan0
iface mlan0 inet dhcp
    pre-up wpa_supplicant -Dwext -imlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf -B
    down killall wpa_supplicant
EOF
sudo mv interfaces kali/etc/network/interfaces
sudo chown root:root kali/etc/network/interfaces
sudo chmod 644 kali/etc/network/interfaces
````

#### Setup the DHCP Settings for the USB Network Interface
* In this step we setup our internal (USB) network DHCP.  If you changed your IP address information in the step above, you will have to change the DHCP settings to match.
```` bash
cat <<EOF >> dnsmasq.conf
dhcp-range=usb0,172.16.1.10,172.16.1.50,12h
EOF
sudo mv dnsmasq.conf kali/etc/dnsmasq.conf
sudo chown root:root kali/etc/dnsmasq.conf
sudo chmod 644 kali/etc/dnsmasq.conf
````

#### Finalize the Third Stage
* In this section we will finalize the third stage configuration. 
* Set some environment variable for upcomming steps
```` bash
export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
````

* Mount some of the host mounts to the chroot environment
```` bash
sudo mount -t proc proc kali/proc
sudo mount -o bind /dev/ kali/dev/
sudo mount -o bind /dev/pts kali/dev/pts
````

* Configure our debconf for the Kali system
```` bash
cat << EOF >> debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF
sudo mv debconf.set kali/debconf.set
sudo chown root:root kali/debconf.set
sudo chmod 644 kali/debconf.set
````

* This step bundles a lot of Kali Linux configurations into a large blob.  It could likely be broken up into smaller steps to make it more readable.  Unfortunately for now, it is how it is.
* Copy, paste, cross your fingers and close your eyes...  Your almost to the finish line.
```` bash
cat << EOF >> third-stage
#!/bin/bash
dpkg-divert --add --local --divert /usr/sbin/invoke-rc.d.chroot --rename /usr/sbin/invoke-rc.d
cp /bin/true /usr/sbin/invoke-rc.d
apt-get update
apt-get install locales-all
#locale-gen en_US.UTF-8
update-rc.d -f ssh remove
update-rc.d -f ssh defaults
update-rc.d -f dnsmasq remove
update-rc.d -f dnsmasq defaults
debconf-set-selections /debconf.set
rm -f /debconf.set
apt-get update
apt-get -y install git-core binutils ca-certificates initramfs-tools uboot-mkimage
apt-get -y install locales console-common less nano git
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d
rm -f /third-stage
EOF
sudo mv third-stage kali/third-stage
sudo chown root:root kali/third-stage
sudo chmod 744 kali/third-stage
sudo chroot kali /third-stage
````

#### Set the System Locale
* If you prefer a different locale, then change it accordingly.
```` bash
cat <<EOF >> locale
LANG=en_US.UTF-8
EOF
sudo mv locale kali/etc/default/locale
sudo chown root:root kali/etc/default/locale
sudo chmod 644 kali/etc/default/locale
````

#### Clean Up Our New Kali OS
* This step cleans some logs and unmounts partitions from our stage three steps.
* First we will clean the logs
```` bash
cat << EOF >> cleanup
#!/bin/bash
rm -rf /root/.bash_history
apt-get update
apt-get clean
rm -f cleanup
EOF
sudo mv cleanup kali/cleanup
sudo chown root:root kali/cleanup
sudo chmod 744 kali/cleanup
sudo chroot kali /cleanup
````

* Then we unmount our host partitions from the chroot environment
```` bash
sudo umount kali/proc
sudo umount kali/dev/pts
sudo umount kali/dev/
````

#### Bundle the Root File System for Your New Kali OS
* Finally, we tar up our configured Kali filesystem.  This filesystem will be used during the install stage for our Gumstix SD card.
```` bash
cd kali
sudo tar -cjf ../kali.tar.bz2 *
cd ..
````

-------------------

# Gumstix Overo Kali Linux Scripted Build
* In order to speed up the Kali Gumstix build process, I have composed a bash script from all of the manual build steps described above.  The script can be found [here](https://github.com/hackgnar/gumstix-overo-images/blob/master/kali/build_gumstix_kali.sh).  This script was tested on a base Debian 7.7 , Ubuntu 14.04 and Kali Linux 1.0.9 system.  The script contains sudo commands so it will prompt you periodically for a root password when it needs to run privileged commands.

### Download the Build Script
* The build script that encapsulates all of the manual build steps can be obtained from by github repo as shown below.
```` bash
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/kali_scripted_build.sh
````

### Run the Build Script
* Note this script assumes you are running as a normal user and will prompt you for a sudo password.
* You may find it useful to alter my bash script if you want custom configurations on your OS like root password, different network addresses, different hostname, etc
```` bash
bash kali_scripted_build.sh
````

-----------------------

# Precompiled Kali Linux Image Build
If you are not interested in building Kali from scratch, you can always download and install precompiled images.  The image provided below was generated by myself from the steps listed above.

### Download the Base Image and Uboot Files
````
mkdir -p gumstix/kali
cd gumstix/kali
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/u-boot.img
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/kali.tar.bz2.split-aa
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/kali.tar.bz2.split-ab
cat kali.tar.bz2.split* > kali.tar.bz2
````

-----------------------

# Install the Image to an SD Card
Once you have built or downloaded your Kali Linux Gumstix image, you can use the steps listed in this section to flash the image to an SD card.  You can then use the SD card to boot your Gumstix board.

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
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/uboot_image/u-boot.img
````

### Copy Uboot Files and OS Filesystem to the SD Card
* On a Debian system your SD card partitions should automatically get mounted to /media/boot and /media/root.  If this is not the case then make sure your SD cards are mounted and substitute the mount directory referenced in the instructions below.
* On ubuntu 14.04 you may have to unplug and replug your SD card to make it remount after running mk2partsd from the step above. Also on Ubuntu 14.04 your mount locations may be /media/username/{boot,rootfs}
```` bash
cp MLO /media/boot
cp uImage /media/boot
cp u-boot.img /media/boot
sudo tar xaf kali.tar.bz2 -C /media/rootfs
sudo sync
sudo umount /media/boot
sudo umount /media/rootfs
````

-----------------

# How to Access the Kali Linux Image Running on a Gumstix 
The manual build steps above and the precompiled images set up the base Kali OS to be easily accessed via ssh over wifi, ethernet or USB networking.

**NOTE:** USB serial console support for the Kali image is not setup so you will not be able to log in via minicom, etc

### Recommended Method for Accessing Precompiled Images
* The easiest way to access your Kali system is via SSH over the USB network interface it provides.
* Plug in your Gumstix board which is attached to a daughter board with a usb device port (Tobi, Thumbo, etc) to your host computer.
* Once the Gumstix board finishes booting the OS you can ssh to it over USB with username:root password:toor
````
ssh root@172.16.1.2
````

### Credentials and IP Addresses for the Kali Image
* The precompiled image (or images created with the build script) is setup with the password "toor" for the root user.
* The ipaddress for the Gumstix USB network interface is 172.16.1.2

### Other Methods for Accessing the Installed Kali Image
Here are all of the  methods that you can use to access the image running on your Gumstix Board

* SSH to the usb network interface located at the address listed above.  The Kali image is configured to serve your host computer a DHCP address in the 172.16.1.0/24 block.
* SSH to the ethernet interface if you are using a daughter board with ethernet capabilities (Tobi, etc).  The eth0 interface will pull a DHCP address.
* SSH to the WiFi interface.  This will require that you setup your wpa supplicant file located at /etc/wpa_supplicatnt/wpa_supplicant.conf prior to flashing your SD card.
* NOTE: USB serial console support for the Kali image is not setup so you will not be able to log in via minicom, etc

# Summary

Hopefully you have found this document for installing Kali Linux on a Gumstix Overo useful.  Many of the steps can be altered to install different operating systems.  With a little alteration of the debootstrap command, you should be able to install any OS supported by debootstrap.  This document can also be altered to install Kali based operating systems to different hardware such as the Gumstix DuoVero series.  As the only Gumstix product I own is an IronStorm-P COM with a Thumbo and Tobi board, this document only focuses on this hardware.

If you have any comments or questions please feel free to send them my way.  You can post comments here or contact me via Twitter @hackgnar.
