#!/bin/bash

SEWIFI_DIR=~/source/gumstix/sewifi
YOCTO_DIR=~/source/gumstix/yocto
mkdir -p $SEWIFI_DIR
cd $SEWIFI_DIR

/bin/su -c "apt-get install -y debootstrap binfmt-support qemu qemu-user-static"

#First Stage
/bin/su -c "debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen,apt-transport-https --exclude=nano wheezy ./sewifi http://ftp.debian.org/debian/"

mkdir -p $YOCTO_DIR/filesystem
cd $YOCTO_DIR/filesystem
tar xfj $YOCTO_DIR/build/tmp/deploy/images/overo/gumstix-console-image-overo.tar.bz2 .
/bin/su -c "mkdir -p $SEWIFI_DIR/sewifi/lib/modules"
/bin/su -c "cp -r lib/modules/3.5.7-custom $SEWIFI_DIR/sewifi/lib/modules"
/bin/su -c "mkdir -p $SEWIFI_DIR/sewifi/lib/firmware"
/bin/su -c "cp -r lib/firmware/* $SEWIFI_DIR/sewifi/lib/firmware"
/bin/su -c "cp etc/fstab  $SEWIFI_DIR/sewifi/etc/fstab"
/bin/su -c "cp etc/network/interfaces  $SEWIFI_DIR/sewifi/etc/network/"

#Second Stage
cd $SEWIFI_DIR
/bin/su -c "cp /usr/bin/qemu-arm-static sewifi/usr/bin"
/bin/su -c "chroot sewifi ./debootstrap/debootstrap --second-stage"

#Third Stage
su -c "chroot sewifi /bin/bash -c 'echo \"root:hackgnar\" | chpasswd'"

cat << EOF > sewifi/etc/apt/sources.list
deb http://http.debian.net/debian wheezy main non-free
deb https://raw.githubusercontent.com/hackgnar/sewifi/master/apt-repo main
EOF

/bin/su -c "sed -i -e \"s/wlan/mlan/g\" $SEWIFI_DIR/sewifi/etc/network/interfaces"
/bin/su -c "sed -i -e \"s/wpa_supplicant.conf/wpa_supplicant\/wpa_supplicant.conf/g\" $SEWIFI_DIR/sewifi/etc/network/interfaces"
cat <<EOF >> wpa.tmp
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF
/bin/su -c "cat wpa.tmp >> $SEWIFI_DIR/sewifi/etc/wpa_supplicant/wpa_supplicant.conf"
rm wpa.tmp
cat <<EOF >> interfaces.tmp
auto usb0
    iface usb0 inet static
    address 172.16.1.2
    netmask 255.255.255.0
EOF
/bin/su -c "cat interfaces.tmp >> $SEWIFI_DIR/sewifi/etc/network/interfaces"
rm interfaces.tmp
/bin/su -c "echo dhcp-range=usb0,172.16.1.10,172.16.1.50,12h > $SEWIFI_DIR/sewifi/etc/dnsmasq.conf"
/bin/su -c "echo LANG=en_US.UTF-8 >> $SEWIFI_DIR/sewifi/etc/default/locale"

cd $SEWIFI_DIR
cat << EOF > sewifi/third-stage
#!/bin/bash
apt-get update
apt-get -y install sewifi-gumstix-overo
#locale-gen en_US.UTF-8
rm -rf /root/.bash_history
apt-get clean
rm -f /third-stage
EOF
chmod +x sewifi/third-stage
LANG=C chroot sewifi /third-stage

cd $SEWIFI_DIR/sewifi
/bin/su -c "tar -cjf ../sewifi.tar.bz2 *"
