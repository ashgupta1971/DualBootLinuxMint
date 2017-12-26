# Setting Up a Dual-Boot Windows 10 and Linux Mint System
* * *

## Introduction

This document explains how to setup a dual-boot Windows 10
and Linux Mint system. It is split into two parts:
setting up a system with drive encryption and without
drive encryption.

Here are the assumptions about your system that this document
makes:

* The storage device being used is 1 TB in size.
* The storage device is a hard disk drive, not a SSD.
* The storage device is in MBR format (not GPT) and will be
kept that way.
* There may be an existing instance of Windows 10 installed 
along with data that needs to be preserved. If this is not the
case then the reader can omit the relevant sections.
* The data which needs to be preserved will be placed in separate
partitions (ie. for music, google drive data, etc.).
* You have Windows software with keys that need to be deactivated
before reinstalling Windows (eg. Norton Internet Security).
* There may be existing LVM metadata on the drive which needs to
be removed. Again, skip the relevant sections if this is not the case.
* The storage device will be completely erased and a 
fresh install of Windows 10 and Linux Mint will be performed.
* You have Oracle Virtualbox installed along with one or more virtual
machines which need to be preserved.
* Your primary day-to-day operating system will be Linux Mint
not Windows 10 (the space alloted to the two operating systems
reflects this assumption).
  
Also, it is assumed the reader has some knowledge of the following:

* Basic linux command line usage
* How to set up partitions using the linux *parted* disk utility
* How to make images of partitions using *Clonezilla* imaging utility.

It doesn't matter which version of Windows 10 
(32-bit, 64-bit, Home, Professional) or Linux Mint you plan 
on installing. 

Due to technical limitations, it is not possible to encrypt both Windows 10
and Linux Mint. This document only describes the procedure for an unencrypted
Windows 10 partition and an encrypted Linux Mint partition. Also, partitions
containing data (music, Google drive, etc.) must be kept unencrypted as well
in order to be accessible from both Windows 10 and Linux Mint.

This document also shows how to install several useful applications and
utilities under Windows 10 and Linux Mint. The reader can skip those that are
not of interest.

## Preliminary Steps

The initial steps which need to be performed are the same for both procedures:

1. Download Windows 10 ISO file and burn it to a USB flash drive.
1. Download any drivers needed for new Windows 10 installation and save them on USB flash drive.
1. Download Linux Mint ISO file, verify checksum and burn ISO to a USB flash drive.
1. Backup existing data to an external drive.
1. Deactivate any Windows software that has product keys (such as Norton Internet Security or Microsoft Office).
1. Wipe LVM data and partition tables on storage device.
1. Create New Partitions on Storage Device.

### Download Windows 10 ISO File and Burn it to a USB Flash Drive

