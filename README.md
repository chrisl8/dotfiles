# dotfiles
My Linux configuration settings and setup files.

## To Install

Because this is a Private repository you need to authenticate yourself.
This repository has a Deploy Key on it and the private key should be in:
`/home/chrisl8/Dropbox/allLinux/dotfilesDeployKey`

Use that key for any system that you don't want to actually give your normal keys to.

```shell
cd
git clone git@github.com:chrisl8/dotfiles.git
cd dotfiles
./update.sh
```

## To Update

You can run the `update.sh` in dotfiles as often as you like,
but there is a script to update everything:

```shell
updateAllTheTHings.sh
```

# Fonts

Fonts are vendored here so that I can easily set them up for the terminal of my system if needed.
See README.md in each fonts sub-folder for source information.

## Install the Font for Ubuntu
1. Open "Files"
2. Navigate to "Home"/dotfiles/fonts/JetBrainsMonoNerdFonts
3. Find and double-click on `JetBrains Mono Regular Nerd Font Complete.ttf`
4. Click "Install"

Now open your Terminal settings and set this Font.

Your Powerline prompt should look amazing!

## Install the Font for Windows

TODO: Add Instructions.

# TMUX

Run `gomux` when you start yoru terminal and it will open a new named session or attach to it if it already exists.
