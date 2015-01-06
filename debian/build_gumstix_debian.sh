#!/bin/bash

DEBIAN_DIR=~/source/gumstix/debian
YOCTO_DIR=~/source/gumstix/yocto
mkdir -p $DEBIAN_DIR
cd $DEBIAN_DIR

/bin/su -c "apt-get install -y debootstrap binfmt-support qemu qemu-user-static"

#First Stage
/bin/su -c "debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano wheezy ./wheezy http://ftp.debian.org/debian/"

mkdir -p $YOCTO_DIR/filesystem
cd $YOCTO_DIR/filesystem
tar xfj $YOCTO_DIR/build/tmp/deploy/images/overo/gumstix-console-image-overo.tar.bz2 .
/bin/su -c "mkdir -p $DEBIAN_DIR/wheezy/lib/modules"
/bin/su -c "cp -r lib/modules/3.5.7-custom $DEBIAN_DIR/wheezy/lib/modules"
/bin/su -c "mkdir -p $DEBIAN_DIR/wheezy/lib/firmware"
/bin/su -c "cp -r lib/firmware/* $DEBIAN_DIR/wheezy/lib/firmware"
/bin/su -c "cp etc/fstab  $DEBIAN_DIR/wheezy/etc/fstab"
/bin/su -c "cp etc/network/interfaces  $DEBIAN_DIR/wheezy/etc/network/"

#Second Stage
cd $DEBIAN_DIR
/bin/su -c "cp /usr/bin/qemu-arm-static wheezy/usr/bin"
/bin/su -c "chroot wheezy ./debootstrap/debootstrap --second-stage"

#Third Stage
su -c "chroot wheezy /bin/bash -c 'echo \"root:hackgnar\" | chpasswd'"
/bin/su -c "echo \"deb http://http.debian.net/debian wheezy main non-free\" > $DEBIAN_DIR/wheezy/etc/apt/sources.list"
/bin/su -c "sed -i -e \"s/wlan/mlan/g\" $DEBIAN_DIR/wheezy/etc/network/interfaces"
/bin/su -c "sed -i -e \"s/wpa_supplicant.conf/wpa_supplicant\/wpa_supplicant.conf/g\" $DEBIAN_DIR/wheezy/etc/network/interfaces"
cat <<EOF >> wpa.tmp
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF
/bin/su -c "cat wpa.tmp >> $DEBIAN_DIR/wheezy/etc/wpa_supplicant/wpa_supplicant.conf"
rm wpa.tmp
cat <<EOF >> interfaces.tmp
auto usb0
    iface usb0 inet static
    address 172.16.1.2
    netmask 255.255.255.0
EOF
/bin/su -c "cat interfaces.tmp >> $DEBIAN_DIR/wheezy/etc/network/interfaces"
rm interfaces.tmp
/bin/su -c "echo dhcp-range=usb0,172.16.1.10,172.16.1.50,12h > $DEBIAN_DIR/wheezy/etc/dnsmasq.conf"
/bin/su -c "echo LANG=en_US.UTF-8 >> $DEBIAN_DIR/wheezy/etc/default/locale"


cd $DEBIAN_DIR/wheezy
/bin/su -c "tar -cjf ../wheezy.tar.bz2 *"
