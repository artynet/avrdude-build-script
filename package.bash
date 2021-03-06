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

#add osxcross, mingw and arm-linux-gnueabihf paths to PATH

# linux 64
./clean_all_avrdude.bash
./package-avrdude.bash

# linux 32
./clean_all_avrdude.bash
./package-avrdude.bash 32

# windows
./clean_all_avrdude.bash
CROSS_COMPILE="mingw" ./package-avrdude.bash

# arm
./clean_all_avrdude.bash
CROSS_COMPILE="arm" ./package-avrdude.bash

# arm64
./clean_all_avrdude.bash
CROSS_COMPILE="arm64" ./package-avrdude.bash

# osx
./clean_all_avrdude.bash
CROSS_COMPILE="Darwin" ./package-avrdude.bash

# final clean
./clean_all_avrdude.bash

# removing source dirs
./clean_all_dirs.bash

package_index=`cat package_index.template | sed s/%%VERSION%%/${OUTPUT_VERSION}/`

cd objdir

rm -f *.bz2

folders=`ls`
t_os_arr=($folders)

for t_os in "${t_os_arr[@]}"
do
	FILENAME=avrdude-${OUTPUT_VERSION}-${t_os}.tar.bz2
	tar -cjvf ${FILENAME} ${t_os}/*
	SIZE=`stat --printf="%s" ${FILENAME}`
	SHASUM=`sha256sum ${FILENAME} | cut -f1 -d" "`
	T_OS=`echo ${t_os} | awk '{print toupper($0)}'`
	echo $T_OS
	package_index=`echo $package_index |
		sed s/%%FILENAME_${T_OS}%%/${FILENAME}/ |
		sed s/%%FILENAME_${T_OS}%%/${FILENAME}/ |
		sed s/%%SIZE_${T_OS}%%/${SIZE}/ |
		sed s/%%SHA_${T_OS}%%/${SHASUM}/`
done
cd -

set +x

echo ================== CUT ME HERE =====================

echo ${package_index} | python -m json.tool
