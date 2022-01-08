# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -z ${PUTTY_SESSION} ]];then
    if [[ ${TERM} == "xterm" ]];then
        export PUTTY_SESSION=True
    else
        export PUTTY_SESSION=False
    fi
fi

#export TERM=xterm-256color # For puTTY sessions

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

export DEFAULT_USER="${USER}"

# https://github.com/romkatv/powerlevel10k#extra-or-missing-spaces-in-prompt-compared-to-powerlevel9k
# This must be 1 or more or else vertical split tmux windows go insane.
ZLE_RPROMPT_INDENT=1

# Use http://nerdfonts.com/?set=nf-custom-#cheat-sheet to find icon codes to use

if [[ ${PUTTY_SESSION} == "True" ]];then
# TODO: This won't actually accomplish anything, but it is here to transfor to a new .p10k.zsh file for putty someday, if I ever use it.

# For some reason Nerd Font glyphs in Windows via puTTY don't all work.
# So I found some that looked similar but worked and substituted.
# Someday maybe we'll sort out the reason, and/or add more substitutions.
# In theory we could even use 'nerdfont-complete' if we found enough.
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)

# run 'get_icon_names' from the command prompt to see all icon names,
# and what they are set to now!
POWERLEVEL9K_VCS_UNSTAGED_ICON='\uf704'
POWERLEVEL9K_VCS_STASH_ICON='\uf48d'
POWERLEVEL9K_VCS_STAGED_ICON='\uf916'
POWERLEVEL9K_HOME_ICON='\uf46d'
POWERLEVEL9K_CARRIAGE_RETURN_ICON='\uf810'
POWERLEVEL9K_OK_ICON='\uf62b'
#POWERLEVEL9K_LINUX_ICON='\ue712'
POWERLEVEL9K_VI_INSERT_MODE_STRING=''
POWERLEVEL9K_VI_COMMAND_MODE_STRING='%F{green3}\uE62B'
fi

# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
KEYTIMEOUT=1

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# I run my own update script, and this just gets in the way when I'm busy.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
# NOTE: See .zshenv for settings that apply to this AND non-interactive sessions!

set -o vi

keychain -q id_rsa
source ~/.keychain/`uname -n`-sh

export EDITOR=vim
export VISUAL=vim

export NVM_SYMLINK_CURRENT=true
# This adds $HOME/.nvm/current/bin which links to the current version.
# Now you can add it to your path in .profile
# AND use it in programs like IntelliJ
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ROS
if [[ "${(L)HOST}" == "twoflower" ]]; then
  export ROS_MASTER_URI=http://localhost:11311
else
  export ROS_MASTER_URI=http://twoflower:11311
fi
export ROS_HOSTNAME=$(uname -n).local
if [[ -d $HOME/catkin_ws/src/ArloBot/scripts ]];then
  export PATH=$PATH:$HOME/catkin_ws/src/ArloBot/scripts
fi
export ROSLAUNCH_SSH_UNKNOWN=1
if [[ -d $HOME/catkin_ws/devel/setup.zsh ]];then
  source $HOME/catkin_ws/devel/setup.zsh
fi

# RobotAnything
if [[ -d $HOME/RobotAnything ]];then
  export PATH=$PATH:$HOME/RobotAnything
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
