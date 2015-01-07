[![Follow Hackgnar](static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

## OS Images for Gumstix Overo
This repository houses OS images, documentation and scripts to assist in obtaining/building various Linux distributions for the Gumstix Overo ARM board.  All of the Linux images here are configured to support USB networking on the Gumstix device for easy access via USB.

This repository currently provides images, scripts and documentation building the following Linux distributions:

### [Yocto](yocto)
* This is the standard Yocto Linux image provided by Gumstix for the Overo boards.
* Asside from providing another place to obtain the standard Gumstix Yocto image, this project provides extended documentation on doing manual builds and also automated build scripts to ease the build process.

### [Debian](debian)
* The Debian image provided by this project is based on the latest Debian wheezy armel release.
* The documentation this project provides for the manual build process can be altered to create images for other Debian OS varients.

### [SEWiFi](sewifi)
* The SEWiFi image is a Debian image varient which aims to turn a Gumstix Overo board into a security enhanced WiFi dongle.
* Features of the SEWiFi image include a customised firewall, IDS, IPS, VPN, etc for all network connections connecting from a host computer though the Gumstix Overo USB network to a connected WiFi network.
* More information on the project can be found [here](hackgnar.com)

### [Kali](kali)
* The Kali image is a minimal install of Kali Linux
* I am currently lacking the manual build documentation.
* The scripted build is verfied to be working.
* The provided precompiled image is also verified to be working.

### Ubuntu (14.X)
* Work in progress... Stay tuned...
* This is a simple port and follows most of the manual build documentation which can be found in the [Debian](debian) section of this repository.

### Fedora
* Work in progress... Stay tuned...

## Notes About the Provided Images
As mentioned above, all of the images provided in this repository are configured to support USB networking on the Gumstix and host computer.  This makes accessing a Gumstix device via SSH over a usb network interface as easy as possible.  All of the images were built for and tested on a Gumstix Overo IronSTORM-P COM with a Thumbo USB daughterbaord.  The images should work on other Gumstix main & daughterbaords, but I have not tested them.

Here is information on the [Thumbo Board](https://store.gumstix.com/index.php/products/240/) 

![](https://d3iwea566ns1n1.cloudfront.net/images/product/PKG30021.overview.jpg)

Here is information on the [Gumstix IronSTORM-P COM](https://store.gumstix.com/index.php/products/622/) 

![](https://s3-us-west-2.amazonaws.com/media.gumstix.com/images/product/768dd9340e71427b43542e11d97a3271574d5764.jpeg)

