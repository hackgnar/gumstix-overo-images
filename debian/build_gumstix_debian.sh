#!/bin/bash

### Create your build directory
mkdir -p gumstix/debian
cd gumstix/debian

### Install Build Dependancies
sudo apt-get install -y debootstrap binfmt-support qemu qemu-user-static curl

### Create our base ARM Debian OS (First Stage)
sudo debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano wheezy ./wheezy http://ftp.debian.org/debian/

### Download a Yocto Image to Utilize its kernel modules and firmware
curl -O curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/gumstix-console-image-overo-20141218160757.rootfs.tar.bz2
mkdir yocto
tar xaf gumstix-console-image-overo-20141218160757.rootfs.tar.bz2 -C ./yocto

### Copy over our Yocto kernel modules, firmware and core system files
sudo mkdir -p wheezy/lib/modules
sudo mkdir -p wheezy/lib/firmware
sudo cp -r yocto/lib/modules/3.5.7-custom wheezy/lib/modules
sudo cp -r yocto/lib/firmware/* wheezy/lib/firmware
sudo cp yocto/etc/fstab  wheezy/etc/fstab
sudo cp yocto/etc/network/interfaces  wheezy/etc/network/

### Configure our base ARM Debian OS (Second Stage)
sudo cp /usr/bin/qemu-arm-static wheezy/usr/bin
sudo chroot wheezy ./debootstrap/debootstrap --second-stage

### More Configuration for our Debian ARM OS (Third Stage)

#### Set our system password
sudo chroot wheezy /bin/bash -c 'echo "root:hackgnar" | chpasswd'

#### Set up our remote apt repository
cat <<EOF >> sources.list
deb http://http.debian.net/debian wheezy main non-free
EOF
sudo mv sources.list wheezy/etc/apt/sources.list
sudo chown root:root wheezy/etc/apt/sources.list
sudo chmod 644 wheezy/etc/apt/sources.list

#### Setup our wifi configuration for the Debian ARM system
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

#### Setup our IP address settings for the usb network interface
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

#### Setup dhcp settings for the usb network interface
cat <<EOF >> dnsmasq.conf
dhcp-range=usb0,172.16.1.10,172.16.1.50,12h
EOF
sudo mv dnsmasq.conf wheezy/etc/dnsmasq.conf
sudo chown root:root wheezy/etc/dnsmasq.conf
sudo chmod 644 wheezy/etc/dnsmasq.conf

#### Set our system locale
cat <<EOF >> locale
LANG=en_US.UTF-8
EOF
sudo mv locale wheezy/etc/default/locale
sudo chown root:root wheezy/etc/default/locale
sudo chmod 644 wheezy/etc/default/locale

#### Bundle our root file system for our new Debian OS
cd wheezy
sudo tar -cjf ../wheezy.tar.bz2 *
cd ..
