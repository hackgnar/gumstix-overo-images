#!/bin/bash

### Create your build directory
mkdir -p gumstix/kali
cd gumstix/kali

### Install Build Dependancies
sudo apt-get install -y debootstrap binfmt-support qemu qemu-user-static curl

### Download the kali linux debootstrap config file and install it
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/kali_debootstrap
sudo mv kali_debootstrap /usr/share/debootstrap/scripts/kali

### Create our base ARM Kali OS (First Stage)
sudo debootstrap --foreign --arch armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano kali ./kali http://archive.kali.org/kali

### Download a Yocto Image to Utilize its kernel modules and firmware
curl -O curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/gumstix-console-image-overo-20141218160757.rootfs.tar.bz2
mkdir yocto
tar xaf gumstix-console-image-overo-20141218160757.rootfs.tar.bz2 -C ./yocto

### Copy over our Yocto kernel modules, firmware and core system files
sudo mkdir -p kali/lib/modules
sudo mkdir -p kali/lib/firmware
sudo cp -r yocto/lib/modules/3.5.7-custom kali/lib/modules
sudo cp -r yocto/lib/firmware/* kali/lib/firmware
sudo cp yocto/etc/fstab kali/etc/fstab
sudo cp yocto/etc/network/interfaces kali/etc/network/

### Configure our base ARM Kali OS (Second Stage)
sudo cp /usr/bin/qemu-arm-static kali/usr/bin
sudo chroot kali ./debootstrap/debootstrap --second-stage

### More Configuration for our Kali ARM OS (Third Stage)

#### Set the System Password
sudo chroot kali /bin/bash -c 'echo "root:toor" | chpasswd'

#### Set up our remote apt repository
cat << EOF >> sources.list
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
sudo mv sources.list kali/etc/apt/sources.list
sudo chown root:root kali/etc/apt/sources.list
sudo chmod 644 kali/etc/apt/sources.list


#### Setup hostname... this is missing from my Kali config... hopefuly echo works
cat << EOF >> hostname
kali
EOF
sudo mv hostname kali/etc/hostname
sudo chown root:root kali/etc/hostname
sudo chmod 644 kali/etc/hostname

#### Setup our wifi configuration for the Kali ARM system
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

#### Setup our IP address settings for the usb network interface
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

#### Setup dhcp settings for the usb network interface
cat <<EOF >> dnsmasq.conf
dhcp-range=usb0,172.16.1.10,172.16.1.50,12h
EOF
sudo mv dnsmasq.conf kali/etc/dnsmasq.conf
sudo chown root:root kali/etc/dnsmasq.conf
sudo chmod 644 kali/etc/dnsmasq.conf

#Third Stage Finalize
export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

sudo mount -t proc proc kali/proc
sudo mount -o bind /dev/ kali/dev/
sudo mount -o bind /dev/pts kali/dev/pts

cat << EOF >> debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF
sudo mv debconf.set kali/debconf.set
sudo chown root:root kali/debconf.set
sudo chmod 644 kali/debconf.set

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

#### Set our system locale
#echo LANG=en_US.UTF-8 >> $KALI_DIR/kali/etc/default/locale
cat <<EOF >> locale
LANG=en_US.UTF-8
EOF
sudo mv locale kali/etc/default/locale
sudo chown root:root kali/etc/default/locale
sudo chmod 644 kali/etc/default/locale

#CLEANUP
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

sudo umount kali/proc
sudo umount kali/dev/pts
sudo umount kali/dev/

## TAR IT UP... DONE!!!
cd kali
sudo tar -cjf ../kali.tar.bz2 *
cd ..
