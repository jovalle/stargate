#!/bin/bash

#
# setup.sh - Deployment tool for Stargate
# Released under Apache License 2.0.
#
# https://github.com/jovalle/stargate
#

VERSION="v1"

#
# Output usage information
#

usage() {
  cat <<-EOF
  Usage: setup.sh [options] [command]
  Options:
    -V, --version        output program version
    -h, --help           output help information
  Commands:
    prepare              install required packages
    deploy               create and start service
    delete               stop and disable service
EOF
}

#
# Output fatal error
#

abort() {
  echo
  echo "  $@" 1>&2
  echo
  exit 1
}

#
# Output version
#

version() {
  echo $VERSION
}

#
# Update/upgrade/install packages
#

prepare() {
  apt update
  apt upgrade -y
  apt install -y \
    curl \
    dnsutils \
    docker \
    docker-compose \
    net-tools \
    rsync \
    vim

  if [[ $(systemctl is-active systemd-resolved) == "active" ]]; then
    echo -n "Stopping systemd-resolved..."
    systemctl stop systemd-resolved
    echo "Done."
  fi

  if [[ $(systemctl is-enabled systemd-resolved) == "enabled" ]]; then
    echo -n "Disabling systemd-resolved..."
    systemctl disable systemd-resolved
    echo "Done."
  fi

  if [[ -L /etc/resolv.conf ]]; then
    echo -n "Overriding resolv.conf symlink..."
    unlink /etc/resolv.conf
    cat <<'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
    echo "Done."
    echo -n "Setting resolv.conf immutability..."
    lsattr /etc/resolv.conf | awk '{print $1}' | grep i
    if [[ $? -ne 0 ]]; then
      chattr +i /etc/resolv.conf
    fi
    echo "Done."
  fi
}

#
# Configure systemd unit
#

deploy() {
  test -d /etc/stargate || abort "jovalle/stargate must reside in /etc/stargate"

  if [[ ! -f /etc/systemd/system/stargate.service ]]; then
    ln -s /etc/stargate/stargate.service /etc/systemd/system/stargate.service
    popd
  fi

  test -f /etc/systemd/system/stargate.service && systemctl daemon-reload || abort "stargate.service not found"

  systemctl status stargate &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "Stargate is NOT running. Restarting service..."
    systemctl restart stargate
  else
    echo "Stargate is running"
  fi

  systemctl enable stargate
}

#
# Stop and remove stargate services
#

delete() {
  systemctl stop stargate
  systemctl disable stargate
  test -f /etc/systemd/system/stargate.service && rm -f /etc/systemd/system/stargate.service
}

#
# Parse argv
#

while test $# -ne 0; do
  arg=$1
  shift
  case $arg in
    -h|--help) usage; exit ;;
    -v|--version) version; exit ;;
    prepare) prepare; ;;
    deploy) deploy; ;;
    delete) delete; ;;
    *) usage; exit ;;
  esac
done
