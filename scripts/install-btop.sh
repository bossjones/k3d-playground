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

cd ~/.local/src
git clone https://github.com/aristocratos/btop
cd btop
make all
sudo make install
sudo make setuid
