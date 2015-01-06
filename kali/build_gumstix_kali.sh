#!/bin/bash

KALI_DIR=~/source/gumstix/kali
YOCTO_DIR=~/source/gumstix/yocto

/bin/su -c "apt-get install -y debootstrap binfmt-support qemu qemu-user-static"
#should I also install locales and locales-all?
#if so, I need to headless set en-US-utf8 instead of dpkg-reconfigure locales

mkdir -p $KALI_DIR
cd $KALI_DIR

/bin/su -c "debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc --exclude=nano kali ./kali http://archive.kali.org/kali"

/bin/su -c "cp /usr/bin/qemu-arm-static kali/usr/bin"

/bin/su -c "chroot kali ./debootstrap/debootstrap --second-stage"
/bin/su -c "chroot kali /bin/bash -c 'echo \"root:toor\" | chpasswd'"
/bin/su -c "echo kali > kali/etc/hostname"

mkdir -p $YOCTO_DIR/filesystem
cd $YOCTO_DIR/filesystem

tar xfj $YOCTO_DIR/build/tmp/deploy/images/overo/gumstix-console-image-overo.tar.bz2 .

/bin/su -c "mkdir $KALI_DIR/kali/lib/modules"
/bin/su -c "cp -r lib/modules/3.5.7-custom $KALI_DIR/kali/lib/modules"
/bin/su -c "cp -r lib/firmware/* $KALI_DIR/kali/lib/firmware"
/bin/su -c "cp etc/fstab  $KALI_DIR/kali/etc/fstab"
/bin/su -c "cp etc/network/interfaces  $KALI_DIR/kali/etc/network/"
cat << EOF >> sources.tmp
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
/bin/su -c "cat srouces.tmp >> $KALI_DIR/kali/etc/apt/sources.list"
rm sources.tmp

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

cd $DEBIAN_DIR/wheezy
/bin/su -c "tar -cjf ../wheezy.tar.bz2 *"

#cd $YOCTO_DIR/poky/meta-gumstix-extras/scripts
#./mk2partsd /dev/sdX
#cd $YOCTO_DIR/build/tmp/deploy/images/overo/ 
#cp MLO u-boot.img uImage /media/boot
#cd $DEBIAN_DIR
#tar xaf wheezy.tar.bz2 -C /media/rootfs
#sync
