#/bin/sh

ZETTEL="wahlzettel.dvi"
WAHLJAHR="2006-07"

function do_split
{
  FILENAME="Wahlzettel $WAHLJAHR - $2"
  dvips -pp $1 "$ZETTEL" -o "$FILENAME.ps"
  dvipdfm -p a3 -s $1 -o "$FILENAME.pdf" "$ZETTEL"
  chgrp wahl "$FILENAME.ps" "$FILENAME.pdf"
  chmod og+rw "$FILENAME.ps" "$FILENAME.pdf"
  mv "$FILENAME.ps" "$FILENAME.pdf" /data/wahl/wahl_$WAHLJAHR/Wahlzettel
}

make $ZETTEL

for((i=1; $i<13; i=(($i+1)) )); do
  case $i in
    1)
      do_split $i 'AuslaenderInnenreferat'
    ;;
    2)
      do_split $i 'Bio- und Geowissenschaften'
    ;;
    3)
      do_split $i 'Chemieingenieurwesen'
    ;;
    4)
      do_split $i 'Elektro- und Informationstechnik'
    ;;
    5)
      do_split $i 'Frauenreferat'
    ;;
    6)
      do_split $i 'Geistes- und Sozialwissenschaften'
    ;;
    7)
      do_split $i 'Informatik'
    ;;
    8)
      do_split $i 'Maschinenbau'
    ;;
    9)
      do_split $i 'Mathematik'
    ;;
    10)
      do_split $i 'Physik'
    ;;
    11)
      do_split $i 'Studierendenparlament'
    ;;
    12)
      do_split $i 'Wirtschaftswissenschaften'
    ;;
#    13)
#      do_split $i 'Bauingenieurwesen'
#    ;;
#    14)
#      do_split $i 'Chemie'
#    ;;
  esac
done
