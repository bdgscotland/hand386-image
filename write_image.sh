#!/bin/bash

# Enable tracing of commands
set -x

# Path to your image file
IMAGE_PATH="hand386_v0.img"

# Check if the image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Image file $IMAGE_PATH does not exist!"
    exit 1
fi

# Identify the CF card's device name with the label "HAND386"
CF_DEVICE=$(diskutil list | grep "HAND386" | awk '{print $NF}' | sed 's/s[0-9]*$//')

if [ -z "$CF_DEVICE" ]; then
    echo "No CF card named HAND386 found!"
    exit 1
fi

# Confirm with the user
read -p "About to write to $CF_DEVICE. Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Unmount the CF card
diskutil unmountDisk "$CF_DEVICE"

# Write the image to the CF card
sudo dd if="$IMAGE_PATH" of=/dev/r${CF_DEVICE##/dev/} bs=512k
sudo sync

# Eject the CF card
diskutil eject "$CF_DEVICE"

# Display the partitions on the CF card
echo "Listing partitions on $CF_DEVICE:"
diskutil list "$CF_DEVICE"

echo "Done!"