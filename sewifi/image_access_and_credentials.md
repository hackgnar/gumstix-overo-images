[![Follow Hackgnar](../static/twitter_hackgnar.png)](https://twitter.com/hackgnar)

[< Back](README.md)

## Recomended Method for Accessing Precompiled Images
* Plug in your Gumstix board which is attached to a daughter board with a usb device port (Tobi, Thumbo, etc) to your host computer.
* Once the Gumstix board finishes booting the OS you can ssh to it with username:root password:hackgnar
````
ssh root@172.16.1.2
````

## Credentials and IP Addresses for the SEWiFi Image
* The precomiled image (or images created with the build script) is setup with the password "hackgnar" for the root user.
* The ipaddress for the Gumstix USB network interface is 172.16.1.2

## Accessing the Installed SEWiFi Image
Here are the methods that you can use to access the image running on your Gumstix Board

* SSH to the usb network interface located at the address listed above.  The SEWiFi image is configured to serve your host computer a DHCP address in the 172.16.1.0/24 block.
* NOTE: USB serial console support for the SEWiFi image is not setup so you will not be able to log in via minicom, etc
* NOTE: SSH access to the Gumstix WiFi or Ethernet interfaces are blocked by the firewall.

