#!/usr/bin/env bash
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

if [ -n "$SOPS_AGE_KEY_FILE" ]; then
  echo "SOPS_AGE_KEY_FILE is not empty"
else
  echo "SOPS_AGE_KEY_FILE is empty"
  exit 1
fi

if [ "$CURRENT_OS" = "macos" ]; then
  for aFile in $(find . -type f -name '*.sops.yaml' ! -name ".sops.yaml"); do
    echo "Re-encrypting ${aFile}"
    sops --decrypt --age $(cat "$SOPS_AGE_KEY_FILE" | ggrep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place "${aFile}"
    sops --encrypt --age $(cat "$SOPS_AGE_KEY_FILE" | ggrep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place "${aFile}"
  done
else
  for aFile in $(find . -type f -name '*.sops.yaml' ! -name ".sops.yaml"); do
    echo "Re-encrypting ${aFile}"
    sops --decrypt --age $(cat "$SOPS_AGE_KEY_FILE" | grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place "${aFile}"
    sops --encrypt --age $(cat "$SOPS_AGE_KEY_FILE" | grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place "${aFile}"
  done
fi
