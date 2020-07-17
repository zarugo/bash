#!/bin/bash

[[ $# -ne 1 ]] && echo -e "\n  Please use \"old\" or \"new\" as an argument" || :

if [[ $1 == "new" ]]; then
  for i in 170 180 190 200 210; do
    ssh root@172.29.0.$i 'rm JPSApps; ln -s JPSApps_1.10.4 JPSApps; reboot' &>/dev/null
  done
  exit 0
elif [[ $1 == "old" ]]; then
  for i in 170 180 190 200 210; do
    ssh root@172.29.0.$i 'rm JPSApps; ln -s JPSApps_1.8.5 JPSApps; reboot' &>/dev/null
  done
  exit 0
elif [[ $1 == "def" ]]; then
  for i in 170 180 190 200 210; do
    ssh root@172.29.0.$i 'rm JPSApps; ln -s JPSApps_1.10.4_default JPSApps; reboot' &>/dev/null
  done
  exit 0
fi
