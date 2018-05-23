#!/bin/bash -x

list="libusb-1.0.22 libusb-compat-0.1.5 libelf-0.8.13 avrdude-6.3"

for i in $list; do
    if [ -d $i/ ]; then
        cd $i/
        make distclean
        cd ..
        rm -rf $i/
    fi
done

if [ -d $PWD/libusb-win32-bin-1.2.6.0 ]; then
    rm -rf $PWD/libusb-win32-bin-1.2.6.0
fi
