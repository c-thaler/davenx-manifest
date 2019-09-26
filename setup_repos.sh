#!/bin/bash

RELEASE=thud
TEMPLATES_DIR=$(cd `dirname $0` && pwd)/templates

echo "TES DaveNX repository setup for Yocto ($RELEASE)"
echo "Copyright (C) 2019 TES Electronic Solutions GmbH"
echo "This program is free software; you can redistribute it and/or modify"
echo "it under the terms of the GNU General Public License as published by"
echo "the Free Software Foundation; either version 2 of the License, or"
echo "(at your option) any later version."
echo ""

if [ "$#" -ne 1 ]; then
	echo "Wrong number of parameters ($#)"

	echo "Usage: $0 TARGET_DIR"

	echo ""
	echo "TARGET_DIR - Path where the Yocto environment will be setup"
	echo ""
	echo "The tool will create the TARGET_DIR directory and download"
	echo "all repository required to build the DaveNX image and SDK."
	echo ""
	echo "Example:"
	echo "	./setup_repos.sh ../yocto"
	exit -1
fi

TARGET_DIR=$(cd $1 && pwd)

if [ -d "$TARGET_DIR" ]; then
	echo "Error: $TARGET_DIR already exist!"
	exit -1
fi

mkdir -p $TARGET_DIR
pushd $TARGET_DIR

echo "-- Yocto Poky --"
echo ""

git clone -b $RELEASE git://git.yoctoproject.org/poky

echo "-- Additional layers --"
echo ""

mkdir -p repos
pushd repos
git clone -b $RELEASE git@github.com:openembedded/meta-openembedded.git
git clone -b $RELEASE git@github.com:c-thaler/meta-tes.git
git clone -b $RELEASE git@github.com:c-thaler/meta-qt5.git
pushd meta-qt5
git remote add upstream git@github.com:meta-qt5/meta-qt5
popd
git clone -b $RELEASE git@github.com:c-thaler/meta-altera.git
pushd meta-altera
git remote add upstream git@github.com:kraj/meta-altera
popd
git clone -b $RELEASE git@github.com:c-thaler/meta-linaro.git
pushd meta-linaro
git remote add upstream https://git.linaro.org/openembedded/meta-linaro.git
popd
popd

. ./poky/oe-init-build-env ./build

# Copy templates
cp $TEMPLATES_DIR/bblayers.conf ./conf/
sed -i 's|ABSOLUTE_PATH_TO_YOUR_YOCTO|'$TARGET_DIR'|g' ./conf/bblayers.conf

cp $TEMPLATES_DIR/local.conf ./conf/
