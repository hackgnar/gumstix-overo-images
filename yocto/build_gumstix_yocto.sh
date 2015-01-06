#!/bin/bash

YOCTO_SRC=~/source/gumstix/yocto

/bin/su -c "apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath libsdl1.2-dev xterm curl"

mkdir -p $YOCTO_SRC
cd $YOCTO_SRC

if [[ $1 && -f $1 ]]; then
    cp $1 .
else
    curl -O http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
fi

chmod a+x repo
/bin/su -c "mv repo /usr/local/bin"

# possibly set up git name and email to avoid warnings
# when you dont set up git name and email you are definately prompted multiple times during the next step
repo init -u git://github.com/gumstix/Gumstix-YoctoProject-Repo.git
repo sync

export TEMPLATECONF=meta-gumstix-extras/conf
source ./poky/oe-init-build-env

#export PARALLEL_MAKE="-j 8"
bitbake -c fetchall gumstix-console-image
bitbake gumstix-console-image
