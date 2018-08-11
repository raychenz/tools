#!/bin/bash

#set -x
#set -o functrace


cd ~ 
echo Checking virgil-build/ exists or not...
if [ -d "virgil-build/" ]; then
    # Check floder exist
    echo "Directory virgil-build/ exists, detete it for clearning build and Cloneing virgil-build"
    sudo rm -rf virgil-build/
else
    echo "Directory does not exists, Cloneing virgil-build/"
fi

#echo Checking armbuild/ exists or not...
#if [ -d "virgil-build/armbuild/" ]; then
    # Check floder exist
#    echo "Directory armbuild/ exists, detete it for clearning build and Cloneing armbuild"
#    sudo rm -rf virgil-build/armbuild/
#else
#    echo "Directory does not exists, moving to next steps"
#fi
echo Clone the livecd-rootfs branch...
git clone lp:~virgil-team/virgil/+git/virgil-build
cd virgil-build
git clone https://github.com/Lyoncore/oem-livecd-rootfs.git -b oem-xenial-base oem-livecd-rootfs | tee ~/desktop-arm64.log 2>&1


#====Desktop arm64====

echo ===Starting Desktop Image build arm64...===
echo Get the project configs branch...
cd oem-livecd-rootfs/live-build
mv ubuntu ubuntu.ori
git clone lp:~virgil-team/virgil/+git/virgil-ubuntu-desktop ubuntu | tee -a ~/desktop-arm64.log  2>&1

echo Copy livecd-rootfs config...
cd ../..
mkdir armbuild
cp -a ./oem-livecd-rootfs/live-build/auto ./armbuild

echo Configure according to snapdragon...
cd armbuild
LB_BOOTSTRAP_INCLUDE="apt-transport-https gnupg" OEM_PROJECT_ROOT=../oem-livecd-rootfs SUITE=bionic ARCH=arm64 PROJECT=ubuntu SUBPROJECT=system-image SUBARCH=snapdragon lb config --apt-secure false --apt-source-archives false --bootstrap-flavour minimal --cache-stages false --distribution bionic --mode ubuntu --security false --binary-images none --chroot-filesystem ext4 --hdd-label base-rootfs --initramfs none --system normal --architectures arm64 --bootstrap-qemu-arch arm64 --bootstrap-qemu-static /usr/bin/qemu-aarch64-static --firmware-binary false --firmware-chroot false --linux-flavours snapdragon --mirror-bootstrap "http://ports.ubuntu.com/ubuntu-ports/" --mirror-binary "http://ports.ubuntu.com/ubuntu-ports/" --parent-mirror-bootstrap "http://ports.ubuntu.com/ubuntu-ports/" --parent-mirror-binary "http://ports.ubuntu.com/ubuntu-ports/" --archive-areas "main restricted universe multiverse" | tee -a ~/desktop-arm64.log 2>&1 

echo Building the image...
mkdir chroot
time sudo LB_BOOTSTRAP_INCLUDE="apt-transport-https gnupg" SUITE=bionic ARCH=arm64 PROJECT=ubuntu SUBPROJECT=system-image SUBARCH=snapdragon lb build | tee -a ~/desktop-arm64.log  2>&1
../ext2tar.sh desktop livecd.ubuntu-snapdragon.ext4 arm64 | tee -a ~/desktop-arm64.log  2>&1
 cp ../arm64img.sh . 
 cp ../uboot.env.in .
sudo ./arm64img.sh virgil-ubuntu-arm64-rootfs.tar.bz2 5120  | tee -a ~/desktop-arm64.log  2>&1
mv dragonboard.img livecd.ubuntu-dragonboard.img 