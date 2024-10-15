#!/bin/bash

apt update

apt install -y \
	btop \
  ca-certificates \
  cifs-utils \
  curl \
  dnsutils \
  extrepo \
  fio \
  glances \
  htop \
  iftop \
  iotop \
  jq \
  lm-sensors \
  mediainfo \
  ncdu \
  neofetch \
  net-tools \
  nfs-common \
  open-iscsi \
  psmisc \
  rsync \
  software-properties-common \
  sudo \
  vim

apt autoremove -y
