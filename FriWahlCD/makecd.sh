#!/bin/bash

INFO="\033[42;1m"
ERROR="\033[41;1m"
BLACK="\033[0m"

# NOTE: this requires the script to be executed from its very location
# WARNING: set the path so we get the correct version of mkarchiso; otherwise, the wrong architecture might be used
# you need to manually set the architecture (arch=i686) in ./archiso/archiso/mkarchiso, otherwise the image will be
# built with your machine's architecture, which might be wrong (x86_64 will cause problems with the live CDs)
export PATH=./archiso/archiso:$PATH


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
	echo -e $INFO"Generiere Key in $HOME/keys/$urne/key..."$BLACK
	ssh-keygen -q -t rsa -N '' -C "$urne" -f "$HOME/keys/$urne/key"
fi

[ -d "$HOME/accounts/$urne" ] || mkdir -p "$HOME/accounts/$urne"
if [ ! -f "$HOME/accounts/$urne/rzaccount.sh" ]; then
	if ([ "$konf_account" = "" ] || [ "$konf_pw" = "" ]); then
		echo "konf_account und/oder konf_pw nicht gesetzt"
		exit 1
	fi
	konf_pw=`echo $konf_pw | sed 's/(/\\(/g;s/)/\\)/g'`
	echo -e $INFO"Erstelle RZ-Accountdatei in $HOME/accounts/$urne/rzaccount.sh..."$BLACK
	echo RZACCOUNT=$konf_account > $HOME/accounts/$urne/rzaccount.sh
	echo 'RZPASSWORD=`mkfifo fin && mkfifo fout && mkfifo encode_out && { { cat > fin << EOT ' >> $HOME/accounts/$urne/rzaccount.sh
	mkfifo fin && mkfifo fout && mkfifo encode_out && { echo $konf_pw > fin & openssl rsautl -inkey $HOME/keys/$urne/key -encrypt -in fin -out fout & openssl base64 -in fout -out encode_out & cat encode_out && rm -f fin fout encode_out; } >> $HOME/accounts/$urne/rzaccount.sh
	echo 'EOT' >> $HOME/accounts/$urne/rzaccount.sh
        echo '} & openssl base64 -d -in fin -out encode_out & openssl rsautl -inkey /etc/friwahl/key -decrypt -in encode_out -out fout & cat fout && rm -f fin fout encode_out; }`' >> $HOME/accounts/$urne/rzaccount.sh
fi

DEST=$(pwd)/work/airootfs

echo -e $INFO"Kopiere Keys in das Arbeitsverzeichnis..."$BLACK
mkdir -p "$DEST/etc/friwahl"
chmod +w "$DEST/etc/friwahl"
cp -v "$HOME/keys/$urne/key" "$DEST/etc/friwahl"
#cp -v "$HOME/accounts/$urne/rzaccount.sh" "$DEST/etc/friwahl/rzaccount.sh"
echo "$urne" > "$DEST/etc/friwahl/user"
cp -v usta/data/server "$DEST/etc/friwahl/server"
mkdir -p "$DEST/etc/ssh"
# wahl.asta.kit.edu is entered as the HostKeyAlias in friwahl-client.pl, it will also
# work if the server is on another IP Adress (ie. inside the UStA subnet)
echo -n "wahl.asta.kit.edu ssh-rsa " > "$DEST/etc/ssh/ssh_known_hosts"
cut -f2 -d' ' /etc/ssh/ssh_host_rsa_key.pub >> "$DEST/etc/ssh/ssh_known_hosts"
chmod -w "$DEST/etc/friwahl"

echo -e $INFO"Setze IRC-User und -Passwort..."$BLACK
ircpassword=$(cat usta/data/ircpasswords | grep "^$urne" | cut -d"," -f 2)
if [ -z "$ircpassword" ] ; then
	echo -e $ERROR"Kein IRC-Passwort gefunden fuer $urne"$BLACK
	exit 1
fi
sed "s|{irc_passwd}|$ircpassword|g;s|{irc_user}|$urne|g" usta/data/irssi.conf > $DEST/home/irc/.irssi/config

echo -e $INFO"Setze Hostname zu $urne"$BLACK
echo $urne > $DEST/etc/hostname

echo -e $INFO"Kopiere Key in die authorized_keys-Datei der Urne..."$BLACK
echo -n "command=\"/data/friwahl/Packages/Application/AstaKit.FriWahl.BallotBoxBackend/Scripts/BallotBoxSession.sh $urne\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding " > "$HOME/keys/$urne/ssh_key"
cat "$HOME/keys/$urne/key.pub" >>"$HOME/keys/$urne/ssh_key"
mkdir -p "/home/urnen/$urne/.ssh"
cp "$HOME/keys/$urne/ssh_key" "/home/urnen/$urne/.ssh/authorized_keys"

sed "s|%ISOLABEL%|WAHLCD_$urne|g" usta/data/syslinux.cfg > work/iso/arch/boot/syslinux/syslinux.cfg

echo -e $INFO"Bereite ISO vor..."$BLACK
mkarchiso prepare
echo -e $INFO"Erstelle ISO unter out/WAHL-CD.$urne.iso..."$BLACK
mkarchiso -L "WAHLCD_$urne" -P "Wahlausschuss der VS" -A "Wahl-CD $urne" iso WAHL-CD.$urne.iso

