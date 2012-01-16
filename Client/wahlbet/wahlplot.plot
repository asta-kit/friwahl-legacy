#!/bin/bash

echo "set xtics ("`(awk '{if (((int(($1-1326697200)/(24*3600))*13+int(($1-1326697200)/3600)%24)%1) == 0) print "\""int(($1-1326697200)/(24*3600))+1". Tag "int(($1-1295218800)/3600)%24 ":00 Uhr\" " int(($1-1326697200)/(24*3600))*13+int(($1-1326697200)/3600)%24}' ~/data/wahlplot.dat) |tr "\n" ","`")"|sed s/",)"/")"/ > /tmp/wahlplot.gp

cat >> /tmp/wahlplot.gp << EOT
set terminal png font '/usr/share/fonts/truetype/freefont/FreeSerif.ttf' size 900,550
set output '~/public_html/wahlbet/wahlplot.png'

set size 0.96,1

set xtics border nomirror rotate by -60

set key left top

set ylabel 'Wahlbeteiligung [%]'
set notitle
set style data linespoints

h(x)=(int((x-1326697200)/(24*3600))*13+int((x-1326697200)/3600)%24)
plot '~/data/wahlplot.dat' using (h(\$1)):3 title 'StuPa','~/data/wahlplot.dat' using (h(\$1)):5 title 'Ausländer','~/data/wahlplot.dat' using (h(\$1)):6 title 'Frauen','~/data/wahlplot.dat' using (h(\$1)):7 title 'Bau','~/data/wahlplot.dat' using (h(\$1)):8 title 'Chemie/Bio','~/data/wahlplot.dat' using (h(\$1)):9 title 'CIW','~/data/wahlplot.dat' using (h(\$1)):10 title 'ETEC','~/data/wahlplot.dat' using (h(\$1)):11 title 'GeistSoz','~/data/wahlplot.dat' using (h(\$1)):12 title 'Geo','~/data/wahlplot.dat' using (h(\$1)):13 title 'Info','~/data/wahlplot.dat' using (h(\$1)):14 title 'Maschinenbau','~/data/wahlplot.dat' using (h(\$1)):15 title 'Mathe','~/data/wahlplot.dat' using (h(\$1)):16 title 'Physik', '~/data/wahlplot.dat' using (h(\$1)):17 title 'WiWi'
EOT

gnuplot /tmp/wahlplot.gp

exit 0
