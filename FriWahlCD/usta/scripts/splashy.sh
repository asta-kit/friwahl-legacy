#!/bin/bash

STR_A1=""
STR_A2=""
STR_L1=""
STR_L2=""

while read LINE
do
	TYPE=`echo $LINE | cut -f1 -d:`
	NAME=`echo $LINE | cut -f2 -d:`
	PROF=`echo $LINE | cut -f3 -d:`

	if [[ $TYPE == "A" ]]; then
		STR_A1+="$NAME\n\n"
		STR_A2+="$PROF\n\n"
	elif [[ $TYPE == "L" ]]; then
		STR_L1+="$NAME\n\n"
		STR_L2+="$PROF\n\n"
	fi
done < $1

convert $2 -pointsize 12 -undercolor white \
	-fill black -annotate +40+180  "$STR_A1" \
	-fill red   -annotate +210+180 "$STR_A2" \
	-fill black -annotate +465+180 "$STR_L1" \
	-fill blue  -annotate +635+180 "$STR_L2" $3
