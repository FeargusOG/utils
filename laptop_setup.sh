#!/bin/bash

user=$1
lastpass_email=$2

function main () {
  snap_install
  apt_install
  git_setup $user $lastpass_email
  clone_utils $user
}

function snap_install() {
  # VS Code
  snap install code --classic
  # Spotify
  snap install spotify
  # Atom
  snap install atom --classic
  # Jq
  snap install jq
}

function apt_install() {
  apt-get update -y
  apt-get upgrade -y
  apt-get dist-upgrade
  # Git
  apt-get install -y git
  # LastPass cli
  apt-get install -y lastpass-cli
  # TLDR
  apt-get install -y nodejs npm
  npm install -g tldr
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

main