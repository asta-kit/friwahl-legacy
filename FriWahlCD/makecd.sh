#!/bin/bash

RED="\033[40;1;31m"
BLACK="\033[0m"

usage() {
       echo "Usage: $1 urne [konf_account konf_pw]"
       exit 1
}

konf_account=""
konf_pw=""

case $# in
	1)
		urne=$1
		;;
	3)
		urne=$1
		konf_account=$2
		konf_pw=$3
		;;
	*)
		usage $0
		;;
esac

[ -d "$HOME/keys/$urne" ] || mkdir -p "$HOME/keys/$urne"
if [ ! -f "$HOME/keys/$urne/key" ]; then
	echo -e $RED"Generiere Key in $HOME/keys/$urne/key..."$BLACK
	ssh-keygen -q -t rsa -N '' -f "$HOME/keys/$urne/key"
fi

[ -d "$HOME/accounts/$urne" ] || mkdir -p "$HOME/accounts/$urne"
if [ ! -f "$HOME/accounts/$urne/rzaccount.sh" ]; then
	if ([ "$konf_account" = "" ] || [ "$konf_pw" = "" ]); then
		echo "konf_account und/oder konf_pw nicht gesetzt"
		exit 1
	fi
	konf_pw=`echo $konf_pw | sed 's/(/\\(/g;s/)/\\)/g'`
	echo -e $RED"Erstelle RZ-Accountdatei in $HOME/accounts/$urne/rzaccount.sh..."$BLACK
	echo RZACCOUNT=$konf_account > $HOME/accounts/$urne/rzaccount.sh
	echo 'RZPASSWORD=`mkfifo fin && mkfifo fout && mkfifo encode_out && { { cat > fin << EOT ' >> $HOME/accounts/$urne/rzaccount.sh
	mkfifo fin && mkfifo fout && mkfifo encode_out && { echo $konf_pw > fin & openssl rsautl -inkey $HOME/keys/$urne/key -encrypt -in fin -out fout & openssl base64 -in fout -out encode_out & cat encode_out && rm -f fin fout encode_out; } >> $HOME/accounts/$urne/rzaccount.sh
	echo 'EOT' >> $HOME/accounts/$urne/rzaccount.sh
        echo '} & openssl base64 -d -in fin -out encode_out & openssl rsautl -inkey /etc/friwahl/key -decrypt -in encode_out -out fout & cat fout && rm -f fin fout encode_out; }`' >> $HOME/accounts/$urne/rzaccount.sh
fi

DEST=$(pwd)/work/airootfs

echo -e $RED"Kopiere Keys in das Arbeitsverzeichnis..."$BLACK
mkdir -p "$DEST/etc/friwahl"
chmod +w "$DEST/etc/friwahl"
cp -v "$HOME/keys/$urne/key" "$DEST/etc/friwahl"
cp -v "$HOME/accounts/$urne/rzaccount.sh" "$DEST/etc/friwahl/rzaccount.sh"
echo "$urne" > "$DEST/etc/friwahl/user"
cp -v usta/data/server "$DEST/etc/friwahl/server"
mkdir -p "$DEST/etc/ssh"
# asta-wahl.asta.uni-karlsruhe.de is entered as the HostKeyAlias, it will also
# work if the server is on another IP Adress (ie. inside the UStA subnet)
echo -n "asta-wahl.asta.uni-karlsruhe.de ssh-rsa " > "$DEST/etc/ssh/ssh_known_hosts"
cut -f2 -d' ' /etc/ssh/ssh_host_rsa_key.pub >> "$DEST/etc/ssh/ssh_known_hosts"
chmod -w "$DEST/etc/friwahl"

echo -e $RED"Setze IRC User und Passwort..."$BLACK
sed "s|__irc_password__|`cat usta/data/ircpassword`|g;s|__urne__|$urne|g" usta/data/irssi.conf > $DEST/home/irc/.irssi/config

echo -e $RED"Setze Hostname zu $urne"$BLACK
echo $urne > $DEST/etc/hostname

echo -e $RED"Kopiere Key in die authorized_keys-Datei der Urne..."$BLACK
echo -n "command=\"/usr/local/FriCardWahl/clearing.pl\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding " > "$HOME/keys/$urne/ssh_key"
cat "$HOME/keys/$urne/key.pub" >>"$HOME/keys/$urne/ssh_key"
mkdir -p "/home/urnen/$urne/.ssh"
cp "$HOME/keys/$urne/ssh_key" "/home/urnen/$urne/.ssh/authorized_keys"

sed "s|%ISOLABEL%|WAHLCD_$urne|g" usta/data/syslinux.cfg > work/iso/arch/boot/syslinux/syslinux.cfg

echo -e $RED"Bereite ISO vor..."$BLACK
mkarchiso prepare
echo -e $RED"Erstelle ISO unter out/WAHL-CD.$urne.iso..."$BLACK
mkarchiso -L "WAHLCD_$urne" -P "Wahlausschuss der VS" -A "Wahl-CD" iso WAHL-CD.$urne.iso

