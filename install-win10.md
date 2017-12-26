# Install and Configure Windows 10

## During Install

1. Insert the USB flash drive containing Windows 10 and boot from it.
1. Go through the installation procedure.
1. Choose the *Windows 10* partition when prompted (this should be partition number 1). 
 *Note: Because we are telling Windows to install in a specific partition, it will not generate
a separate **System Reserved** partition. Instead, it will place all files in the partition we
have chosen.*
1. Make sure not to choose "Express Install" when prompted (this will enable various "snooping" options).
1.  When prompted for the first user account, choose the name *admin* but ensure it is created as a *local* account not a *One Drive* account.

## After Install

1. Disconnect from the internet.
1. Boot into the Windows 10 environment you just installed.
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
1. Connect to the internet and install your security software.
1. Install all outstanding Windows 10 updates.
1. Install and activate any non-free software which you previously deactivated (ie. Microsoft Office).
1. Download and install the driver and software for your printer.

## Install Open-Source Software

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
[*vimrc* configuration file](https://github.com/ashgupta1971/dotfiles/blob/master/vim/.vimrc ".vimrc") and copy it to *C:\Users\johndoe\\_vimrc*.

## Finish Up Windows Installation

1. Remove unnecessary programs from startup using Windows' *msconfig* utility.
1. Configure the desktop as desired.
1. Calibrate the display using Windows' *calibrate* utility.
