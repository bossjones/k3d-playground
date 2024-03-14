#!/usr/bin/env bash
echo ""
#echo "# arguments called with ---->  ${@}     "
#echo "# \$1 ---------------------->  $1       "
#echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo ""# my "name ------------------>  ${0##*/} "
echo ""

set -x
# set -euxo pipefail

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

echo "Encrypting target: $1 …"
if [ "$CURRENT_OS" = "macos" ]; then
  sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |ggrep -oP "public key: \K(.*)") --in-place "${1}"
else
  sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --in-place "${1}"
fi
