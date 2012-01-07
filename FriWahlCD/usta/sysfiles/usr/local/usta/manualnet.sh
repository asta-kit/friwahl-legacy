#!/bin/bash

#
# $Id: manualnet.sh 451 2011-01-16 09:33:08Z mariop $
#

isnum() {
	if [[ "$1" == "" ]]; then
	       return 0
	fi

	case $1 in
	*[!0-9]*)
		return 0;;
	*)
		return 1;;
	esac
}


isip() {
	dots=$(echo $1 | sed 's/\./\n/g' | wc -l)

	if [[ "$dots" != "4" ]]; then
		return 0
	fi

	part1=$(echo $1 | cut -d. -f1)
	part2=$(echo $1 | cut -d. -f2)
	part3=$(echo $1 | cut -d. -f3)
	part4=$(echo $1 | cut -d. -f4)

	if (isnum "$part1" || isnum "$part2" || isnum "$part3" || isnum "$part4"); then
		return 0
	fi

	if ([ $part1 -ge 256 ] || [ $part2 -ge 256 ] || [ $part3 -ge 256 ] || [ $part4 -ge 256 ]); then
		return 0
	fi

	return 1
}

#IP-Adressen für Interface auslesen
getip() {
	device=$1
	ip=$(/sbin/ip -4 addr show dev $device | grep -Eoh '([0-9]{1,3}.){3}[0-9]{1,3}/[0-9]{1,2}' | tr '\n' '; ')
	if [ -z "$ip" ]; then
		ip="unset"
	fi
	echo $ip
}

#Alle Netzwerkschnittstellen auslesen, die vom Typ Ethernet sind
#abwechselnd mit IP-Adressen toggle wert  für den Dialog in ein
#array speichern.
i=0
for devicepath in /sys/class/net/* ; do
	if [ $(cat $devicepath/type) -eq 1 ]; then
		device=$(basename $devicepath)
		devicelist[$i]=$device;
		((i++))
		devicelist[$i]=$(getip $device)
		((i++))
		devicelist[$i]="off"
		((i++))
	fi;
done

#den ersten Eintrag als default-Auswahl setzen.
devicelist[2]="on"

#Wiviel devices sollen angezeigt werden, bevor gescrollt werden muss?
showdev=5

DATA=$(dialog --stdout --backtitle "$BACKTITLE" --title "Netzwerkeinstellungen" \
	--auto-toggle --radiolist "Schnittstelle" 0 40 $showdev ${devicelist[@]} \
        --output-separator ";" --backtitle "$BACKTITLE" --backfoot "(*) optional" --form "Einstellungen" \
	12 45 0 \
        "IP:"       1 1 "192.168.178.100"       1 23 16 15 \
        "Netmask:"  2 1 "255.255.255.0"  2 23 16 15 \
        "Gateway:"  3 1 "192.168.178.1"  3 23 16 15 \
        "DNS1:"     4 1 "8.8.8.8"     4 23 16 15 \
	"DNS2(*):"     5 1 ""     5 23 16 15) || exit 1

intf=$(echo $DATA    | sed 's/ /\;/g' | cut -d ";" -f 1)
ip=$(echo $DATA      | sed 's/ /\;/g' | cut -d ";" -f 2)
netmask=$(echo $DATA | sed 's/ /\;/g' | cut -d ";" -f 3)
gateway=$(echo $DATA | sed 's/ /\;/g' | cut -d ";" -f 4)
dns1=$(echo $DATA    | sed 's/ /\;/g' | cut -d ";" -f 5)
dns2=$(echo $DATA    | sed 's/ /\;/g' | cut -d ";" -f 6)

if [[ $ip == "" ]]; then
	dialog --backtitle "$BACKTITLE" --msgbox "keine IP eingegeben" 5 30 
	sleep 1
	exit 1
fi

if isip "$ip"; then
	dialog --backtitle "$BACKTITLE" --msgbox "IP ungültig" 5 30
	exit 1
fi

options="$intf $ip "

if [[ $netmask != "" ]]; then
	if isip "$netmask"; then
		dialog --backtitle "$BACKTITLE" --msgbox "Netmask ungültig" 5 30 
		exit 1
	fi
	options+=" netmask $netmask"
fi

if [[ "$gateway" != "" ]]; then
	if isip "$gateway"; then
		dialog --backtitle "$BACKTITLE" --msgbox "Gateway ungültig" 5 30
		exit 1
	fi
fi

ifconfig $intf up
ifconfig $options

if [[ $gateway != "" ]]; then
	route add default gw $gateway
fi

nameserver=""

if [[ $dns1 != "" ]]; then
	if isip "$dns1"; then
		dialog --backtitle "$BACKTITLE" --msgbox "DNS1 ungültig" 5 30
		exit 1
	fi
	nameserver="nameserver $dns1\n"
fi

if [[ $dns2 != "" ]]; then
	if isip "$dns2"; then
		dialog --backtitle "$BACKTITLE" --msgbox "DNS2 ungültig" 5 30
		exit 1
	fi
	nameserver+="nameserver $dns2\n"
fi

if [[ $nameserver != "" ]]; then
	echo -e $nameserver > /etc/resolv.conf
fi

