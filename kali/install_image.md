[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Install image to SD Card
* requires a linux machine

### Insert your SD Card
* note the device block it gets mapped to.  In most instances it will /dev/sdb

### Format your SD card
* in the command below, replace sdX with the device your SD card was mapped to which you noted in the previous step
````
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/mk2partsd
./mk2partsd /dev/sdX
````

### Copy uboot files to the SD card
* On a debian system your SD card partitions should automaticly get mounted to /media/boot and /media/root.  If this is not the case then make sure your SD cards are mounted and substitute the mount directory refrenced in the instuctions below.
````
cp MLO /media/boot
cp uImage /media/boot
cp u-boot.img /media/boot
tar xaf kali.tar.bz2 -C /media/rootfs
sync
umount /media/boot
umount /media/rootfs
````
