export PATH=${HOME}/dotfiles/Scripts:${HOME}/dotfiles/bin:${HOME}/bin:${HOME}/Work/Scripts:${PATH}
if (uname -a | grep arm >/dev/null); then
  if (file /bin/ls | grep "32-bit" > /dev/null); then
    export PATH=${HOME}/dotfiles/pi32:${PATH}
  fi
  if (file /bin/ls | grep "64-bit" > /dev/null); then
    export PATH=${HOME}/dotfiles/pi64:${PATH}
  fi
fi
if (uname -a | grep arch >/dev/null); then
  if (file /bin/ls | grep "32-bit" > /dev/null); then
    export PATH=${HOME}/dotfiles/pi32:${PATH}
  fi
  if (file /bin/ls | grep "64-bit" > /dev/null); then
    export PATH=${HOME}/dotfiles/pi64:${PATH}
  fi
fi
if [[ -n "$WSL_DISTRO_NAME" && "$(uname -n)" == "KSCDTL01CL5864" ]]; then
    export http_proxy=http://sub.proxy.att.com:8080/
    export https_proxy=http://sub.proxy.att.com:8080/
    export NO_PROXY=".att.com,.sbc.com,localhost,127.0.0.1,*.docker.internal,.azmk8s.io"
fi
