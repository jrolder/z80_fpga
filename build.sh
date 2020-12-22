#!/bin/sh -xe
cd zextest
./build.sh
cd ..
cd fpga
./build.sh
./obj_dir/Vz80
