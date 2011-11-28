<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

include("dbconfig.php") ;
include("util.php") ;
include("querysys.php") ;
include("headfoot.php") ;
include("graph.php") ;


function show_stupa_fak ( $row, &$pass ) {
	extract ( $row ) ;
	if ( $_fakultaet ) {
		print "<TR><TD>$fakultaet</TD>\n" ;
		$pass = array() ;
	}
	array_push ( $pass, $stimmen, $r, $g, $b ) ;
	if ( $fakultaet_ ) {
		print "<TD>\n" ;
		## Wenn Fakultät einen Slash enthält, ersetze durch Unterstrich
		$fakultaet = str_replace("/", "_", $fakultaet);
		barchart ( 200, 15, $pass, "stupa-fak-$fakultaet.png" ) ;
		image ( "stupa-fak-$fakultaet.png" ) ;
		print "</TD></TR>\n" ;
	}
}

function show_legende ( $row ) {
	extract ( $row ) ;
	print colorTD ( $name_kurz, "center", $r, $g, $b ) . "\n" ;
}

$pass = array() ;

head ( "StuPa nach Fakultäten", "stupa-fak.html" ) ;
print "<TABLE>" ;
do_query_pass ( "SELECT urne.fakultaet, sum(liste_urne.stimmen) AS stimmen, ".
		"anzeige_red AS r, anzeige_green AS g, anzeige_blue AS b ".
		"FROM wahl, liste, urne, liste_urne ".
		"WHERE liste_urne.liste = liste.id ".
		"AND liste_urne.urne = urne.id ".
		"AND wahl.id = liste.wahl ".
		"AND urne.status=".$GLOBALS["ok_status"]." ".
		"AND wahl.name_kurz = 'StuPa' ".
		"GROUP BY fakultaet, anzeige_nummer, liste.id",
		show_stupa_fak, $pass ) ;
print "</TABLE>\n" ;
print "<BR>\n" ;
print "<TABLE><TR>" ;
print colorTD ( "Legende:", "left", 0.9,0.9,0.9 ) . "\n" ;
do_query ( "SELECT liste.name_kurz, ".
	   "anzeige_red AS r, anzeige_green AS g, anzeige_blue AS b ".
	   "FROM wahl, liste ".
	   "WHERE wahl.id = liste.wahl ".
	   "AND wahl.name_kurz = 'StuPa' ".
	   "ORDER BY anzeige_nummer, liste.id",
	   show_legende ) ;
print "</TR></TABLE><BR>\n" ;

foot() ;
?>
