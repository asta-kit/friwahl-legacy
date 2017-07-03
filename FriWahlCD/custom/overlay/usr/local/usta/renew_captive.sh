#!/bin/bash

ping -c 1 -W 5 captive-portal.scc.kit.edu > /dev/null
if [ $? -eq 0 ]; then
   . /etc/friwahl/rzaccount.sh
	 curl -s --request POST 'https://captive-portal.scc.kit.edu/login' --data-urlencode "username=$RZACCOUNT" --data-urlencode "password=$RZPASSWORD" | grep -q "erfolgreich"
   if [ $? -eq 0 ]; then
      logger "Authentifizierung am Captive Portal erneuert!"
   else
      logger "Authentifizierung am Captive Portal fehlgeschlagen!"
   fi
else
    logger "Noch authentifiziert oder nicht im vpn/web/belwue oder LTA Netzwerk"
fi

