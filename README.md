# dotfiles
My Linux configuration settings and setup files.

## Platform

This is intended to work on both the latest LTS of Ubuntu **and** WSL2.
It should also work on Raspbian as well as Ubuntu on Raspberry Pi.

## To Install

Because this is a Private repository, you need to authenticate yourself or use a token.  

You will have to go into your "Developer Settings" in Github Settings and set up a key.  
https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token

1. https://github.com/settings/profile
2. <> Developer Settings
3. Personal access tokens
4. Fine-grained tokens
5. Generate new token
6. Give it a name
7. The furthest expiration date possible is 1 year out, so do that.
8. Only select repositories
9. Pick this one
10. Repository Permissions -> Content -> Read-Only
11. Generate token

Save it somewhere safe.

This is how I perform this install on a new system using said token:  

```shell
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -H 'Authorization: token <TOKEN>' \
  -H 'Accept: application/vnd.github.v4.raw' \
  -O \
  -L https://raw.githubusercontent.com/chrisl8/dotfiles/main/setup.sh && chmod +x ./setup.sh && ./setup.sh && rm ./setup.sh
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