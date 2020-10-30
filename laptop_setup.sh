#!/bin/bash

bail=false
function main () {
  if [ -z $SETUP_USER ]; then
    echo "The '\$SETUP_USER' env var must be set!"
    bail=true
  fi

  if [ -z $SETUP_EMAIL ]; then
    echo "The '\$SETUP_EMAIL' env var must be set with your LastPass email account!"
    bail=true
  fi

  if [ "$bail" = false ]; then
      echo "Starting Laptop Setup..."
      snap_install
      apt_install
      git_setup $SETUP_USER $SETUP_EMAIL
      clone_utils $SETUP_USER
      set_bash_aliases $SETUP_USER
  else
    echo "Did you forget to persist the env vars? 'sudo -E ./laptop_setup.sh'"
  fi
}

function snap_install() {
  # Get the list of packages already snap installed
  snap_list=($(snap list | awk '{print $1}'))

  # VS Code
  if [[ ! " ${snap_list[@]} " =~ "code" ]]; then
    snap install code --classic
  fi

  # Spotify
  if [[ ! " ${snap_list[@]} " =~ "spotify" ]]; then
    snap install spotify
  fi

  # Jq
  if [[ ! " ${snap_list[@]} " =~ "jq" ]]; then
    snap install jq
  fi

  # Heroku
  if [[ ! " ${snap_list[@]} " =~ "heroku" ]]; then
    snap install heroku --classic
  fi

  # Postman
  if [[ ! " ${snap_list[@]} " =~ "postman" ]]; then
    snap install postman
  fi

  # Upgrades
  snap refresh
}

function apt_install() {
  # Update apt
  apt-get update -y

  # Git
  if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y git
  fi
  # Atom
  if [ $(dpkg-query -W -f='${Status}' atom 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add
    sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
    apt-get update
    apt-get install -y atom
  fi

  # LastPass cli
  if [ $(dpkg-query -W -f='${Status}' lastpass-cli 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y lastpass-cli
  fi

  # TLDR
  if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y nodejs npm
    npm install -g npm
    npm install -g tldr
  fi

  # Virtualbox
  if [ $(dpkg-query -W -f='${Status}' virtualbox 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y virtualbox
    apt-get install -y virtualbox-guest-additions-iso #/usr/share/virtualbox/VBoxGuestAdditions.iso
  fi

  # Bat
  if [ $(dpkg-query -W -f='${Status}' bat 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y bat
  fi

  # Curl
  if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y curl
  fi

  # Autojump
  if [ $(dpkg-query -W -f='${Status}' autojump 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y autojump
    ## THIS IS NOT WORKING....
    echo "/usr/share/autojump/autojump.bash" >> ~/.bashrc
    chmod 755 /usr/share/autojump/autojump.bash
  fi

  # Go
  if [ $(dpkg-query -W -f='${Status}' golang 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apt-get install -y golang
  fi

  # Upgrade and cleanup
  apt-get upgrade -y
  apt-get dist-upgrade -y
  apt autoremove -y
}

function git_setup () {
  git_username=$(git config user.name)
  if [ -z $git_username ]
  then
    lpass login $2
    echo "Configuring Git..."
    githubemail=$(lpass show 1282860809177592449 --username)
    echo "Using email $githubemail"
    githubuser=$(echo $githubemail | awk -F '@' '{print $1}')
    echo "Using username $githubuser"
    echo "Setting Git SSH Keys..."
    lpass show 1282860809177592449 --notes | jq -r .id_rsa > /home/$1/.ssh/id_rsa
    lpass show 1282860809177592449 --notes | jq -r .id_rsa_pub > /home/$1/.ssh/id_rsa.pub
    sudo -u $1 git config --global user.name "$githubuser"
    sudo -u $1 git config --global user.email "$githubemail"
    sudo -u $1 git config --global color.ui true
    sudo -u $1 git config --global core.editor atom
  fi
}

function clone_utils () {
  if [[ ! -d "/home/$1/workspace" ]]; then
    sudo -u $1 mkdir -p /home/$1/workspace
    cd /home/$1/workspace
    sudo -u $1 git clone git@github.com:FeargusOG/utils.git
  fi
}

function set_bash_aliases () {
  if [[ ! -L "/home/$1/.bash_aliases" ]]; then
    sudo -u $1 ln -s /home/$1/workspace/utils/.bash_aliases /home/$1/.bash_aliases
  fi
}

main
