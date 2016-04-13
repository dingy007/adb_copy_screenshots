#!/bin/bash
# Created by Dinesh Kumar Pulikesi
# Date: 13/04/2016

shopt -s nocasematch 
#############################################################################################
#																							#
# Declare the ADB Location and Directory in your PC to copy the files to.					#
# (To be updated by the user/use an ENV variable)											#
#																							#
#############################################################################################
declare ADB_LOCATION="/home/dinesh/Downloads/android_platform_tools_adb/platform-tools/adb"
declare DIR_TO_COPY_TO="/local/dinesh/personal/docs/docs/project_docs/phone_screens"

#############################################################################################
#																							#
# Declare the Locations for Screenshots in the phones to copy the files from.				#
#																							#
#############################################################################################
declare SAMSUNG_SCREENSHOTS_DIR="/storage/sdcard0/Pictures/Screenshots/"
declare HTC_SCREENSHOTS_DIR="/storage/sdcard0/Pictures/Screenshots/"
declare NEXUS_SCREENSHOTS_DIR="/storage/self/primary/Pictures/Screenshots/"
declare ADB_COMMAND_LIST_DEVICES="devices -l"
declare ADB_COMMAND_SHELL="shell"
declare ADB_COMMAND_LIST_FILES="ls"
declare ADB_PULL_COMMAND="pull"
declare -a FILES_TO_COPY=() # list of all the files to copy from the ScreenShots directory
declare -a DEVICES_ATTACHED=() #list of all the devices attached
declare -a SCREENSHOTS_DIR=($HTC_SCREENSHOTS_DIR $NEXUS_SCREENSHOTS_DIR); #store for all the Screenshots directories
declare -a FILES_ARRAY=() # Could be used to store the image files for copying.

function copy_from_specific_device() {
	cd $DIR_TO_COPY_TO
	echo $1
	echo "Executing the pull command on device: "

	for file in ${FILES_ARRAY[@]}
	do 
		echo "Executing: $ADB_LOCATION -s $1 $ADB_PULL_COMMAND $HTC_SCREENSHOTS_DIR$file"
		sh -c "$ADB_LOCATION -s $1 $ADB_PULL_COMMAND $HTC_SCREENSHOTS_DIR$file ;"
	done
	echo "DONE."
}

function list_connected_device() {
	echo "$ADB_LOCATION $ADB_COMMAND_LIST_DEVICES"
	$ADB_LOCATION $ADB_COMMAND_LIST_DEVICES
}

function list_files_in_screenshots_directory() {
	echo  "$ADB_LOCATION $ADB_COMMAND_SHELL $ADB_COMMAND_LIST_FILES $HTC_SCREENSHOTS_DIR"
	sh -c "$ADB_LOCATION $ADB_COMMAND_SHELL $ADB_COMMAND_LIST_FILES $HTC_SCREENSHOTS_DIR ;"
}

function copy_all_files() {
	cd $DIR_TO_COPY_TO
	declare -a devices=()
	devices=($(list_connected_device | awk '{if(NR>2)print}' | awk '{print $1}')) #list all attached devices
	# Loop through each device in the list
	for each_device in "${devices[@]}"
	do
		  echo "Reviewing: $each_device"
		  for each_location in ${SCREENSHOTS_DIR[@]}
		  do 
		  	echo "==> Looking for ScreenShots: $each_location"

			if [ `$ADB_LOCATION shell "if [ -e ${each_location} ]; then echo 1; fi"` ]; 
			then 
				echo "Folder exists";
				FILES_TO_COPY=($(sh -c "$ADB_LOCATION $ADB_COMMAND_SHELL $ADB_COMMAND_LIST_FILES $each_location"))
				sh -c "$ADB_LOCATION $ADB_PULL_COMMAND $each_location ;"
				echo "-->$FILES_TO_COPY[2]"
			else
				echo "Folder does not exist"; # proceed to check the next known directory
			fi
		done
		#FILES_TO_COPY=(); # reset the files array to null
	done
	# for each device get the list of Screenshots
}

#function check_if_screenshots_dir_exists() {

#}

function help_message() {
	echo "[1]$./copy_files_from_adb.sh"
	echo "	'Display this help message & also the list of the devices currently connected to this system through adb."
	echo "[2]:./copy_files_from_adb.sh listfiles 'NameOfConnectedDevice' "
	echo "  'lists the files in the Screenshots directory of the specified device.'"
	echo "[3]:./copy_files_from_adb.sh copy 'NameOfConnectedDevice' "
	echo "  'Copy specified files from the Screenshots directory of the specified device.'"
	echo "[4]:./copy_files_from_adb.sh copy_all_files"
	echo "  'Copy all Screenshots from the Screenshots directory of all the attached devices.'"
}

function execute_functions() {
	case $1 in 
		copy)
			copy_from_specific_device $2;;
		listfiles)
			list_files_in_screenshots_directory $2;;

		*)
			help_message;;
	esac
}

function intialize_script() {
	if [[ -z $1 && -z $2 ]]; 
	then
		echo "No parameters provided.";
		echo "Display help file & results from commands that do not require any input parameters related to the ADB."
		# help_message;
		# list_connected_device;
		copy_all_files
	else
		# execute_functions $1 $2
		copy_all_files
	fi
}



intialize_script $1 $2
#copy_from_specific_device $1
# list_files_in_screenshots_directory
#list_connected_device

shopt -u nocasematch 