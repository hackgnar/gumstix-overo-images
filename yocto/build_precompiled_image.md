[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Precompiled Image Build
Flexitarian fanny pack sartorial jean shorts, hoodie Etsy ethical. Keytar irony Banksy kogi seitan typewriter tilde, viral slow-carb polaroid salvia 8-bit Bushwick cronut. Wes Anderson photo booth Etsy master cleanse, leggings American Apparel cardigan hoodie plaid 8-bit Blue Bottle Helvetica Banksy meggings.

### Download the base image uboot files
````
mkdir myimage
cd myimage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/MLO
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/uImage
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/u-boot.img
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/uboot_image/gumstix-console-image-overo-20141218160757.rootfs.tar.bz2
````

### Install to SD Card
Documentation on installing this image can be found here:  

* [Install Image to SD](install_image.md)
