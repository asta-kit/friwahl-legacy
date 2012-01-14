#!/bin/bash

sed '1d;s/, /,/g;/^$/d' $1 | cut -d, -f3 | sort -u
