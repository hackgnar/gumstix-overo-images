[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Gumstix Overo Debian Scripted Build
* The build script used here is based off the steps in the [Manual Build](build_manually.md) documentation.

### Download the Build Script
````
curl -O https://raw.githubusercontent.com/hackgnar/gumstix-overo-images/master/debian/debian_scripted_build.sh
````

### Run the Build Script
* Note this script assumes you are running as a normal user and will prompt you for the root password mutiple times as many of the commands are run with su.  You can alter the script to run with sudo if you like.  Future interations of this script will utilize sudo instead so the script can be run headless for nightly builds.  However, you can probably run the script as root and it will likely work.  I havent had time to test it.
* You may find it useful to alter my bash script if you want custom configurations on your OS like root password, different network addresses, different hostname, etc
````
bash debian_scripted_build.sh
````

### Install to SD Card
Documentation on installing this image can be found here:

* [Install Image to SD](install_image.md)
