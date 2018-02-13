#!/bin/bash

cd /data

rm -f top.out
top -b -n 1 > top.out

rm -f cpuinfo.out
cat /proc/cpuinfo > cpuinfo.out

rm -f env.out
env > env.out

rm hostname.out
hostname > hostname.out



hd_root --config=jana_recon.config hd_rawdata_??????_???.evio