Download the [Windows 10 ISO file](https://www.microsoft.com/en-us/software-download/windows10ISO "Windows 10 ISO").

Burn it to a USB flash drive from the command line as follows:

        $ sudo mkfs.vfat -n "Windows10" -I /dev/sd<drive identifier>
        $ sudo dd status=progress bs=1M if=<path to Windows 10 ISO file> of=/dev/sd<drive identifier>

Note that the `dd` command may appear to freeze for several minutes. This
is normal and just wait for it to finish.

### Download Windows 10 Drivers

Download the following drivers from the manufacturers' websites:

* chipset
* LAN
* audio
* USB 3
* graphics card
* Intel RST (Rapid Storage Technology) drivers (if you are using RAID or an SSD/M.2 drive)

Copy them in a folder on the same USB drive containing the Windows 10 ISO.

### Download, Verify and Burn Linux Mint ISO File

Download the [Linux Mint ISO file](https://www.linuxmint.com/download.php "Linux Mint ISO Download") of your choice.
Also download the *sha256 checksum text file*, its associated *signature file* and make a note of the *fingerprint* for
the *public GPG Linux Mint key*. Verify the ISO image using the following commands (these must be run inside the directory
containing the Linux Mint ISO file):

        $ sha256sum --ignore-missing -c <sha256 checksum text file>
        $ gpg --recv-key <linux mint public key fingerprint> --keyserver keyserver.ubuntu.com
        $ gpg --verify <signature file> <sha256 checksum text file>

Burn the ISO file to a USB flash drive as follows:

        $ sudo mkfs.vfat -n "LinuxMint" -I /dev/sd<drive identifier>
        $ sudo dd status=progress bs=1M if=<path to Linux Mint ISO file> of=/dev/sd<drive identifier>

### Backup Data to Storage Device

Either from a live Linux Mint environment or your existing Windows 10 environment, 
backup the following items to your external storage device:

* *Downloads* folder
* *Documents* folder
* *Music* folder
* *Google Drive* folder
* any folders in the *Data* partition
* the *johndoe.kdbx* password file
* export all Oracle Virtualbox VMs as appliances to an external drive

### Deactivate Windows Software

Products such as Norton Internet Security need to be deactivated before reinstalling
Windows. Otherwise, when you reinstall this software, its install "count" will increase
by one even though you have not installed it on a new device.

### Wipe LVMs and Partitions on Storage Device

Perform the following steps from a Linux Mint live environment.
First look for any logical volumes on the storage device with the following command:

        $ sudo lvs

For each logical volume, issue the command:

        $ sudo lvremove --verbose <lvname>

After all logical volumes have been removed, remove all volume groups. To
list all volume groups, issue the command:

        $ sudo vgs

For each volume group, issue the command:

        $ sudo vgremove --verbose <vgname>

After all volume groups have been removed, remove all physical volumes. To
list all physical volumes, issue the command:

        $ sudo pvs

For each physical volume, issue the command:

        $ sudo pvremove --verbose <pvname>

Now wipe all partition information from the storage device using 'parted':

        $ sudo parted /dev/sd<device identifier>

### Create New Partitions on Storage Device

Create the following partitions on the storage device using 'parted', again
from a Linux Mint live environment (use a partition type of "7" for NTFS partitions):

1. a 100 GiB *Windows 10* primary partition formatted as *NTFS*
1. a 450 GiB *Linux Mint* unformatted, logical partition. 
**NOTE: if you are going to encrypt the Linux Mint environment, then this partition
must be created with OPTIMAL alignment. (Use the *parted* arguments "--align optimal".)**
1. a 25 GiB *Shared Documents* logical partition formatted as *NTFS*
1. a 25 GiB *Music* logical partition formatted as *NTFS*
1. a 25 GiB *Google Drive* logical partition formatted as *NTFS*
1. a 10 GiB *Ebooks* logical partition formatted as *NTFS*
1. a 50 GiB *Windows Virtual Machines* logical partition formatted as *NTFS*
1. a 200 GiB *Data* logical partition formatted as *NTFS*

This will leave approximately 50 GB of empty space on the storage
device for future use.

To format partitions with the NTFS file system, use the command:

        $ sudo mkfs -t ntfs -f -L <partition label> /dev/sd<drive identifier><partition identifier>

## Install Windows 10 (Unencrypted)

Follow the instructions on this [page](https://ashgupta1971.github.io/DualBootLinuxMint/install-win10.html "Install and Configure Windows 10")
to install and configure Windows 10.

## Install Linux Mint (Unencrypted)

Now that Windows 10 has been installed, we can install Linux Mint as described
[here](https://ashgupta1971.github.io/DualBootLinuxMint/WithoutEncryption/dual-boot-without-encryption.html "Dual-Boot Without Encryption").

## Install Linux Mint (Encrypted)

To finish setting up the system, setup an encrypted Linux Mint partition as described
[here](https://ashgupta1971.github.io/DualBootLinuxMint/WithEncryption/dual-boot-with-encryption.html "Dual-Boot With Encryption").

## Make Separate Images of the Windows 10 and Linux Mint Partitions

Boot from a USB flash drive containing Clonezilla and use it to make
an image of the 100 GiB Windows 10 partition to an external hard drive.

Do the same for the Linux Mint partition.

*Note: Do not make images of the Google Drive, Music, Ebooks, Data,
 Shared Documents or Virtual Machine partitions.*

## Restore Data from Backups

The following steps can be done from either your new Windows 10 or Linux Mint environments:

1. Restore all music to the folder *C:\Users\johndoe\Music*.
1. Restore all ebooks to the folder *C:\Users\johndoe\Ebooks*.
1. Download all files from *johndoe's* Google Drive account into the folder *C:\Users\johndoe\Google Drive*.
1. Restore the contents of the *Data* partition.
1. Copy the *johndoe.kdbx* password file back to the folder *C:\Users\johndoe\Shared Documents*.

***

# Congratulations! You have successfully setup a dual boot Windows 10/Linux Mint system.
