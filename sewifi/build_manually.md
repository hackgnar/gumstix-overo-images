[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Manually Building a Gumstix Overo SEWiFi Image
* **NOTE: This documenation utilizes the deboostrap command so you will likely have to build this on a Debian based system**.  There are some tricks to get around this, but they are not covered here.

* Of all the methods I provide for building/obtaining Gumstix Overo OS images, the manual build process is by far the most time consuming.  If however you are intrested in maually building your own image, this method defiantely allows for the most custimizations to your image.

* These steps build a base Debian OS with the SEWiFi overlay for the Gumstix Overo board and uses files, kernel moduels, firmware created in the [Yocto manual build](../yocto/build_manually.md).  If you have not completed the steps listed in the [Yocto manual build](../yocto/build_manually.md) documentation, you should do that first.

* If you ignore the advice above, you can technicaly complete these build steps by yanking out the reqiured files from a pre compliled Yocto or Debian image provided in this repository in the corrisponding uboot_files directories.  In the near future, I may provide a deb package which houses the required files (stay tuned...).

### Create your build directory
* This follows the standards found in the yocto build.  It is not required that you follow the same directory build stucture.  However, if you do use a different directory stucture, you will have to substitute your directories in my build commands.
```
mkdir -p ~/source/gumstix/sewifi
cd ~/source/gumstix/sewifi
```

### Install Build Dependancies
* these are the files needed to build our base OS
```
/bin/su -c "apt-get install -y debootstrap binfmt-support qemu qemu-user-static"
```

### Create our base ARM Debian OS (First Stage)
* In this step,  we create our base Debian OS with deboostrap.  This is often called "First Stage" build.
```
/bin/su -c "debootstrap --foreign --verbose --arch=armel --include=vim-nox,openssh-server,ntpdate,less,wireless-tools,wpasupplicant,dnsmasq,psmisc,locales,locales-all,screen --exclude=nano wheezy ./sewifi http://ftp.debian.org/debian/"
```

### Copy over our YOCTO kernel modules, firmware and core system files
* In this step, we copy over our kernel modules and system files from our previous Yocto build for our new Debian OS
```
mkdir -p ~/source/gumstix/yocto/filesystem
cd ~/source/gumstix/yocto/filesystem
tar xfj ~/source/gumstix/yocto/build/tmp/deploy/images/overo/gumstix-console-image-overo.tar.bz2 .
/bin/su -c "mkdir -p ~/source/gumstix/sewifi/sewifi/lib/modules"
/bin/su -c "cp -r lib/modules/3.5.7-custom ~/source/gumstix/sewifi/sewifi/lib/modules"
/bin/su -c "mkdir -p ~/source/gumstix/sewifi/sewifi/lib/firmware"
/bin/su -c "cp -r lib/firmware/* ~/source/gumstix/sewifi/sewifi/lib/firmware"
/bin/su -c "cp etc/fstab  ~/source/gumstix/sewifi/sewifi/etc/fstab"
/bin/su -c "cp etc/network/interfaces  ~/source/gumstix/sewifi/sewifi/etc/network/"
```

### Configure our base ARM Debian OS (Second Stage)
* This is typicaly called "Second Stage" build.
* Here we configure all of the packages we installed from the First Stage
```
cd ~/source/gumstix/sewifi
/bin/su -c "cp /usr/bin/qemu-arm-static sewifi/usr/bin"
/bin/su -c "chroot sewifi ./debootstrap/debootstrap --second-stage"
```

### More Configuration for our Debian ARM OS (Third Stage)
* Durint this configuration stage, we set up more personal configurations such as passwords, hostnames, network addresses, etc
* this section is broken up into smaller subsections.
* During this stage, you may choose to customize network interfaces, passwords, etc.

#### Set our system password
* Feel free to set your own password here.
```
su -c "chroot sewifi /bin/bash -c 'echo \"root:hackgnar\" | chpasswd'"
```

#### Set up our remote apt repository
* Feel free to use a different core apt repository if you like.
* If you want backports, you can also add this line **deb http://http.debian.net/debian wheezy-backports main**
```
cat << EOF > sewifi/etc/apt/sources.list
deb http://http.debian.net/debian wheezy main non-free
deb https://raw.githubusercontent.com/hackgnar/sewifi/master/apt-repo main
EOF
```

#### Setup our wifi configuration for the Debian ARM system
* Here we set up our WiFi networks and passwords for the WiFi networks you would like your external interface to connect to.
```
/bin/su -c "sed -i -e \"s/wlan/mlan/g\" ~/source/gumstix/sewifi/sewifi/etc/network/interfaces"
/bin/su -c "sed -i -e \"s/wpa_supplicant.conf/wpa_supplicant\/wpa_supplicant.conf/g\" ~/source/gumstix/sewifi/sewifi/etc/network/interfaces"
cat <<EOF >> wpa.tmp
network={
    ssid="MyWiFiNetwork1"
    psk="MyPassword"
    priority=5
}
EOF
/bin/su -c "cat wpa.tmp >> ~/source/gumstix/sewifi/sewifi/etc/wpa_supplicant/wpa_supplicant.conf"
rm wpa.tmp
```

#### Setup our address and dhcp settings for the usb network interface
* In this step we setup our internal (USB) network interface.  Feel free to use a different static IP address and CIDR block if you prefer something different.
````
cat <<EOF >> interfaces.tmp
auto usb0
    iface usb0 inet static
    address 172.16.1.2
    netmask 255.255.255.0
EOF
/bin/su -c "cat interfaces.tmp >> ~/source/gumstix/sewifi/sewifi/etc/network/interfaces"
rm interfaces.tmp
/bin/su -c "echo dhcp-range=usb0,172.16.1.10,172.16.1.50,12h > ~/source/gumstix/sewifi/sewifi/etc/dnsmasq.conf"
````

#### Set our system locale
* If you prefer a different locale, then change it accordingly.
````
/bin/su -c "echo LANG=en_US.UTF-8 >> ~/source/gumstix/sewifi/sewifi/etc/default/locale"
````

#### Install the SEWiFi overlay and clean up
````
cd ~/souce/gumstix/sewifi
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
````

#### Bundle our root file system for our new Debian OS
* Finally, we tar up our configured Debian filesystem.  This filesystem will be used during the install stage for our Gumstix SD card.
````
cd ~/source/gumstix/sewifi/sewifi
/bin/su -c "tar -cjf ../sewifi.tar.bz2 *"
````

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
