#!/bin/bash -ex
# Copyright (c) 2014-2016 Arduino LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

OUTPUT_VERSION=6.3.0-arduino9

export OS=`uname -o || uname`
export TARGET_OS=$OS

if [[ $CROSS_COMPILE == "Darwin" ]] ; then

  ## checks for the existence of o64-clang in your PATH
  [ ! `which o64-clang` ] && echo -e "\nInsert o64-clang executable in your PATH variable !\n" && exit 0

  PLATFORM=$(o64-clang -v 2>&1 | grep Target | awk {'print $2'} | sed 's/[.].*//g')

  export CC=o64-clang
  export CXX=o64-clang++
  export CROSS_COMPILE_HOST=$PLATFORM
  export PKG_CONFIG=$(which pkg-config)
  OUTPUT_TAG=$PLATFORM
  export ARCH=osx

elif [[ $CROSS_COMPILE == "arm" ]] ; then

  export CC="arm-linux-gnueabihf-gcc"
  export CXX="arm-linux-gnueabihf-g++"
  export CROSS_COMPILE_HOST="arm-linux-gnueabihf"
  export PKG_CONFIG=$(which pkg-config)
  OUTPUT_TAG=armhf-pc-linux-gnu
  export ARCH=arm

elif [[ $CROSS_COMPILE == "mingw" ]] ; then

  export CC="i686-w64-mingw32-gcc"
  export CXX="i686-w64-mingw32-g++"
  export CROSS_COMPILE_HOST="i686-w64-mingw32"
  export TARGET_OS="Windows"
  OUTPUT_TAG=i686-w64-mingw32
  export ARCH=windows

elif [[ $CROSS_COMPILE == "arm64" ]] ; then

  export CC="aarch64-linux-gnu-gcc"
  export CXX="aarch64-linux-gnu-g++"
  export CROSS_COMPILE_HOST="aarch64-linux-gnu"
  export PKG_CONFIG=$(which pkg-config)
  OUTPUT_TAG=aarch64-pc-linux-gnu
  export ARCH=arm64

elif [[ $OS == "GNU/Linux" ]] ; then

  export MACHINE=`uname -m`
  if [[ $MACHINE == "x86_64" ]] && [[ $1 = "32" ]] ; then
    export CC="i686-linux-gnu-gcc"
    export CXX="i686-linux-gnu-g++"
    OUTPUT_TAG=i686-pc-linux-gnu
    export ARCH=linux32
  elif [[ $MACHINE == "x86_64" ]] ; then
    OUTPUT_TAG=x86_64-pc-linux-gnu
    export ARCH=linux64
  elif [[ $MACHINE == "i686" ]] ; then
    OUTPUT_TAG=i686-pc-linux-gnu
    export ARCH=linux32
  elif [[ $MACHINE == "armv7l" ]] ; then
    OUTPUT_TAG=armhf-pc-linux-gnu
    export ARCH=arm
  else
    echo Linux Machine not supported: $MACHINE
    exit 1
  fi

elif [[ $OS == "Msys" || $OS == "Cygwin" ]] ; then

  echo *************************************************************
  echo WARNING: Build on native Cygwin or Msys has been discontinued
  echo you may experience build failure or weird behaviour
  echo *************************************************************

  export PATH=$PATH:/c/MinGW/bin/:/c/cygwin/bin/
  export CC="mingw32-gcc -m32"
  export CXX="mingw32-g++ -m32"
  export TARGET_OS="Windows"
  OUTPUT_TAG=i686-mingw32

else

  echo OS Not supported: $OS
  exit 2

fi

# rm -rf avrdude-6.3 libusb-1.0.20 libusb-compat-0.1.5 libusb-win32-bin-1.2.6.0 libelf-0.8.13

./libusb-1.0.20.build.bash
./libusb-compat-0.1.5.build.bash
./libelf-0.8.13.build.bash
./avrdude-6.3.build.bash

# if producing a windows build, compress as zip and
# copy *toolchain-precompiled* content to any folder containing a .exe

if [[ ${OUTPUT_TAG} == *"mingw"* ]] ; then

    cp libusb-win32-bin-1.2.6.0/bin/x86/libusb0_x86.dll objdir/windows/bin/libusb0.dll

fi

# if [[ ${OUTPUT_TAG} == *"mingw"* ]] ; then
#
#   cp libusb-win32-bin-1.2.6.0/bin/x86/libusb0_x86.dll objdir/windows/bin/libusb0.dll
#   rm -f avrdude-${OUTPUT_VERSION}-${OUTPUT_TAG}.zip
#   cp -a objdir avrdude
#   zip -r avrdude-${OUTPUT_VERSION}-${OUTPUT_TAG}.zip avrdude
#   rm -r avrdude
#
# else
#
#   rm -f avrdude-${OUTPUT_VERSION}-${OUTPUT_TAG}.tar.bz2
#   cp -a objdir avrdude
#   tar -cjvf avrdude-${OUTPUT_VERSION}-${OUTPUT_TAG}.tar.bz2 avrdude
#   rm -r avrdude
#
# fi
