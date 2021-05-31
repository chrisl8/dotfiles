export PATH=${HOME}/dotfiles/Scripts:${HOME}/dotfiles/bin:${HOME}/bin:${HOME}/Work/Scripts:${PATH}
if (uname -a | grep arch64 >/dev/null); then
  export PATH=${HOME}/dotfiles/pi64:${PATH}
fi
