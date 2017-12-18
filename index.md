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
* The storage device is in MBR format (not UEFI) and will be
kept that way.
* There may be an existing instance of Windows 10 installed 
along with data that needs to be preserved. If this is not the
case then the reader can omit the relevant sections.
* The data which needs to be preserved will be placed in separate
partitions (ie. for music, google drive data, etc.).
* You have Norton Security installed and this product needs to
be deactivated and reinstalled after the fresh install of Windows 10.
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
* How to set up partitions using the linux *fdisk* utility

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
1. Deactivate Norton Security on existing Windows installation.
1. Wipe LVM data and partition tables on storage device.
1. Create New Partitions on Storage Device.
1. Install and Configure Windows 10.

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

Backup the following items to your storage device:

* *Downloads* folder
* *Documents* folder
* *Music* folder
* *Google Drive* folder
* any folders in the *Data* partition
* the *johndoe.kdbx* password file
* export all Oracle Virtualbox VMs as appliances to an external drive

### Deactivate Norton Security

If you don't deactivate Norton Security before reinstalling Windows, 
your Norton online account will still assume you have an "instance" of 
their product activated and running. This will count against the total
number of "instances" of their product you can install.


### Wipe LVMs and Partitions on Storage Device

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

Now wipe all partition information from the storage device using fdisk:

        $ sudo fdisk /dev/sd<device identifier>

At the fdisk prompt type "o" to erase the MBR and then type "w" to write
all changes and exit the utility.

### Create New Partitions on Storage Device

Create the following partitions on the storage device using fdisk (use
a partition type of "7" for NTFS partitions):

1. a 100 GiB *Windows 10* primary partition formatted as *NTFS*
1. a 450 GiB *Linux Mint* unformatted, logical partition
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

### Install and Configure Windows 10

#### During Install

1. Insert the USB flash drive containing Windows 10 and boot from it.
1. Go through the installtion procedure.
1. Choose the *Windows 10* partition when prompted (this should be partition number 1). 
 *Note: Because we are telling Windows to install in a specific partition, it will not generate
a separate **System Reserved** partition. Instead, it will place all files in the partition we
have chosen.*
1. Make sure not to choose "Express Install" when prompted (this will enable various "snooping" options).
1.  When prompted for the first user account, choose the name *admin* but ensure it is created as a *local* account not a *One Drive* account.

#### After Install

1. Disconnect from the internet.
1. Install all the drivers previously downloaded, in the following order:
    * chipset
    * LAN
    * audio
    * USB 3
    * graphics card
1. Create a *local*, *non-adminstrator* account called *johndoe*.
1. Create a *visitor* account by running this [batch script](https://ashgupta1971.github.io/DualBootLinuxMint/Common/create-visitor-account.bat "Visitor account creation script")
 from an administrator command prompt. When the script prompts for a visitor password, just press <ENTER>.
1. Enable restore points on the C partition (Windows 10 disables them by default).
1. Windows 10, by default, assumes the hardware clock is in local time. Linux Mint, by default, assumes it is in UTC time. To reconcile
 this difference, we will perform a registry edit to tell Windows 10 that the hardware clock is in UTC time. Download the
 [registry edit](https://ashgupta1971.github.io/DualBootLinuxMint/Common/WinSetTimeStandard.reg "Registry Edit - Set Time to UTC") 
 and run it as administrator.
1. Delete the hidden file *C:\Users\johndoe\Music\desktop.ini* and map the *Music* partition to this folder.
1. Create a folder *C:\Users\johndoe\Google Drive* and map the *Google Drive* partition to it.
1. Create a folder *C:\Users\johndoe\Shared Documents* and map the *Shared Documents* partition to it.
1. Create a folder *C:\Users\johndoe\Ebooks* and map the *Ebooks* partition to it.
1. Create a folder *C:\Users\johndoe\VirtualBox VMs* and map the *Windows Virtual Machines* partition to it.
1. Set permissions for the *Data* partition so that only *admin* and *johndoe* can access it.
1. Connect to the internet, download and install *Norton Security* and all security updates.
1. Install all outstanding Windows 10 updates.
1. Download and install the driver and software for your printer.

#### Install Software

1. Visit [Ninite](https://ninite.com/ "Ninite") and download and install the following software.
 *Note: Keep the Ninite installer download. You can use it to update all these applications
in bulk later.*

    * Chrome
    * Opera
    * Firefox
    * TeamViewer 12
    * ImgBurn
    * CDBurnerXP
    * Revo
    * InfraRecorder
    * Skype
    * 7-zip
    * PeaZip
    * VLC
    * MusicBee
    * K-Lite Codecs
    * Spotify
    * CCCP
    * FileZilla
    * Notepad++
    * WinSCP
    * PuTTY
    * LibreOffice
    * Malwarebytes
    * KeePass 2

1. Download and install [*PDF-XChange Viewer*](https://www.tracker-software.com/product/pdf-xchange-viewer "PDF-XChange Viewer").
1. Download and install [*Oracle Virtualbox*](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html "Oracle Virtualbox").
1. Install [*gvim*](http://www.vim.org), download the 
[*vimrc* configuration file](https://github.com/ashgupta1971/dotfiles/blob/master/vim/.vimrc ".vimrc") and copy it to *C:\Users\johndoe\\_vimrc*.
1. Remove unnecessary programs from startup using Windows' *msconfig* utility.
1. Import all Oracle Virtualbox appliances previously exported.
1. Restore data to all data partitions (ie. music, google drive, etc.).
1. Configure the desktop as desired.
1. Calibrate the display using Windows' *calibrate* utility.

## Setting Up a Non-Encrypted Dual-Boot System

Now that Windows 10 has been installed, we can install Linux Mint as described
[here](https://ashgupta1971.github.io/DualBootLinuxMint/WithoutEncryption/dual-boot-without-encryption.html "Dual-Boot Without Encryption").

## Setting Up an Encrypted Dual-Boot System

To finish setting up the system, setup an encrypted Linux Mint partition as described
[here](https://ashgupta1971.github.io/DualBootLinuxMint/WithEncryption/dual-boot-with-encryption.html "Dual-Boot With Encryption").

## Make Separate Images of the Windows 10 and Linux Mint Partitions

Boot from a USB flash drive containing Clonezilla and use it to make
an image of the 100 GiB Windows 10 partition to an external hard drive.

Do the same for the Linux Mint partition.

*Note: Do not make images of the Google Drive, Music, Ebooks, Data,
 Shared Documents or Virtual Machine partitions.*

## Restore Data from Backups

1. Restore all music to the folder *C:\Users\johndoe\Music*.
1. Restore all ebooks to the folder *C:\Users\johndoe\Ebooks*.
1. Download all files from *johndoe's* Google Drive account into the folder *C:\Users\johndoe\Google Drive*.
1. Restore the contents of the *Data* partition.
1. Copy the *johndoe.kdbx* password file back to the folder *C:\Users\johndoe\Shared Documents*.

***

**Congratulations! You have successfully setup a dual boot Windows 10/Linux Mint system.**
