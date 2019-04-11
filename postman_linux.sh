#!/bin/bash
#set -x
function GET_DEVICES () {
	IPS=$(arp |grep "\ 9c\:53\:cd\:" |awk '{print $1}')
	for i in $IPS
	do 
		TYPE=$(ssh -o "StrictHostKeyChecking no" root@${i} "ps |grep "[J]PSApplication" |awk '{print \$6}'")
		echo "${TYPE}_${i}"
	done
}
if [ $# -lt 1 ]
then

		echo -e "Finding devices on your network..."
		PS3='Select the peripheral you want to send a command to: '
		select DEVICE in $(GET_DEVICES) Quit;
			do
				case $DEVICE in
					Quit)
					echo "Bye!"
					exit
					;;		
					*)
		  			echo "You picked $DEVICE"
	              	PS3='Which command do you want to send?: '
					select COMMAND in HW_Reboot SW_Reboot Force_Auth Get_Status Open_Barrier Set_in_Service Quit;
		  					do
			  					case $COMMAND in
									Quit)
									echo "Bye!"
									exit
									;;
									HW_Reboot)
									echo "The devices will do an Hardware reboot"
									IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')" 	
									curl -X POST -d '{"mode":"Hardware"}' http://${IP}:65000/jps/api/command/reboot --header "Content-Type:application/json"
									;;
									SW_Reboot)
									echo "The device will do a Software reboot"
									IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')"
									curl -X POST -d '{"mode":"Software"}' http://${IP}:65000/jps/api/command/reboot --header "Content-Type:application/json"
									;;
									Force_Auth)
									echo "The device will authentincate again on JBL"
									IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')"
									curl -X GET http://${IP}:65000/jps/api/command/forceauth --header "Content-Type:application/json"
									;;
			        					Open_Barrier)
									echo "The device will open the barrier"
									IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')"
									curl -X POST -d '{"type":"Transit","status":"Opened"}' http://${IP}:65000/jps/api/command/barrier --header "Content-Type:application/json"
									;;
			        					Get_Status)
									echo "Getting device status..."
                                					IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')"
									curl -X GET http://${IP}:65000/jps/api/status --header "Content-Type:application/json"
                                					;;
			        					Set_in_Service)
									echo "Setting the device In Service..."
                               	 					IP="$(echo $DEVICE | sed 's/[A-Za-z_]*//')"
									curl -X POST -d '{"humtriggered": true,"mode":"InService"}' http://${IP}:65000/jps/api/command/setMode --header "Content-Type:application/json"
			   					esac
		   					done
					;;
		
				esac
			done

else

       		PS3='Which command do you want to send?: '
                select COMMAND in HW_Reboot SW_Reboot Force_Auth Get_Status Open_Barrier Set_in_Service Quit;
                	do
                        	case $COMMAND in
                                	Quit)
                                	echo "Bye!"
                                	exit
                                	;;
                                	HW_Reboot)
                                	echo "The devices will do an Hardware reboot"
                                      	curl -X POST -d '{"mode":"Hardware"}' http://${1}:65000/jps/api/command/reboot --header "Content-Type:application/json"
                                	;;
                                	SW_Reboot)
                                	echo "The device will do a Software reboot"
                                	curl -X POST -d '{"mode":"Software"}' http://${1}:65000/jps/api/command/reboot --header "Content-Type:application/json"
                                	;;
                                	Force_Auth)
                                	echo "The device will authentincate again on JBL"
                                        curl -X GET http://${1}:65000/jps/api/command/forceauth --header "Content-Type:application/json"
                                	;;
                                	Open_Barrier)
                                	echo "The device will open the barrier"
									curl -X POST -d '{"type":"Transit","status":"Opened"}' http://${1}:65000/jps/api/command/barrier --header "Content-Type:application/json"
                                	;;
                                	Get_Status)
                                	echo "Getting device status..."
									curl -X GET http://${1}:65000/jps/api/status --header "Content-Type:application/json"
                                	;;
                                	Set_in_Service)
                                	echo "Setting the device In Service..."
                                        curl -X POST -d '{"humtriggered": true,"mode":"InService"}' http://${IP}:65000/jps/api/command/setMode --header "Content-Type:application/json"
                                 esac
                   	done

fi

                




