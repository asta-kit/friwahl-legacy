#!/bin/bash

prevfs=""
fssum=0
sum=0

if [ $# -ne 4 ]; then 
	echo $0 raw-wahlen.csv fsquote.dat urne fs-identifier
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

	quote=`grep "^$fs" $2 | cut -f2`

	zettel=$(echo "scale=0;($zettel*$quote+.5)/1" | bc -ql)

	fssum=$(( $fssum+$zettel ))
	sum=$(( $sum+$zettel ))
	prevfs=$fs
done < <(grep "^$4 .*, .*, $3, .*, [0-9][0-9]*, .*, .*, .*, .*, .*" $1 | sed "s|^$4 \\(.*\\), .*, .*, .*, \\(.*\\), .*, .*, .*, .*, .*|\1,\2|g")

echo $prevfs,$fssum >> /tmp/urne.dat

awk -F, "{print \$1, \":\t\", \$2/$sum}" /tmp/urne.dat

rm -f /tmp/urne.dat

