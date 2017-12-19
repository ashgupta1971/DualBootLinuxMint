# Install and Configure Linux Mint (Unencrypted)

## Prior to Running Linux Mint Installer

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

## Run the Linux Mint Installer

Execute the following command to run the Linux Mint installer:
        
        $ sh -c "ubiquity -b gtk_ui"&

Go through the steps in the Linux Mint installer. When prompted to setup partitions,
select *something else* and map the logical volumes created above to their 
appropriate mount points.


## After Running Linux Mint Installer

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

1. Now download the new [GRUB configuration file](https://ashgupta1971.github.io/DualBootLinuxMint/WithoutEncryption/grub "grub")
 and copy it to */etc/default/grub*.

1. Download the [GRUB background image](https://ashgupta1971.github.io/DualBootLinuxMint/Common/grub_background.png "grub_background.png")
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

## Fix GRUB Menu

After rebooting, you will be presented with the GRUB boot loader menu. There
will be entries to boot into the Windows 10 partition and Linux Mint partition.
Try selecting each entry to see what it does. (You will need to reboot to get back
into the GRUB boot loader menu after each selection.)

Now we will manually, edit the GRUB boot loader menu so that it appears more
presentable. First, make a backup copy of the GRUB files:

        $ sudo cp -r /etc/grub.d /etc/grub.d.original

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

## Setup the fstab file

1. Login as *johndoe*.
1. Create directories in *johndoe's* home folder for Oracle Virtualbox and wallpapers:

        $ mkdir /home/johndoe/VirtualBox\ VMs
        $ mkdir /home/johndoe/Wallpaper

1. Make a backup of the existing */etc/fstab* file (this contains all the mount
points for the system):

        $ cd /etc
        $ sudo mv fstab{,.bak}

1. Download the new [*fstab* file](https://ashgupta1971.github.io/DualBootLinuxMint/Common/fstab "fstab")
 and copy it to */etc/fstab*.
1. Setup all the mount points in the *fstab* file and mount them using the command (note that the
UUID numbers for your system will be different than the ones in this file):

        $ sudo mount -a

## Setup Oracle Virtualbox

1. Download [Oracle Virtualbox](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html "Oracle Virtualbox").
1. Install it with the command:

        $ sudo dpkg -i <path to .deb file>

1. Launch Virtualbox and allow it to download and install the extension package.
1. Import all the virtualbox appliances previously exported.

## Perform More Customizations

Watch the [Youtube video](https://youtu.be/RXV6FXVL6xI "15 Things To Do First in Linux Mint")
and perform any of the customizations mentioned.

## Change Shell and Install Additional Packages

Optionally, you can change the shell, editor, file manager and perform other customizations
as described [here](https://ashgupta1971.github.io/DualBootLinuxMint/Common/install-lightweight-apps.html "Install i3, zsh, vim and more.").
