#!/bin/bash

# Slackware build script for r8152

# Copyright 2022 Lime Technology Inc.
# License: GPLv2

cd $(dirname $0) ; CWD=$(pwd)

PRGNAM=r8152
VERSION=$(ls $PRGNAM-*.tar.?z* | cut -d - -f 2 | rev | cut -f 3- -d . | rev)
BUILD=${BUILD:-1}
TAG=${TAG:-_LT}
PKGTYPE=${PKGTYPE:-txz}

KERNEL=${KERNEL:-$(uname -r)}
PKGVER=$(printf %s "${VERSION}_$KERNEL" | tr - _)

if [ -z "$ARCH" ]; then
  case "$( uname -m )" in
    i?86) ARCH=i586 ;;
    arm*) ARCH=arm ;;
       *) ARCH=$( uname -m ) ;;
  esac
fi

if [ "$ARCH" = "i586" ]; then
  SLKCFLAGS="-O2 -march=i586 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "i686" ]; then
  SLKCFLAGS="-O2 -march=i686 -mtune=i686"
  LIBDIRSUFFIX=""
elif [ "$ARCH" = "x86_64" ]; then
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX="64"
else
  SLKCFLAGS="-O2"
  LIBDIRSUFFIX=""
fi

set -eu

TMP=${TMP:-/tmp}
BLD=${DATA_DIR:-$TMP}
PKG=$TMP/package-$PRGNAM
OUTPUT=${OUTPUT:-$TMP}

rm -rf $PKG
mkdir -p $TMP $PKG $BLD

cd $BLD
rm -rf $PRGNAM-$VERSION
tar xvf $CWD/$PRGNAM-$VERSION.tar.bz2
cd $PRGNAM-$VERSION
chown -R root:root .
find -L . \
 \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
  -o -perm 511 \) -exec chmod 755 {} \; -o \
 \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
  -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# make the driver module
make EXTRA_CFLAGS="$SLKCFLAGS" modules
xz $PRGNAM.ko
install -m 0644 -D -t $PKG/lib/modules/$KERNEL/updates/drivers/net/usb $PRGNAM.ko.xz
# copy udev rule
install -m 0644 -D -t $PKG/etc/udev/rules.d 50-usb-realtek-net.rules 

mkdir -p $PKG/install
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.
#      |-----handy-ruler------------------------------------------------------|
tee $PKG/install/slack-desc <<EOF
$PRGNAM: $PRGNAM driver version $VERSION built for $(uname -r)
$PRGNAM:
$PRGNAM: https://www.realtek.com/en/component/zoo/category/
$PRGNAM:  network-interface-controllers-10-100-1000m-gigabit-ethernet-
$PRGNAM:  usb-3-0-software
$PRGNAM:
$PRGNAM:
$PRGNAM:
$PRGNAM:
$PRGNAM:
$PRGNAM:
EOF

cd $PKG
# slackware package naming convention
#/sbin/makepkg -l y -c n $BLD/$PRGNAM-$PKGVER-$ARCH-$BUILD$TAG.$PKGTYPE
# Unraid OS module package naming convention
/sbin/makepkg -l y -c n $OUTPUT/$PRGNAM-$VERSION-$KERNEL-$BUILD.$PKGTYPE
