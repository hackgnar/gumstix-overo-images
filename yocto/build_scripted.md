[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Gumstix Overo Yocto Scripted Build
* The build script used here is based off the steps in the [Manual Build](build_manually.md) documentation.

* In order to speed up the Yocto Gumstix build process, I have composed a bash script from all of the manual build steps described above.  The script can be found [here](build_gumstix_yocto.sh).  This script was tested on a base Debian 7.7 and Kali Linux 1.0.9 system.  The script should be run as a non root user but it will propt you periodicly for a root password when it needs to run privilaged commands.  Because of this you should make sure that your root user has a password set.  The automated script provides very useful for building Yocto images on a clean system or of if you want to spin up a temperary EC2 instance for building.

### Download the Build Script
````
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/yocto/yocto_scripted_build.sh
````

### Run the Build Script
* The script should not be run as root.  Note however that you will be asked for the root password multiple times during the build process since the script utilizes the su command.
````
bash yocto_scripted_build.sh
````

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
