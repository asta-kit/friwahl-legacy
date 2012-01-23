#!/bin/bash

OLDIFS=$IFS

LINEIFS=$'\n'
SEPIFS=' '

MAKECD="./makecd.sh"

FILE=$1

if [[ ! -f $FILE ]]; then
  echo Ich brauche eine Datei mit den Accountnamen und Passwoertern, durch ein Leerzeichen getrennt.
  echo Der zweite Parameter kann eine Nummer sein, dann macht er ab dieser Urne weiter
  echo Der dritte Parameter kann eine weitere Nummer ein, bis zu der er die Urnen erstellt
  exit 1
fi

URNE=1

if [[ ! -z "$2" ]]; then
  URNE=$(( $2 - 1 + 1 ))
  if [[ "$2" != "$URNE" ]]; then
    echo $2 ist keine Zahl!
    exit 1
  fi
  echo Starte bei Urne $URNE
fi

if [[ ! -z "$3" ]]; then
  URNE_END=$(( $3 - 1 + 1 ))
  if [[ "$3" != "$URNE_END" ]]; then
    echo $3 ist keine Zahl!
    exit 1
  fi
  echo Ende bei Urne $URNE_END	
fi

IFS=$'\n'

LINECOUNTER=1

echo "---------------------------------------" >> cds.log

for line in `cat $FILE`; do
  
  if (( $LINECOUNTER < $URNE )); then
    LINECOUNTER=$(( LINECOUNTER + 1 ))
    continue
  fi
  
  IFS=$SEPIFS
  i=0
  for text in $line; do
    case $i in
      0)
        ACCOUNT_NAME=$text
        ;;
      1)
        ACCOUNT_PASS=$text
        ;;
      *)
        echo Irgendwas stimmt nicht mit der Datei, ich brauche [Accountname] [Accountpasswort] pro Zeile
        exit 1
        ;;
     esac
     i=$(( $i+1 ))
   done
   
   IFS=$OLDIFS

   if (( $URNE < 10 )); then
     URNE_NAME="urne0$URNE"
   else
     URNE_NAME="urne$URNE"
   fi

   echo -e "$URNE_NAME\t$ACCOUNT_NAME" >> cds.log
   echo Erstelle CD: Urne $URNE_NAME mit Account $ACCOUNT_NAME
   $MAKECD $URNE_NAME $ACCOUNT_NAME $ACCOUNT_PASS || exit 1
   echo Urne $URNE_NAME mit Account $ACCOUNT_NAME ist fertig!
   
   IFS=$LINEIFS

   if [[ "$URNE" -eq "$URNE_END" ]]; then
     exit 0
   fi
   
   URNE=$(( $URNE + 1 ))

   LINECOUNTER=$(( LINECOUNTER + 1 ))
done

