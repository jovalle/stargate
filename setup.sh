#!/bin/bash

#
# setup.sh - Deployment tool for Stargate
# Released under Apache License 2.0.
#
# https://github.com/jovalle/stargate
#

VERSION="v1"

[[ -n ${APP_DIR} ]] || export APP_DIR=/var/lib/stargate

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
    update               deploy changes from docker-compose.yaml
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

  [[ $(systemctl list-unit-files systemd-resolved &>/dev/null) ]] && systemctl stop systemd-resolved && systemctl disable systemd-resolved

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

  pwd | grep ${APP_DIR}
  if [[ $? -ne 0 ]]; then
    abort "jovalle/stargate must reside in ${APP_DIR}"
  fi

  if [[ ! -f /etc/systemd/system/stargate.service ]]; then
    ln -s ${APP_DIR}/stargate.service /etc/systemd/system/stargate.service
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
# Update only altered services
#

update() {
  pushd $APP_DIR
  if [[ -f $APP_DIR/.env ]]; then
    source $APP_DIR/.env
  fi
  /usr/bin/docker-compose $EXTRA_ARGS up -d $EXTRA_UP_ARGS
  popd
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
    update) update; ;;
    *) usage; exit ;;
  esac
done
