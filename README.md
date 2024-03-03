# dotfiles
My Linux configuration settings and setup files.

**I do not expect these to work generically for anyone else, but they are here if in case they can help you as examples.**

## Platform

This is intended to work on both the latest LTS of Ubuntu **and** WSL2.
It should also work on Raspbian as well as Ubuntu on Raspberry Pi.

## To Install

This is how I perform this installation on a new system using said token:  

```shell
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -H 'Accept: application/vnd.github.v4.raw' -O \
  -L https://raw.githubusercontent.com/chrisl8/dotfiles/main/setup.sh && chmod +x ./setup.sh && ./setup.sh && rm ./setup.sh
```


# Fonts

Fonts are vendored here so that I can easily set them up for the terminal of my system if needed.
See README.md in each font sub-folder for source information.

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