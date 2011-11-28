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

head ( "Stand der Auszählung", "status.html" ) ;

function show_urnen($row) {
	extract ( $row ) ;
	if ( $_fakultaet ) {
		print "<TR>".colorTD( $fakultaet, "left",
				      0.9, 0.9, 0.9 )."\n" ;
	}
	
	print colorTD( "<B>$nummer</B>".
		       (isset($stimmen) ? " ($stimmen)" : 
		       " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"), 
		       "left", $red, $green, $blue )."\n" ;
	if ( $fakultaet_ ) {
		print "</TR>\n" ;
	}
}

function set_chart($row,&$chart) {
	extract ( $row ) ;
	array_push ( $chart, $sum, $red, $green, $blue ) ;
}


function show_legende($row) {
	extract ( $row ) ;
	print colorTD( "$name", "center",
		       $red, $green, $blue )."\n" ;
}

section ( "Status der Urnen" ) ;
print "<TABLE border=0 cellpadding=3>\n" ;
do_query ( "SELECT fakultaet, nummer, stimmen, ".
	   "urne_status.name AS status_name, ".
	   "red, green, blue FROM urne, urne_status ".
           "WHERE urne.status = urne_status.id ".
           "ORDER BY fakultaet, nummer", show_urnen ) ;
print "</TABLE><BR>\n" ;

section ( "Status der Stimmen" ) ;
$chart = array();
do_query_pass ( "SELECT sum(stimmen) AS sum, red, green, blue ".
		"FROM urne, urne_status ".
		"WHERE urne.status = urne_status.id ".
		"GROUP BY urne_status.id ".
		"ORDER BY urne_status.id ", set_chart, $chart ) ;

barchart ( 400, 20, $chart, "stimmenstatus.png" ) ;
image ( "stimmenstatus.png" ) ;

print "<BR><TABLE border=0 cellpadding=3><TR>\n" ;
print colorTD( "Legende:", "left", 0.9, 0.9, 0.9 )."\n" ;
do_query ( "SELECT * FROM urne_status ORDER BY id", show_legende ) ;
print "</TR></TABLE><BR>\n" ;

foot() ;
?>
