[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Gumstix Overo Kali Scripted Build
* The build script used here is based off the steps in the [Manual Build](build_manually.md) documentation.

### Download the Build Script
````
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/kali/kali_scripted_build.sh
````

### Run the Build Script
* NOTE: This scripted build assumes you have built the Yocto image with the director stucture outlined in the [Yocto Manual Build](../yocto/build_manually.md) docs.  If your Yocto image resides elsewhere, just change the directory variables KALI_DIR and YOCTO_DIR in the beginning of the script.
* This script should be run as root or with sudo since it requires admin privleges.
````
bash kali_scripted_build.sh
````

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
