# Setting Up a Dual-Boot Windows 10 and Linux Mint System
* * *

## Introduction

This document explains how to setup a dual-boot Windows 10
and Linux Mint system from start to finish. 

Here are the assumptions about your system that this document
makes:

* The storage device being used is 1 TB in size.
* The storage device is a hard disk drive, not a SSD.
* The storage device will be completely erased and a 
fresh install of Windows 10 and Linux Mint will be performed.
* The storage device is in MBR format (not UEFI) and will be
kept that way.
* There may be an existing instance of Windows 10 installed 
along with data that needs to be preserved.
* The data which needs to be preserved will be placed in separate
partitions (ie. for music, google drive data, etc.).
* You have Norton Security installed and this product needs to
be deactivated and reinstalled after the fresh install of Windows 10.
* You have Oracle Virtualbox installed along with one or more virtual
machines which need to be preserved.
* Your primary day-to-day operating system will be Linux Mint
not Windows 10 (the space alloted to the two operating systems
reflects this assumption).
* Both the Windows 10 partition and Linux Mint partitions will be
left unencrypted.
  
It doesn't matter which version of Windows 10 
(32-bit, 64-bit, Home, Professional) or Linux Mint you plan 
on installing. 

This document also shows how to install several useful applications and
utilities under Windows 10 and Linux Mint. You can skip those that do not
interest you.

All the steps shown below assume you are working within a Linux Mint live
environment as root.

## Outline of Steps

1. Download Windows 10 ISO file and burn it to a USB flash drive.
1. Download any drivers needed for new Windows 10 installation and save them on USB flash drive.
1. Download Linux Mint ISO file, verify checksum and burn ISO to a USB flash drive.
1. Backup existing data to an external drive.
1. Deactivate Norton Security on existing Windows installation.
1. Wipe LVM data and partition tables on storage device.
1. Setup new partitions on storage device.
1. Install and configure Windows 10.
1. Install and configure Linux Mint.
1. Create an image of Windows 10 using Clonezilla.
1. Create an image of Linux Mint using Clonezilla.
1. Restore all data from backups.

## Download Windows 10 ISO File and Burn it to a USB Flash Drive

