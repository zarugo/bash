#!/bin/bash
WORKDIR=/home/root
TYPE=$(ps | grep [J]PSApplication | awk '{print $6}')

#if [ $(pwd) != $WORKDIR ]
	# then 
	# cd $WORKDIR
# fi
echo $TYPE
