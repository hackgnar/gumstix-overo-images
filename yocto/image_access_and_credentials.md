[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

**NOTE:** there is no simple way to access a stock Yocto image via a networked USB interface.  In the future, Ill add configuration steps to the [Build Yocto Manualy](build_manually.md) documentation.  I will also update the stock image provided in this repository to hace network access via USB by default.

## Recomended Method for Accessing Precompiled Images
* Access your Gumstix device via the USB console using a daughterboard such as the Tobi or Janus with minicom

## Credentials and IP Addresses for the Yocto Image
* The stock Yocto image has no password for the root user so you can simply log in via the USB console
* You may also SSH in if you are using a daughterboard with an ethernet adapter.

## Accessing the Installed Yocto Image
Here are the methods that you can use to access the image running on your Gumstix Board

* SSH to the ethernet interface if you are using a daughter board with ethernet capabilities (Tobi, etc).  The eth0 interface will pull a DHCP address.
* You may also alter the /etc/network/interfaces file before flashing your SD card.  If you are doing this, you can set network interface usb0 to a static IP address so you can ssh to it.  Note however, your base system will not pull a DHCP address unless you set up a DHCP service on the base OS.  Here is an example of how you could access your system via USB if you include usb0 with a static ip in your network interfaces file.

````
# assume you set usb0 to static IP 172.16.1.2
# after your Gumstix which is connected via usb boots up, run this on your host computer
ifconfig eth0 172.16.1.3
ssh root@172.16.1.2
````
