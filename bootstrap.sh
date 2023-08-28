#!/bin/bash
set -x
#brew install qemu

### CREATE IMAGE

dd if=/dev/zero of=working/dos622.img bs=1m count=1024
#device=$(hdiutil attach -nomount working/dos622.img)
#sudo newfs_msdos -F 16 $device
#hdiutil detach $device

### FORMAT IMAGE

{
    sleep 10;            # wait for DOS to boot
    echo "sendkey f";    # 'f'
    echo "sendkey d";    # 'd'
    echo "sendkey i";    # 'i'
    echo "sendkey s";    # 's'
    echo "sendkey k";    # 'k'
    echo "sendkey ret";  # Enter to execute `fdisk`
    sleep 2;             # wait for `fdisk` to load
    
    echo "sendkey 1";    # option to create a DOS partition
    echo "sendkey ret";  # Enter
    sleep 1;
    
    echo "sendkey 1";    # option to create a primary DOS partition
    echo "sendkey ret";  # Enter
    sleep 2;
    
    echo "sendkey y";    # confirm the creation
    echo "sendkey ret";  # Enter
    sleep 1;
    echo "sendkey ret";  # Enter

    sleep 10;            # wait for DOS to boot

    echo "sendkey f";    # Start typing 'format C: /S'
    echo "sendkey o";
    echo "sendkey r";
    echo "sendkey m";
    echo "sendkey a";
    echo "sendkey t";
    echo "sendkey spc";   # Spacebar
    echo "sendkey c";
    echo "sendkey shift-semicolon"; # Represents the ':' character
    echo "sendkey spc";   # Spacebar
    echo "sendkey slash";     # Forward slash for the /S switch
    echo "sendkey s";
    echo "sendkey ret";  # Enter to execute format command with /S switch

    sleep 2;             # Wait for the format prompt

    echo "sendkey y";    # 'y' to confirm formatting
    echo "sendkey ret";  # Enter

    sleep 10;            # Wait for the format to finish

    echo "sendkey h";    # Start typing 'hand386'
    echo "sendkey a";
    echo "sendkey n";
    echo "sendkey d";
    echo "sendkey 3";
    echo "sendkey 8";
    echo "sendkey 6";
    echo "sendkey ret";  # Enter to set volume label    

    sleep 10;

    echo "quit";         # quit QEMU
} | qemu-system-i386 -fda dos622_boot.img -hda working/dos622.img -boot a -monitor stdio

### Dev - Delete image
cp working/dos622.img hand386_v0.img
rm working/dos622.img


### REBOOT AND PRESS ENTER TWICE

{
    sleep 5;             # Wait a bit for QEMU to fully boot up
    echo "sendkey ret";  # Press Enter
    sleep 1;             # Wait a second
    echo "sendkey ret";  # Press Enter again
    sleep 10;            # Allow some time if needed
    echo "quit";         # quit QEMU
} | qemu-system-i386 -hda hand386_v0.img -boot c -monitor stdio
