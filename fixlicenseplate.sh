#!/bin/bash

#just a workaround to fix the -1 bug on the license plate recognition with Survision cameras

export PGPASSWORD=jbl
export DB_NAME=jbl

while true; do
	psql -U jbl -c "update lpr_camera_recognitions set original_licence_plate = null where original_licence_plate = '-1' and corrected_licence_plate is null"
	sleep 20
done
