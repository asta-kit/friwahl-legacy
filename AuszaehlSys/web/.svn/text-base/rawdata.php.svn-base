<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

include("dbconfig.php") ;
include("querysys.php") ;


function show_csv ( $row, $pass ) {
	print implode ( ', ',array_slice($row,0,$pass) )."\n" ;
}

print "\n<NEWFILE raw-wahlen.csv Rohdaten Wahlen>\n" ;
print ( "Wahl, Wahlberechtigte, Fakultaet, Urne, ".
	"Stimmzettel, Ungueltige Stimmzettel, ".
	"Ungueltige Listenstimmen, Enthaltungen Listenstimmen, ".
	"Ungueltige Kandidatenstimmen, Enthaltungen Kandidatenstimmen\n" ) ;
$n = 10;
do_query_pass ( "SELECT wahl.name_kurz, ".
		"wahlberechtigt, ".
		"urne.fakultaet, urne.nummer, ".
		"wahl_urne.stimmzettel, ".
		"wahl_urne.stimmzettel_ungueltig, ".
		"wahl_urne.listen_ungueltig, ".
		"wahl_urne.listen_enthaltungen, ".
		"wahl_urne.kandidaten_ungueltig, ".
		"wahl_urne.kandidaten_enthaltungen ".
		"FROM wahl, urne, wahl_urne ".
		"WHERE wahl_urne.wahl = wahl.id ".
		"AND wahl_urne.urne = urne.id ".
		"AND urne.status=".$GLOBALS["ok_status"]." ".
		"ORDER BY wahl.name_kurz, ".
		"urne.fakultaet, urne.nummer, urne.id",
		show_csv, $n ) ;

print "\n<NEWFILE raw-listen.csv Rohdaten Listenstimmen>\n" ;
print "Wahl, Liste, Fakultaet, Urne, Stimmen\n" ;
$n = 5;
do_query_pass ( "SELECT wahl.name_kurz AS wahl_name, ".
		"liste.name_kurz AS liste_name, ".
		"urne.fakultaet, urne.nummer, ".
		"liste_urne.stimmen ".
		"FROM wahl, liste, urne, liste_urne ".
		"WHERE liste_urne.liste = liste.id ".
		"AND liste_urne.urne = urne.id ".
		"AND wahl.id = liste.wahl ".
		"AND urne.status=".$GLOBALS["ok_status"]." ".
		"ORDER BY wahl.name_kurz, liste.nummer, liste.id, ".
		"urne.fakultaet, urne.nummer, urne.id",
		show_csv, $n ) ;

print "\n<NEWFILE raw-kandidaten.csv Rohdaten Kandidierendenstimmen>\n" ;
print "Wahl, Liste, Kandidat Nachname, Kandidat Vorname, Fakultaet, Urne, Stimmen\n" ;
$n = 7;
do_query_pass ( "SELECT wahl.name_kurz AS wahl_name, ".
		"liste.name_kurz AS liste_name, ".
		"kandidat.nachname, ".
		"kandidat.vorname, ".
		"urne.fakultaet, urne.nummer, ".
		"kandidat_urne.stimmen ".
		"FROM wahl, liste, kandidat, urne, kandidat_urne ".
		"WHERE kandidat_urne.kandidat = kandidat.id ".
		"AND kandidat_urne.urne = urne.id ".
		"AND wahl.id = liste.wahl ".
		"AND liste.id = kandidat.liste ".
		"AND urne.status=".$GLOBALS["ok_status"]." ".
		"ORDER BY wahl.name_kurz, liste.nummer, liste.id, ".
		"kandidat.listenplatz, kandidat.id, ".
		"urne.fakultaet, urne.nummer, urne.id",
		show_csv, $n ) ;
?>
