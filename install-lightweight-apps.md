# Installing a Lightweight Window Manager and Associated Applications

Linux Mint is usually installed with the Cinnamon or Mate desktop environments.
This section shows how to install the *i3 window manager* and some other
applications not part of the default Linux Mint install. *i3* and these other
apps draw fewer system resources and may be useful for an underpowered system.

## Download Configuration Files from git Repository

1. Before installing any other software packages, update the package database:
    
        $ sudo apt-get update

1. We will download some configuration files from a *git* repository. But first, we
must install and configure *git*. Execute the following command in *johndoe's* home directory:

        $ sudo apt-get install git
        $ git config --global user.name "John Doe"
        $ git config --global user.email "johndoe@server.com"
        $ git clone https://github.com/ashgupta1971/dotfiles.git

## Setup the Shell

By default, Linux Mint comes with the *Bash* shell. We recommend the *Z* shell, not because
it is lightweight, but because it is much more powerfull.

1. Install the Z Shell:

        $ sudo apt-get install zsh zsh-docs
        $ chsh -s /usr/bin/zsh johndoe

1. Download the Z Shell configuration file [*zshrc*](https://ashgupta1971.github.io/DualBootLinuxMint/Common/zshrc "zshrc") into *johndoe's* home directory
and rename it *.zshrc*.

## Install a File Browser

Linux Mint, by default, comes with the *Nemo* file browser. We recommend *thunar* instead:

        $ sudo apt-get install thunar

*Thunar* is highly customizable, so configure it as necessary.

## Install and Setup Vim

We recommend the *vim* text editor because it is lightweight and very powerfull:

        $ sudo apt-get install vim-gtk

1. Get the vim configuration file [*vimrc*](https://ashgupta1971.github.io/DualBootLinuxMint/Common/vimrc "vimrc") and copy it to *johndoe's* home directory
with the name *.vimrc*.

## Setup the Music Player Backend

1. Install the *Music Player Daemon*:

        $ sudo apt-get install mpd mpc

1. Configure the *Music Player Daemon* by first creating its working 
and playlist directories:

        $ mkdir -p ~/.config/mpd/playlists

1. Next, download the *Music Player Daemon* configuration file [*mpd.conf*](https://github.com/ashgupta1971/dotfiles/blob/master/mpd/mpd.conf "mpd.conf") and copy it to *~/.config/mpd/mpd.conf*

## Install a Music Player

The *Music Player Daemon* needs a music player to actually interface with the user. We recommend installing *ncmpcpp* for this purpose:

        $ sudo apt-get install ncmpcpp

Download the *ncmpcpp* configuration file [*config*](https://github.com/ashgupta1971/dotfiles/blob/master/ncmpcpp/config "ncmpcpp config file") and copy it to *~/.config/ncmpcpp/config*.

## Setup the i3 Window Manager

As mentioned above, the *i3 window manager* is very lightweight. We will install and configure it in this section.

1. Install the *i3 Window Manager*:

        $ sudo apt-get install i3 

1. Create the *i3 Window Manager* configuration directory: 

        $ mkdir -p ~/.config/i3/

1. Download the *i3 Window Manager* configuration file [*config*](https://github.com/ashgupta1971/dotfiles/blob/master/i3/config "i3wm config file") and copy it to *~/.config/i3/config*.

1. Install the *i3 Window Manager status bar* and create its configuration directory:

        $ sudo apt-get install i3status
        $ mkdir -p ~/.config/i3status

1. Configure the status bar:

    * download its configuration file [*config*](https://github.com/ashgupta1971/dotfiles/blob/master/i3status/config "i3wm status bar config file") and copy it to *~/.config/i3status/config*
    * download the custom status bar configuration script [*myi3status.sh*](https://github.com/ashgupta1971/dotfiles/blob/master/i3status/myi3status.sh "myi3status.sh") and copy it to *~/.config/i3status/myi3status.sh*

1. Install the compositor *compton* (which handles window transparency), 
*i3lock* lock screen, *rofi* application launcher and *feh* wallpaper manager:

        $ sudo apt-get install compton i3lock rofi feh

## Setup MediaTomb

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

If you want mediatomb to start automatically at boot then download this [*systemd unit file*](https://github.com/ashgupta1971/dotfiles/blob/master/mediatomb/mediatomb.service "mediatomb.service").
Place this file in */etc/systemd/system*. Then execute the following commands:

        $ cd /etc/systemd/system
        $ sudo chown root:root mediatomb.service
        $ sudo chmod 664 mediatomb.service
        $ sudo systemctl daemon-reload
        $ sudo systemctl enable mediatomb.service
        $ sudo systemctl start mediatomb.service 