Download the [Windows 10 ISO file](https://www.microsoft.com/en-us/software-download/windows10ISO "Windows 10 ISO").

Burn it to a USB flash drive from the command line as follows:

        $ sudo mkfs.vfat -n "Windows10" -I /dev/sd<drive identifier>
        $ sudo dd status=progress bs=1M if=<path to Windows 10 ISO file> of=/dev/sd<drive identifier>

Note that the `dd` command may appear to freeze for several minutes. This
is normal and just wait for it to finish.

## Download Windows 10 Drivers

Download the following drivers from the manufacturers' websites:

* chipset
* LAN
* audio
* USB 3
* graphics card
* Intel RST (Rapid Storage Technology) drivers (if you are using RAID or an SSD/M.2 drive)

Copy them in a folder on the same USB drive containing the Windows 10 ISO.

## Download, Verify and Burn Linux Mint ISO File

Download the [Linux Mint ISO file](https://www.linuxmint.com/download.php "Linux Mint ISO Download") of your choice.
Also download the *sha256 checksum text file*, its associated *signature file* and make a note of the *fingerprint* for
the *public GPG Linux Mint key*. Verify the ISO image using the following commands:

        $ sha256sum --ignore-missing -c <Linux Mint ISO file>
        $ gpg --recv-key <linux mint public key fingerprint> --keyserver keyserver.ubuntu.com
        $ gpg --verify <signature file> <sha256 checksum text file>

Burn the ISO file to a USB flash drive as follows:

        $ sudo mkfs.vfat -n "LinuxMint" -I /dev/sd<drive identifier>
        $ sudo dd status=progress bs=1M if=<path to Linux Mint ISO file> of=/dev/sd<drive identifier>

## Backup Data From the Storage Device

Backup the following items from your storage device:

* *Downloads* folder
* *Documents* folder
* *Music* folder
* *Google Drive* folder
* any folders in the *Data* partition
* the *johndoe.kdbx* password file
* export all Oracle Virtualbox VMs as appliances to an external drive

## Deactivate Norton Security

If you don't deactivate Norton Security before reinstalling Windows, 
your Norton online account will still assume you have an "instance" of 
their product activated and running. This will count against the total
number of "instances" of their product you can install.


## Wipe LVMs and Partitions on Storage Device

First look for any logical volumes on the storage device with the following command:

        $ lvs

For each logical volume, issue the command:

        $ lvremove --verbose <lvname>

After all logical volumes have been removed, remove all volume groups. To
list all volume groups, issue the command:

        $ vgs

For each volume group, issue the command:

        $ vgremove --verbose <vgname>

After all volume groups have been removed, remove all physical volumes. To
list all physical volumes, issue the command:

        $ pvs

For each physical volume, issue the command:

        $ pvremove --verbose <pvname>

Now wipe all partition information from the storage device using fdisk:

        $ fdisk /dev/sd<device identifier>

At the fdisk prompt type "o" to erase the MBR and then type "w" to write
all changes and exit the utility.

## Create New Partitions on Storage Device

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

        $ sudo mkfs -t NTFS -f -L <partition label> /dev/sd<drive identifier><partition identifier>

## Install and Configure Windows 10

### During Install

1. Insert the USB flash drive containing Windows 10 and boot from it.
1. Go through the installtion procedure.
1. Choose the *Windows 10* partition when prompted (this should be partition number 1). 
 *Note: Because we are telling Windows to install in a specific partition, it will not generate
a separate **System Reserved** partition. Instead, it will place all files in the partition we
have chosen.*
1. Make sure not to choose "Express Install" when prompted (this will enable various "snooping" options).
1.  When prompted for the first user account, choose the name *admin* but ensure it is created as a *local* account not a *One Drive* account.

### After Install

1. Disconnect from the internet.
1. Install all the drivers previously downloaded, in the following order:
    * chipset
    * LAN
    * audio
    * USB 3
    * graphics card
1. Create a *local*, *non-adminstrator* account called *johndoe*.
1. Create a *visitor* account by running this [batch script](https://ashgupta1971.github.io/DualBootLinuxMint/create-visitor-account.bat "Visitor account creation script")
 from an administrator command prompt. When the script prompts for a visitor password, just press <ENTER>.
1. Enable restore points on the C partition (Windows 10 disables them by default).
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
1. Import all Oracle Virtualbox appliances previously exported.
1. Install [*gvim*](http://www.vim.org), download the 
[*vimrc* configuration file](../dotfiles/vim/.vimrc ".vimrc") and copy it to *C:\Users\johndoe\\_vimrc*.
1. Remove unnecessary programs from startup using Windows' *msconfig* utility.
1. Configure the desktop as desired.
1. Calibrate the display using Windows' *calibrate* utility.

## Install and Configure Linux Mint

### Prior to Running Linux Mint Installer

1. Insert and boot from the USB flash drive containing Linux Mint.
1. Open a terminal window.
1. Determine the numbers for the *Linut Mint* partition using the command:

        $ lsblk

1. Create a physical LVM volume from the *Linux Mint* partition using the command:

        $ sudo pvcreate -v /dev/sd<drive identifier><partition identifier>

1. Create a LVM volume group from the physical volume created above using the command:

        $ sudo vgcreate -v vg01 /dev/sd<drive identifier><partition identifier>

1. Create a 75 GiB *root* logical volume and format it as *ext4* using the commands:

        $ sudo lvcreate -v -L 75G -n root vg01
        $ sudo mkfs -t ext4 -L <partition label> /dev/vg01/root

1. Repeat the above commands to create the following logical volumes (format all as *ext4*):

    * a 500 MiB *boot* logical volume
    * a 70 GiB *home* logical volume
    * a 75 GiB *usr* logical volume
    * a 75 GiB *var* logical volume
    * a 150 GiB *VM* logical volume (this will contain all Oracle Virtualbox VMs)
    * a 5 GiB *swap* logical volume

### Run the Linux Mint Installer

Execute the following command to run the Linux Mint installer:
        
        $ sh -c "ubiquity -b gtk_ui"&

Go through the steps in the Linux Mint installer. When prompted to setup partitions,
select *something else* and map the logical volumes created above to their 
appropriate mount points.


### After Running Linux Mint Installer

1. After the Linux Mint installer has finished, we need to execute some commands in a
*chroot* environment. To prepare for this, execute the following commands:

        $ sudo mount /dev/vg01/root /mnt
        $ sudo mount /dev/vg01/boot /mnt/boot
        $ sudo mount /dev/vg01/home /mnt/home
        $ sudo mount /dev/vg01/usr /mnt/usr
        $ sudo mount /dev/vg01/var /mnt/var
        $ sudo mount --bind /dev /mnt/dev
        $ sudo mount --bind /dev/pts /mnt/dev/pts
        $ sudo mount --bind /sys /mnt/sys
        $ sudo mount --bind /proc /mnt/proc
        $ sudo mount --bind /run /mnt/run

1. Now enter the *chroot* enviroment by running:

        $ sudo chroot /mnt /bin/bash

1. Now execute the following commands to generate the locale and the initial ramdisk:

        $ sudo locale-gen --purge --no-archive
        $ sudo update-initramfs -u

1. Now we must setup the GRUB boot loader. First make a backup of the existing GRUB
configuration file:

        $ cd /etc/default
        $ sudo mv grub{,.bak}

1. Now download the new [GRUB configuration file](https://ashgupta1971.github.io/DualBootLinuxMint/grub "grub")
 and copy it to */etc/default/grub*.

1. Download the [GRUB background image](https://ashgupta1971.github.io/DualBootLinuxMint/grub_background.png "grub_background.png")
and copy it to */boot/grub/grub_background.png*.

1. Now install the GRUB boot loader:

        $ sudo grub-mkconfig -o /boot/grub.cfg
        $ sudo grub-install /dev/<drive identifier>

1. If the file */sbin/initctl.REAL* is present, execute the following commands:

        $ sudo mv /sbin/initctl /sbin/initctl.orig
        $ sudo mv /sbin/initctl.REAL /sbin/initctl

1. Finally, exit out of the *chroot* environment, unmount all the directories and reboot:

        $ exit
        $ sudo umount /mnt/sys /mnt/dev/pts /mnt/dev /mnt/run /mnt/proc 
        $ sudo umount /mnt/boot /mnt/home /mnt/usr /mnt/var /mnt
        $ reboot

### Fix GRUB Menu

After rebooting, you will be presented with the GRUB boot loader menu. There
will be entries to boot into the Windows 10 partition and Linux Mint partition.
Try selecting each entry to see what it does. (You will need to reboot to get back
into the GRUB boot loader menu after each selection.)

Now we will manually, edit the GRUB boot loader menu so that it appears more
presentable. First, make a backup copy of the GRUB files:

        $ sudo cp -R /etc/grub.d /etc/grub.d.original

Next, go into the GRUB boot loader directory and delete all unnecessary files:

        $ cd /etc/grub.d
        $ sudo rm 20* 30*

(You may have to look inside the files in this directory to see which files are
necessary and unnecessary.)

Open the file */boot/grub/grub.cfg* in a text editor as root, find
the lines that generate the GRUB boot loader menu text, copy them into the
file */etc/grub.d/40_custom*, edit them as desired and save this file.

Finally, regenerate the GRUB boot loader menu configuration file:

        $ sudo grub-mkconfig -o /boot/grub/grub.cfg

Reboot to see the new GRUB boot loader menu.

### Setup the fstab file

1. Login as *johndoe*.
1. Create directories in *johndoe's* home folder for Oracle Virtualbox and wallpapers:

        $ mkdir /home/johndoe/VirtualBox\ VMs
        $ mkdir /home/johndoe/Wallpaper

1. Make a backup of the existing */etc/fstab* file (this contains all the mount
points for the system):

        $ cd /etc
        $ sudo mv fstab{,.bak}

1. Download the new [*fstab* file](https://ashgupta1971.github.io/DualBootLinuxMint/fstab "fstab")
 and copy it to */etc/fstab*.
1. Setup all the mount points in the *fstab* file and mount them using the command (note that the
UUID numbers for your system will be different than the ones in this file):

        $ sudo mount -a

### Perform More Customizations

Watch the [Youtube video](https://youtu.be/RXV6FXVL6xI "15 Things To Do First in Linux Mint")
and perform any of the customizations mentioned.

### Install and Configure Remaining Linux Mint Packages

1. Perform any GUI customizations to *johndoe's* desktop that you wish.
1. Before installing the remaining packages, update the package database:
    
        $ sudo apt-get update

#### Download Configuration Files from git Repository

Execute the following command in *johndoe's* home directory:

        $ git clone https://github.com/ashgupta1971/dotfiles.git

#### Setup the Shell, Editor and File Browser

1. Install the Z Shell:

        $ sudo apt-get install zsh zsh-docs
        $ chsh -s /usr/bin/zsh johndoe

1. Download the Z Shell configuration file [*.zshrc*](.zshrc ".zshrc") into *johndoe's* home directory.

1. Install the *thunar* file browser and configure its settings as desired from its GUI.

        $ sudo apt-get install thunar

1. Now install `gvim`:

        $ sudo apt-get install vim-gtk

1. Get the vim configuration file [*.vimrc*](vimrc ".vimrc") and copy it to *johndoe's* home directory.

#### Setup the Music Player

1. Install the *Music Player Daemon*:

        $ sudo apt-get install mpd mpc

1. Configure the Music Player Daemon by first creating its working 
and playlist directories:

        $ mkdir -p ~/.config/mpd/playlists

1. Next, download the *Music Player Daemon* configuration file [*mpd.conf*](mpd.conf "mpd.conf") and copy it to *~/.config/mpd/mpd.conf*

1. Install the *ncmpcpp* music player client:

        $ sudo apt-get install ncmpcpp

1. Download the *ncmpcpp* configuration file [*config*](config "ncmpcpp config file") and copy it to *~/.config/ncmpcpp/config*.

#### Setup the i3 Window Manager

1. Install the *i3 Window Manager*:

        $ sudo apt-get install i3 

1. Create the *i3 Window Manager* configuration directory: 

        $ mkdir -p ~/.config/i3/

1. Download the *i3 Window Manager* configuration file [*config*](config "i3wm config file") and copy it to *~/.config/i3/config*.

1. Install the *i3 Window Manager status bar* and create its configuration directory:

        $ sudo apt-get install i3status
        $ mkdir -p ~/.config/i3status

1. Configure the status bar:

    * download its configuration file [*config*](config "i3wm status bar config file") and copy it to *~/.config/i3status/config*
    * download the custom status bar configuration script [*myi3status.sh*](myi3status.sh "myi3status.sh") and copy it to *~/.config/i3status/myi3status.sh*

1. Install the compositor *compton* (which handles window transparency), 
*i3lock* lock screen, *rofi* application launcher and *feh* wallpaper manager:

        $ sudo apt-get install compton i3lock rofi feh

#### Setup MediaTomb

Mediatomb is a UPnP media server that allows you to stream your media library across your home. To install
it type:

        $ sudo apt-get install mediatomb

The mediatomb configuration file is *~/.mediatomb/config.xml*. By default, the web UI is enabled and is insecure
because it allows anyone to access all files on the sytem where mediatomb is installed. To disable the UI, change the line
in the confiuration file that says:

        <ui enabled="yes" poll-interval="2" poll-when-idle="no"/>

to

        <ui enabled="no" poll-interval="2" poll-when-idle="no"/>


To launch mediatomb in daemon mode, enter the following command:

        $ mediatomb --port 49152 --daemon --home ~/Music --logfile ~/.mediatomb/mediatomb.log --config ~/.mediatomb/config.xml

If you want mediatomb to start automatically at boot then download this [*systemd unit file*](mediatomb.service "mediatomb.service").
Place this file in */etc/systemd/system*. Then execute the following commands:

        $ cd /etc/systemd/system
        $ sudo chown root:root mediatomb.service
        $ sudo chmod 664 mediatomb.service
        $ sudo systemctl daemon-reload
        $ sudo systemctl enable mediatomb.service
        $ sudo systemctl start mediatomb.service 

#### Setup Oracle Virtualbox

1. Download [Oracle Virtualbox](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html "Oracle Virtualbox").
1. Install it with the command:

        $ sudo dpkg -i <path to .deb file>

1. Launch Virtualbox and allow it to download and install the extension package.
1. Import all the virtualbox appliances previously exported.

## Make Separate Images of the Windows 10 and Linux Mint Partitions

Boot from a USB flash drive containing Clonezilla and use it to make
an image of the 150 GiB Windows 10 partition to an external hard drive.

Do the same for the Linux Mint partition.

*Note: Do not make images of the Google Drive, Music, Ebooks, Data,
 Shared Documents or Virtual Machine partitions.*

## Restore Data from Backups

1. Restore all music to the folder *C:\Users\johndoe\Music*.
1. Restore all ebooks to the folder *C:\Users\johndoe\Ebooks*.
1. Download all files from *johndoe's* Google Drive account into the folder *C:\Users\johndoe\Google Drive*.
1. Restore the contents of the *Data* partition.
1. Copy the *johndoe.kdbx* password file back to the folder *C:\Users\johndoe\Shared Documents*.
