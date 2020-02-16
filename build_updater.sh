#!/bin/bash

###################################################################
#Script Name	: build_updater.sh
#Description	: Automatic update tool to fetch new JMS/JBL builds
#Args        	: no args
#Author       : ***********
#Release      : 0.1_alpha
###################################################################

JMS_BUID=''
JMS_RUN=''
JBL_BUILD=''
JBL_RUN=''
LOGFILE=./build_updater_$(date +%F-%H-%M-%S).log



function log(){
	echo "[$(date --rfc-3339=seconds)]: $*" >> $LOGFILE
}
