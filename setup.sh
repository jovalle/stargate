#!/bin/bash

#
# setup.sh - Deployment tool for Stargate
# Released under Apache License 2.0.
#
# https://github.com/jovalle/stargate
#

VERSION="v1"
SERVICES=(
  glances
  stargate
)

[[ -n ${APP_DIR} ]] || export APP_DIR=/etc/stargate

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
    btop \
    curl \
    dnsutils \
    docker \
    docker-compose \
    glances \
    net-tools \
    python3 \
    python3-bottle \
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

  for svc in ${SERVICES[@]}; do
    if [[ ! -f /etc/systemd/system/${svc}.service ]]; then
      ln -sf ${APP_DIR}/${svc}.service /etc/systemd/system/${svc}.service
    fi

    test -f /etc/systemd/system/${svc}.service && systemctl daemon-reload || abort "${svc}.service not found"

    systemctl status ${svc} &>/dev/null
    if [[ $? -ne 0 ]]; then
      echo "${svc}.service is NOT running. Restarting service..."
      systemctl restart ${svc}
    else
      echo "${svc}.service is running"
    fi

    systemctl enable ${svc}
  done
}

#
# Stop and remove stargate services
#

delete() {
  for svc in ${SERVICES[@]}; do
    systemctl stop ${svc}
    systemctl disable ${svc}
    test -f /etc/systemd/system/${svc}.service && rm -f /etc/systemd/system/${svc}.service
  done
}

#
# Update only altered services
#

update() {
  pushd $APP_DIR
  if [[ -f $APP_DIR/.env ]]; then
    source $APP_DIR/.env
  fi
  /usr/bin/docker-compose up -d --remove-orphans
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
