#/bin/sh

#
# $Id: wlanconf.sh 401 2011-01-09 18:33:05Z mariop $
#


. /etc/friwahl/rzaccount.sh

DIALOG=dialog
MESSAGE0="Keine Wireless-Netzwerkkarte gefunden."
MESSAGE1="Konfiguration der Wireless-Parameter von"
MESSAGE2="Bitte Wireless-Netzwerkkarte auswählen"

# Gibt es überhaupt Wireless Karten ?
#WLDEVICES=`grep -v "|" /proc/net/wireless | gawk -F: '{print $1}'`

WLDEVICES=""

for devdir in /sys/class/net/*; do
	dev=`echo $devdir | sed "s|/sys/class/net/||g"`
	if [ `cat $devdir/type` = "1" ]; then
		if [ -d "$devdir/wireless" ]; then
			WLDEVICES="$WLDEVICES $dev"
		fi
	fi
done

if [ -z "$WLDEVICES" ]; then
    $DIALOG --backtitle "$BACKTITLE" --msgbox "$MESSAGE0" 10 50
    exit 1
fi

# Suche eine der Wireless Karten aus, wenn es mehrere gibt,
# sonst nur Bestätigung
SECOND=`echo $WLDEVICES |  gawk '{print $2}'`

if [ -n "$1" ]; then

    SECOND=""
    WLDEVICES="$1"

fi
if [ -z "$SECOND" ]; then

    # Es gibt nur eine
    WLDEV=`echo $WLDEVICES |  gawk '{print $1}'`
    $DIALOG --backtitle "$BACKTITLE" --msgbox "$MESSAGE1 $WLDEV" 10 50

else
    DEVICELIST=""
    for DEVICE in $WLDEVICES; do
        NUMBER="${DEVICE##eth}"
        NUMBER="${NUMBER##wlan}"
        DEVICELIST="$DEVICELIST ${DEVICE} $NWC${NUMBER}"; done
        WLDEV=$($DIALOG --stdout --backtitle "$BACKTITLE" --menu "$MESSAGE2" 18 45 12 $DEVICELIST) || exit 0
fi

killall openvpn 2> /dev/null
killall dhclient 2> /dev/null
killall wpa_supplicant 2> /dev/null

ifconfig $WLDEV up

sleep 5

choice=$($DIALOG \
        --stdout \
        --backtitle "$BACKTITLE" \
        --title "WLAN-Einrichtung" \
        --ok-label "Ok" \
        --menu "Bitte einen Netzwerk-Namen auswählen:" \
        0 0 0 $(iwlist $WLDEV scan 2>/dev/null | grep ESSID | cut -d'"' -f2 | grep -v "^$" | sed 's| |_|g; s|$| Funknetz|g') manual "Manuelle Einrichtung (Experten)") || exit 0

    if [ "$choice" == manual ] ; then
	choice=$($DIALOG --stdout --backtitle "$BACKTITLE" --title "WLAN-Einstellungen" --ok-label "Ok" --inputbox "ESSID" 8 40) || exit 0
    fi

    echo "Verbinde zu $choice ..."

    iwconfig "$WLDEV" essid "$choice"

    if [ "$choice" == "wkit-802.1x" ] ; then
	 echo "Starte WPA Supplikanten ..."
	 sed "s|__rzaccount__|$RZACCOUNT@uni-karlsruhe.de|g;s|__rzpassword__|$RZPASSWORD|g" /etc/wpa_supplicant.conf0 > /tmp/wpa_supplicant.conf
	 wpa_supplicant -c /tmp/wpa_supplicant.conf -i$WLDEV -B
	 sleep 5
    fi

    echo -n "Suche Netz auf $WLDEV ..."

    dhclient $WLDEV || { echo "fehlgeschlagen"; echo "Beliebige Taste um fortzufahren."; read -n1; exit 1; }

    echo "OK"
    exit 0

