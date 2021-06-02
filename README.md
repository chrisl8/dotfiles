# dotfiles
My Linux configuration settings and setup files.

## Platform

This is intended to work on both the latest LTS of Ubuntu **and** WSL2.
It should also work on Raspbian as well Ubuntu on Raspberry Pi.

## To Install

Because this is a Private repository, you need to authenticate yourself.
This repository has a Deploy Key on it, and the private key should be in:
`/home/chrisl8/Dropbox/allLinux/dotfilesDeployKey/id_rsa`

To add a key to your new system:  
`mkdir .ssh;vi .ssh/id_rsa;chmod -R go-rw .ssh`

Use that key for any system that you don't want to actually give your normal keys to.

```shell
if ! (command -v git > /dev/null);then sudo apt -y install git;fi
cd
git clone git@github.com:chrisl8/dotfiles.git
cd dotfiles
./update.sh
```

# Fonts

Fonts are vendored here so that I can easily set them up for the terminal of my system if needed.
See README.md in each fonts sub-folder for source information.

## Ubuntu

Open your Terminal settings and set the Font to "JetBrains Mono Regular Nerd Font".

Your Powerline prompt should look amazing!

# Other Terminal Settings

I use a black background on all terminals, so the color settings assume that.

## Install the Font for Windows

TODO: Add Instructions.

# TMUX

Run `gomux` when you start yoru terminal and it will open a new named session or attach to it if it already exists.

## To Update

You can run the `update.sh` in dotfiles as often as you like,
but there is a script to update everything:

```shell
updateAllTheThings.sh
```

# Windows Terminal

TODO: Include font install instructions.