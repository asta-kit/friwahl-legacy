<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

include("dbconfig.php") ;
include("util.php") ;
include("querysys.php") ;
include("headfoot.php") ;

function show_beteiligung ( $row ) {
	extract ( $row ) ;
	print ( "<TR><TD>$wahl_name</TD>".
		"<TD>$wahlberechtigt</TD>".
		"<TD>$stimmen_gesamt</TD>".
		"<TD>".percent($stimmen_gesamt,$wahlberechtigt)."%</TD>".
		"</TR>\n" ) ;
}

head ( "Wahlbeteiligung", "wahlbeteiligung.html" ) ;

print "<TABLE>\n" ;
print "<TR><TD>Wahl</TD><TD>Wahlberechtigte</TD>".
      "<TD>Stimmzettel</TD><TD>Beteiligung</TD></TR>\n" ;
do_query ( "SELECT ".
	   "wahl.id as wahl_id, wahl.name_kurz as wahl_name, ".
	   "wahlberechtigt, ".
	   "sum(stimmzettel) as stimmen_gesamt ".
	   "FROM wahl, urne, wahl_urne ".
	   "WHERE wahl.id = wahl_urne.wahl ".
	   "AND urne.id = wahl_urne.urne ".
	   "AND status = ".$GLOBALS["ok_status"]." ".
	   "GROUP by wahl.id ".
	   "ORDER by wahl.name_kurz", 
	   show_beteiligung ) ;
print "</TABLE>\n" ;

foot() ;

?>
