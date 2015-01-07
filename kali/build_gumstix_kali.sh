#!/bin/bash

KALI_DIR=~/source/gumstix/kali
YOCTO_DIR=~/source/gumstix/yocto
mkdir -p $KALI_DIR
cd $KALI_DIR

apt-get install -y debootstrap binfmt-support qemu qemu-user-static
#TODO: FIX THIS SHIT
curl -O url/kali_debootstrap
mv kali_debootstrap /usr/share/debootstrap/scripts/kali
#ALSO NOTE: after bootstrap starts, i get this warning
#W: Cannot check Release signature; keyring file not available /usr/share/keyrings/kali-archive-keyring.gpg

#First Stage
#TODO: --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano
debootstrap --foreign --arch armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano kali ./kali http://archive.kali.org/kali
cp /usr/bin/qemu-arm-static kali/usr/bin

##Stage ??? 1.5 ???
mkdir -p $YOCTO_DIR/filesystem
cd $YOCTO_DIR/filesystem
tar xfj $YOCTO_DIR/build/tmp/deploy/images/overo/gumstix-console-image-overo.tar.bz2 .
mkdir -p $KALI_DIR/kali/lib/modules
cp -r lib/modules/3.5.7-custom $KALI_DIR/kali/lib/modules
mkdir -p $KALI_DIR/kali/lib/firmware
cp -r lib/firmware/* $KALI_DIR/kali/lib/firmware
cp etc/fstab $KALI_DIR/kali/etc/fstab

#Second Stage
cd $KALI_DIR
LANG=C chroot kali /debootstrap/debootstrap --second-stage
cat << EOF > kali/etc/apt/sources.list
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
echo "kali" > kali/etc/hostname
cat << EOF > kali/etc/network/interfaces
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
cat <<EOF > kali/etc/wpa_supplicant/wpa_supplicant.conf
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF

#Third Stage
cd $KALI_DIR/kali
export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
mount -t proc proc kali/proc
mount -o bind /dev/ kali/dev/
mount -o bind /dev/pts kali/dev/pts
cat << EOF > kali/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF
cat << EOF > kali/third-stage
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
echo "root:toor" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
#apt-get --yes --force-yes install $packages
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d
rm -f /third-stage
EOF
chmod +x kali/third-stage
LANG=C chroot kali /third-stage
echo dhcp-range=usb0,172.16.1.10,172.16.1.50,12h > $KALI_DIR/kali/etc/dnsmasq.conf
echo LANG=en_US.UTF-8 >> $KALI_DIR/kali/etc/default/locale

#CLEANUP
cat << EOF > kali/cleanup
#!/bin/bash
rm -rf /root/.bash_history
apt-get update
apt-get clean
rm -f cleanup
EOF
chmod +x kali/cleanup
LANG=C chroot kali /cleanup
umount kali/proc
umount kali/dev/pts
umount kali/dev/

## TAR IT UP... DONE!!!
cd $KALI_DIR/kali
tar -cjf ../kali.tar.bz2 *
