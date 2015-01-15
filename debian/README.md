[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

## Build the Gumstix Overo Debian Image
Choose one of the three methods below to build your base image for the Gumstix Overo board.

1. [Manual Build](build_manually.md) - This method is the most advanced and takes the longest but it allows for the most image customization.
2. [Scripted Build](build_scripted.md) - This method wraps all of the steps of the manual build into a script which allows for a faster build process.  Customizations can be made to the base image by editing the build script.
3. [Precompiled Image Build](build_precompiled_image.md) - This method is by far the fastest and easiest.  Simply download a prebuilt image which can then be installed to an SD card.

## Install Your Debian Image
* [Install Image to SD Card](install_image.md) - Once you have your image from one of the above build methods, this documentation will explain how to prepare an SD card for the Gumstix Overo board.

## Credentials and Access Notes for Precompiled images
* [How to Access your Image](image_access_and_credentials.md) - If you are using the precompiled image or an unmodifed build script to create your image, look here for help on accessing and logging into your system.

## Accessing Your Installed Image
* [Accessing Your Image](image_access_and_credentials.md) - How to access your Gumstix device after installing an OS image.

## Notes about this Debian Image
The build notes and images here are for a stock Debian Wheezy OS configured for a Gumstix Overo device.  The Debian image is configured for easy access when the Gumstix device is plugged into a host computer via USB.
