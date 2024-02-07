#!/usr/bin/env bash
set -e
set -x

# set -euxo pipefail

set -x
# SOURCE: https://rtx.pub/install.sh
#region environment setup
get_os() {
  os="$(uname -s)"
  if [ "$os" = Darwin ]; then
    echo "macos"
  elif [ "$os" = Linux ]; then
    echo "linux"
  else
    error "unsupported OS: $os"
  fi
}

# SOURCE: https://rtx.pub/install.sh
get_arch() {
  arch="$(uname -m)"
  if [ "$arch" = x86_64 ]; then
    echo "x64"
  elif [ "$arch" = aarch64 ] || [ "$arch" = arm64 ]; then
    echo "arm64"
  else
    error "unsupported architecture: $arch"
  fi
}

CURRENT_OS="$(get_os)"

# SOURCE: https://github.com/viaduct-ai/kustomize-sops/blob/master/scripts/install-ksops.sh

# Require $XDG_CONFIG_HOME to be set
if [[ -z "$XDG_CONFIG_HOME" ]]; then
  echo "You must define XDG_CONFIG_HOME to use a legacy kustomize plugin"
  echo "Add 'export XDG_CONFIG_HOME=\$HOME/.config' to your .bashrc or .zshrc"
  exit 1
fi

if [ "$CURRENT_OS" = "macos" ]; then
  VERSION=1.6.0 PLATFORM=darwin ARCH=arm64
else
  VERSION=1.6.0 PLATFORM=linux ARCH=amd64
fi
# https://github.com/goabout/kustomize-sopssecretgenerator/releases/download/v1.6.0/SopsSecretGenerator_1.6.0_linux_amd64
# VERSION=1.6.0 PLATFORM=darwin ARCH=amd64
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator" || true
pushd "${XDG_CONFIG_HOME:-$HOME/.config}/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator"
curl -Lo SopsSecretGenerator "https://github.com/goabout/kustomize-sopssecretgenerator/releases/download/v${VERSION}/SopsSecretGenerator_${VERSION}_${PLATFORM}_${ARCH}"
chmod +x SopsSecretGenerator
popd

# mv SopsSecretGenerator "${XDG_CONFIG_HOME:-$HOME/.config}/kustomize/plugin/goabout.com/v1beta1/sopssecretgenerator"
