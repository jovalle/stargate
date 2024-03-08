#!/bin/bash

set -e

# Get token from https://github.com/jovalle/stargate/settings/actions/runners/new?arch=x64&os=linux
[[ -z "$GH_AR_TOKEN" ]] && { echo "GH_AR_TOKEN must set! Exiting." ; exit 1; }
[[ -n $APP_DIR ]] || { export APP_DIR=/var/lib/stargate ; }
[[ -d $APP_DIR/actions-runner ]] || { mkdir $APP_DIR/actions-runner ; }

echo "Deploying actions runner..."

if [[ $(lscpu | grep -i architecture) == *aarch64* ]]; then
  export ARCH=arm64
else
  export ARCH=x64
fi

VERSION="2.314.1"

pushd ${APP_DIR}/actions-runner
if [[ ! -f ./actions-runner-linux-${ARCH}-${VERSION}.tar.gz ]]; then
  curl -o actions-runner-linux-${ARCH}-${VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-${ARCH}-${VERSION}.tar.gz
  tar xzf ./actions-runner-linux-${ARCH}-${VERSION}.tar.gz
fi

[[ $USER == "root" ]] && export RUNNER_ALLOW_RUNASROOT=1
./config.sh --url https://github.com/jovalle/stargate --token ${GH_AR_TOKEN}
./svc.sh install
cat <<'EOF' > /var/lib/stargate/actions-runner/.env
LANG=en_US.UTF-8
RUNNER_ALLOW_RUNASROOT=1
EOF
systemctl daemon-reload
systemctl restart actions.runner.jovalle-stargate.stargate.service
systemctl enable actions.runner.jovalle-stargate.stargate.service
popd

set +e
