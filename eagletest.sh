#!/bin/bash

# This is supposed to run inside the peripheral. It's a stress test to catch errors regarding the coin reader in real time
# and kill the application as soon as an error pops in a log file

#remove all logs
rm /mnt/sdfast/Logs/SGPDriver/*


for ((i = 1 ; i < 1000000; i++)); do
        # Trigger a lost ticket. NB: the payment timeout must be short, so we can stress test the antijam solenoid
        echo "$(date +%F-%T) Issuing a lost ticket, iteration nr $i" | tee -a eagletest.log
        curl -X POST -d '{"amount" : 10.0, "timetoexit" : 0, "oldLstUid" : null}' -s http://127.0.0.1:65000/jps/api/command/lsttckt &>/dev/null
        sleep 15
        #check the log files to catch errors and kill the app
        if [[ $(grep 'ACoinFDeckAlrmFilterEvt' /mnt/sdfast/Logs/SGPDriver/*) ]]; then
                echo "$(date +%F-%T) Error found on iteration nr. $i! Stopping the application" | tee -a eagletest.log
                curl -X POST -d '{"mode":"SoftKill"}' -H "Content-Type: application/json"  -s http://127.0.0.1:65000/jps/api/command/reboot &>/dev/null
                exit 1
        else
                echo "$(date +%F-%T) No errors found, keep trying" | tee -a eagletest.log
        fi
done
