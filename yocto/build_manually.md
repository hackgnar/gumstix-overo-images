[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Manually Building a Gumstix Overo Yocto Image
* If you decided to not to Download the pre-built Yocto images and want to build it youself from scratch, this section describes the process in detail.  Manualy building the Yocto system has many benifits such as base image customizations and the ability to add your own packages.  I am not going to cover customization or package addition via bitbake (bitbake is very similar to Gentoo's ebuild package management system) here.  However, if you are interested in adding your own packages to the base system via bitbake, I will cover that process in a future post.  The process takes some time to complete but consecutive builds can be done much faster. Most of this is derived from the docs found [here](https://github.com/gumstix/Gumstix-YoctoProject-Repo)
* Also note, that if you want to build the Yocto system but dont want to manualy type in all of the following commands, I provide a bash script which automaticly runs all of these commands which is covered in the following section.

* Finaly, this manual build process was tested on a minumal install Debian 7.7 system.  I also successfuly tested the build on Kali Linux 1.0.9 but it will likely also build on past revisions. 

### Download the required packages for building 
* These packages are needed to build our base Yocto image
```
sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath libsdl1.2-dev xterm curl
```

### Create a build directory and go there
* I like to create a directory stucture to house my source code and projects.  You do not have to abide by my directory stucture, but keep in mind that I will refrence these directories thoughout this and future documentation.
```
mkdir -p ~/source/gumstix/yocto
cd ~/source/gumstix/yocto
```

### Download the repo command and add it to your system
* In order to download the Yocto configurations for the project, we must first install the repo command.  In short, repo is basicly a wrapper around git which provides a simple way to bundle a bunch of different git repositories into one project.
* If you are interested in learning more about the repo command, this link is a good start http://xda-university.com/as-a-developer/repo-tips-tricks
```
curl -O http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo mv repo /usr/local/bin
```

### Initialize your yocto repo project
* Now that repo is installed, we are going to download all of the Yocto configs for our project.  The init command will take some time as it downloads all of the git repositories associated with the project.  The sync command is used to make sure all of your repos are up to date and is useful for updateing your Yocto configs if you do a build at a later date.
```
repo init -u git://github.com/gumstix/Gumstix-YoctoProject-Repo.git
repo sync
```

### Change into your yocto build environment
* Now that we have our base Yocto configs, we are going to enter our build environment.  If for some reason, you exit your bash shell before finishing your Yocto build, you will need to execute this command each time before being able to run all of the consecutive steps.  Keep in mind that this also applies to doing builds at a future date.
```
export TEMPLATECONF=meta-gumstix-extras/conf
source ./poky/oe-init-build-env
```

### Build with bitbake
* Yocto projects utilize bitbake in order to compile your Yocto Linux image.  Bitbake basicly just compiles your base OS, kernel, modules and all of the packages included in your target Linux OS.  A Yocto project contains a bunch of recipies (files with the extention bb) which define how each package gets downloaded and compiled.  Bitbake recipies are extreamly similar to Gentoo ebuild files.  If you are intrested in adding extra or custom applications to your base Yocto Linux OS you can add and link bitbake recipies to the Gumstix console image.  I will not cover adding and customizing bitbake here but it is something I plan to cover in future documentation.

* (Optional) If you are familair with compiling via make, you can speed up the following compile process by telling bitbake to compile with more threads.  This step is not needed but if you are compiling on a system with a high end CPU with many cores, this will speed up your compile time.  Keep in mind that the rule of thumb here is you should not specify a -j value greater than the amount of CPU cores present on your build machine.
```
export PARALLEL_MAKE="-j 8"
```

* (Optional) Before we kick off the build, I typicaly find it useful to download all of the build sources first incase I lose network connectivity.  As a Yocto build can take a few hours, I find this extreamly useful if I am goint to be doing a build on my laptop.
```
bitbake -c fetchall gumstix-console-image
```

* Now to build build the Yocto image.  Depending on the speed of your computer and how many threads you specified to build with, this step can take a few hours to complete.  When the build complets, you can use the image it creates in ~/source/gumstix/yocto/build/tmp/deploy/images/overo/ to either install the Yocto system or use the kernel, modules, firmware contained in the gumstix-console-image-overo-XXXXXXXXXXXXX.rootfs.tar.bz2 file to build a Debian (or other OS) Gumstix image.
```
bitbake gumstix-console-image
```

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
