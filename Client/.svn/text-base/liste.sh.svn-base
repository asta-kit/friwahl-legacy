#!/bin/bash

echo -n "Server: "
read server || exit

echo -n "Username: "
read user || exit

/usr/local/FriCardWahl/liste.pl |
a2ps --no-header --borders=0 --chars-per-line=30 --columns=6 -o - |
ssh -l "$user" "$server" "lpr"