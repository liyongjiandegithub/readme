#!/bin/sh

root_dir=$(pwd)
echo $root_dir
cware_dir=$root_dir/cware-repo
echo $fware_dir

cd $cware_dir/src/cware
#make clean cpu=x86_64 debug=1 
#make comp cpu=x86_64 debug=1 
make all cpu=x86_64 debug=1 
#exit

#cd $cware_dir/src/cware/platform/cpu_intel_xeon/stub
#make clean comp all cpu=x86_64 debug=1 

#cd $cware_dir/src/cware/utils/cmp/
#make clean comp all cpu=x86_64 debug=1 

#cd $cware_dir/src/cware/activefilter/engine/MIPSmux
#make clean comp all cpu=x86_64 debug=1 

#cd $cware_dir/src/cware/video/decoder/
#cd $cware_dir/src/cware/sequencers/xcode/
#cd $cware_dir/src/cware/hostinterface/CHostIF
#cd $cware_dir/src/cware/streams/CFilter/CStreamFilter/CPesPth
#make clean comp all cpu=x86_64 debug=1 

cd $cware_dir/src/cware/sequencers/xcode/interface/ProXCodeHostIFApp
make clean all debug=1 platform=cpu_intel_xeon cpu=x86_64 

cd $cware_dir/x86/os_wrapper/linux
make clean all cpu=x86_64 DEBUG=1 

cd $cware_dir/x86/osal
make clean all debug=1 cpu=x86_64 

cd $cware_dir/x86/bsp
make clean all cpu=x86_64 DEBUG=1 

#change /root/yli/git_1663/cware-repo/x86/startup/Makefile libstdc++.a to -lstdc++
cd $cware_dir/x86/startup
make clean all cpu=x86_64 DEBUG=1 

