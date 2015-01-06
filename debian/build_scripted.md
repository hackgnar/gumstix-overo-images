[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Gumstix Overo Debian Scripted Build
* The build script used here is based off the steps in the [Manual Build](build_manually.md) documentation.

### Download the Build Script
````
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/debian_scripted_build.sh
````

### Run the Build Script
* The script should not be run as root.  Note however that you will be asked for the root password multiple times during the build process since the script utilizes the su command.
````
bash debian_scripted_build.sh
````

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
