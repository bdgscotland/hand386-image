#!/bin/bash
#set -x
set -e

#brew install qemu


# Check if required files/directories exist
if [ ! -d "working" ]; then
    mkdir working
fi

if [ ! -f "dos622_boot.img" ]; then
    echo "Error: dos622_boot.img not found."
    exit 1
fi

for i in {1..3}
do
    if [ ! -f "software/dos622/Disk${i}.img" ]; then
        echo "Error: Disk${i}.img not found."
        exit 1
    fi
done

### CREATE IMAGE

echo "Creating Image..."
dd if=/dev/zero of=working/dos622.img bs=512k count=2048

### FORMAT IMAGE
echo "Formatting Image..."

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


# Check if image creation was successful
if [ ! -f "working/dos622.img" ]; then
    echo "Error: Failed to create dos622.img."
    exit 1
fi

echo "Copying and Cleaning Up..."
cp working/dos622.img hand386_v0.img
cp working/dos622.img hand386_dos622.img
rm working/dos622.img

### Install DOS 6.22

echo "Installing DOS 6.22..."

{
    sleep 5;            # Wait for DOS installation to start
    echo "sendkey ret"; # Press Enter
    sleep 1;            # Wait a second

    echo "sendkey down";# Press Down arrow key
    sleep 1;            # Wait a second

    echo "sendkey ret"; # Press Enter
    sleep 1;            # Wait a second

    echo "sendkey ret"; # Press Enter again
    sleep 1;            # Wait a second

    echo "sendkey ret";  # Press Enter yet again
    sleep 10;            # Assume a wait time for Disk1 to finish its operations

    echo "eject -f floppy0";  # Eject Disk1.img
    echo "change floppy0 software/dos622/Disk2.img"; # Insert Disk2.img

    echo "sendkey ret";  # Press Enter yet again
    sleep 10;            # Assume a wait time for Disk2 to finish its operations

    echo "eject -f floppy0";  # Eject Disk2.img
    echo "change floppy0 software/dos622/Disk3.img"; # Insert Disk3.img

    echo "sendkey ret";  # Press Enter yet again
    sleep 10;            # Assume a wait time for Disk3 to finish its operations

    echo "eject -f floppy0";  # Eject Disk3.img
    echo "sendkey ret";  # Press Enter yet again
    echo "sendkey ret";  # Press Enter yet again

    # Add more waits or key presses as necessary for Disk2 operations.
    echo "quit";
} | qemu-system-i386 -fda software/dos622/Disk1.img -hda hand386_v0.img -boot a -monitor stdio

echo "DOS 6.22 Installation Complete."

### Install Windows 3.11
echo "Installing Windows 3.11..."

### Install Windows 3.11

{
    sleep 5;               # Wait a bit before starting commands

    echo "sendkey a";          # Press 'a'
    echo "sendkey shift-semicolon"; # Press ':'
    echo "sendkey ret";        # Press Enter
    sleep 2;               # Assume a small wait

    # Start typing 'setup'
    echo "sendkey s";
    echo "sendkey e";
    echo "sendkey t";
    echo "sendkey u";
    echo "sendkey p";
    echo "sendkey ret";        # Press Enter to execute `setup`
    sleep 10;              # Assume a wait time for setup to initialize

    echo "sendkey ret";        # Press Enter
    echo "sendkey ret";        # Press Enter
    sleep 5;               # Some wait time
    
    echo "eject -f floppy0";   # Eject current floppy image
    echo "change floppy0 software/win311/DISK2.IMG";   # Insert DISK2
    sleep 5;              # Wait a bit
    echo "sendkey ret";        # Press Enter
    sleep 10;              # Wait a bit

    echo "eject -f floppy0";   # Eject DISK2
    echo "change floppy0 software/win311/DISK3.IMG";   # Insert DISK3    
    sleep 5;              # Wait a bit
    echo "sendkey ret";        # Press Enter
    sleep 10;              # Wait a bit
    
    # Start typing 'hand386'
    echo "sendkey h";
    echo "sendkey a";
    echo "sendkey n";
    echo "sendkey d";
    echo "sendkey 3";
    echo "sendkey 8";
    echo "sendkey 6";
    echo "sendkey ret";        # Press Enter to finalize the input
    sleep 5;               # Some wait time

    echo "sendkey ret";        # Press Enter
    echo "sendkey ret";        # Press Enter
    sleep 15;
    
    echo "eject -f floppy0";   # Eject current floppy image
    echo "change floppy0 software/win311/DISK4.IMG";   # Insert DISK4
                      # Wait a bit    
    echo "sendkey ret";        # Press Enter
    sleep 15;              # Wait a bit
    

    echo "eject -f floppy0";   # Eject DISK4
    echo "change floppy0 software/win311/DISK5.IMG";   # Insert DISK5
    echo "sendkey ret";        # Press Enter
    sleep 15;              # Wait a bit

    echo "sendkey ret";        # Press Enter
    echo "sendkey alt-s";      # Press Alt+S (This command might depend on the specific configuration)
    echo "sendkey ret";        # Press Enter

    sleep 15;              # Wait a bit
    echo "quit";           # Quit QEMU

} | qemu-system-i386 -fda software/win311/DISK1.IMG -hda hand386_v0.img -boot c -monitor stdio


# Test Boot
#qemu-system-i386 -fda software/win311/DISK1.IMG -hda hand386_v0.img -boot c -monitor stdio

