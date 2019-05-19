#!/bin/bash -x

list="libusb-1.0.20 libusb-compat-0.1.5 libelf-0.8.13 avrdude-6.3"

for i in $list
do
    rm -rf $PWD/$i/
done

rm -rf $PWD/libusb-win32-bin-1.2.6.0
