#!/bin/bash
rm /mnt/sdfast/Logs/SGPDriver/*
for ((i = 1 ; i < 1000000; i++)); do
        echo "$(date +%F-%T) Issuing a lost ticket, iteration nr $i" | tee -a eagletest.log
        curl -X POST -d '{"amount" : 10.0, "timetoexit" : 0, "oldLstUid" : null}' -s http://127.0.0.1:65000/jps/api/command/lsttckt &>/dev/null
        sleep 15
        if [[ $(grep 'ACoinFDeckAlrmFilterEvt' /mnt/sdfast/Logs/SGPDriver/*) ]]; then
                echo "$(date +%F-%T) Error found on iteration nr. $i! Stopping the application" | tee -a eagletest.log
                curl -X POST -d '{"mode":"SoftKill"}' -H "Content-Type: application/json"  -s http://127.0.0.1:65000/jps/api/command/reboot &>/dev/null
                exit 1
        else
                echo "$(date +%F-%T) No errors found, keep trying" | tee -a eagletest.log
        fi
done
