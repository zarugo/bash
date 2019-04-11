#!/bin/bash


IPS=$(arp.exe -a |grep 9c-53 |awk '{print $1}')
TYPE=$(ssh -o "StrictHostKeyChecking no" root@${IPS} "ps |grep "[J]PSApplication" |awk '{print \$6}'")
for i in $IPS
	do 
		echo "${IPS}_${TYPE}"
	done
