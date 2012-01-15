#!/bin/bash

prevfs=""
fssum=0
sum=0

if [ $# -ne 3 ]; then 
	echo $0 raw-wahlen.csv urne fs-identifier
	exit 1
fi

rm -f /tmp/urne.dat

while read line; do
	fs=`echo $line | cut -d, -f1`
	zettel=`echo $line | cut -d, -f2`

	if [ "$fs" != "$prevfs" -a "$prevfs" != "" ]; then
		echo $prevfs,$fssum >> /tmp/urne.dat
		fssum=0
	fi

	fssum=$(( $fssum+$zettel ))
	sum=$(( $sum+$zettel ))
	prevfs=$fs
done < <(grep "^$3 .*, .*, $2, .*, [0-9][0-9]*, .*, .*, .*, .*, .*" $1 | sed "s|^$3 \\(.*\\), .*, .*, .*, \\(.*\\), .*, .*, .*, .*, .*|\1,\2|g")

echo $prevfs,$fssum >> /tmp/urne.dat

awk -F, "{print \$1, \":\t\", \$2/$sum}" /tmp/urne.dat

rm -f /tmp/urne.dat

