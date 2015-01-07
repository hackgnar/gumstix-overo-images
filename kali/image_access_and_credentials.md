[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Recomended Method for Accessing Precompiled Images
* Plug in your Gumstix board which is attached to a daughter board with a usb device port (Tobi, Thumbo, etc) to your host computer.
* Once the Gumstix board finishes booting the OS you can ssh to it with username:root password:toor
````
ssh root@172.16.1.2
````

## Credentials and IP Addresses for the Kali Image
* The precomiled image (or images created with the build script) is setup with the password "toor" for the root user.
* The ipaddress for the Gumstix USB network interface is 172.16.1.2

## Accessing the Installed Kali Image
Here are the methods that you can use to access the image running on your Gumstix Board

* SSH to the usb network interface located at the address listed above.  The Kali image is configured to serve your host computer a DHCP address in the 172.16.1.0/24 block.
* SSH to the ethernet interface if you are using a daughter board with ethernet capabilities (Tobi, etc).  The eth0 interface will pull a DHCP address.
* SSH to the WiFi interface.  This will require that you setup your wpa supplicant file located at /etc/wpa_supplicatnt/wpa_supplicant.conf prior to flashing your SD card.
* NOTE: USB serial console support for the Kali image is not setup so you will not be able to log in via minicom, etc

