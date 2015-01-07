[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

## Build the Gumstix Overo Yocto Image
Choose one of the three methods below to build your base image for the Gumstix Overo board.

1. [Manual Build](build_manually.md) - This method is the most advanced and takes the longest but it allows for the most image customization.
2. [Scripted Build](build_scripted.md) - This method wraps all of the steps of the manual build into a script which allows for a faster build process.  Customizations can be made to the base image by editing the build script.
3. [Precompiled Image Build](build_precompiled_image.md) - This method is by far the fastest and easiest.  Simply download a prebuilt image which can then be installed to an SD card.

## Install your Yocto Image
* [Install Image to SD Card](install_image.md) - Once you have your image from one of the above build methods, this documentation will explain how to prepare an SD card for the Gumstix Overo board.

## Notes About Building Yocto for the Gumstix Overo

This writeup goes over some basics on how to build and install a Yocto Linux image for an Overo Gumstix board.  The Yocto build described in this document can be directly installed on a Gumstix board or you can utilize the kernel, modules and firmeware it creates to constuct other Linux distributions (Debian, Kali, Ubuntu, Fedora, etc) for your Gumstix board.

Here is a short summary of what this writeup covers:

1.  Where to download Yocto images if you are not interested in building them yourself.
2.  How to manualy build and compile a Yocto image for a Gumstix Overo.
3.  A quick alternative way to build a Gumstix Yocto image.
4.  How to install a Linux image to an SD card for your Gumstix board.


### Overview
The Yocto Project is a framework for buidling custom Linux distributions for embeded systems.  As I come from a Linux background, I like to think of Yocto as the Gentoo for ARM systems.  These custom Linux distributions are typicaly stripped down to the bare necessities and configured to run as efficiant as possible on the target hardware.  Hardware vendors that create ARM devices capable of supporting Linux typicaly recomend Yocto builds and provide full Yocto configurations for thier hardware.  These Yocto configurations provided by hardware vendors typical include kerel configurations, kernel modules, kernel firmeare and base system packages.

Gumstix provides a few different Yocto configuations for building different Linux images.  This documentation focuses on building the Gumstix Yocto console (command line only) image but the process for building thier other imgages (such as the desktop XFCE image) is relatively similar.

 Another extreamly helpful use for vendor supplied Yocto builds and configurations is using the kernel, modules and firmware produced by thier Yocto builds with other Linux distributions.  If you are reading this article because of my work on the SEWiFi project, this is something I take advantage of in the project.  The Gumstix Yocto uBoot files, kernel, modules and firmwarefiles are used to create a functioning Debian ARM distribution for the Gumstix Overo.  The follow up to this documentation will show how to use these Yocto files to run a Debian OS on the Gumstix Overo board.  Alternatively, these files can also be use to create other operating systems other than Debian. 

 There are two methods to obtain a Yocto build for the Gumstix Overo.  The first method is to download a pre compiled build directly from Gumstix.  The second method is to build it yourself.  The majority of this documentation focusus on manualy building the Gumstix Overo Yocto build manualy which has added benifits such as cusomization or adding additional binary packages to your base image.  I have also composed a bash file which scripts the manual build process which is refrenced and explained at the end of this documentation.

 Finaly, if you are interested in installing the Yocto Linux build on your Gumstix Overo board, I will briefly cover this process as well.  Instalation of the Yocto image is not necissary if you are looking to use the Yocto kernel, modules and firmware to build a Debian (or other OS) image for your Gumstix board.  However, the Yocto image installation is almost identical to installing a Debian OS (which I will cover in future documentation), so you make find it useful to review. 


