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
	printf ( "<tr class=\"%s\"><td>$wahl_name</td>" , $row_number % 2 ? "even" : "odd");
	print ( "<td>$wahlberechtigt</td>".
		"<td>$stimmen_gesamt</td>".
		"<td>".percent($stimmen_gesamt,$wahlberechtigt)."%</td>".
		"</tr>\n" );
}

head ( "Wahlbeteiligung", "wahlbeteiligung.html" ) ;

print "<div class=\"tabelle\"><p><table>\n" ;
print "<tr><th>Wahl</th><th>Wahlberechtigte</th>".
      "<th>Stimmzettel</th><th>Beteiligung</th></tr>\n" ;
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
print "</table></p></div>\n" ;

foot() ;

?>
