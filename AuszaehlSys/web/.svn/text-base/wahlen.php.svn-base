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

function set_listen_chart ( $row, &$pass ) {
  array_push ( $pass, $row ["sitze"], 
	       $row ["anzeige_red"], 
	       $row ["anzeige_green"], 
	       $row ["anzeige_blue"] ) ;
}

function show_kandidaten ( $row, &$cnt ) {
	extract ( $row ) ;
	if ( $_liste_id ) {
		print "<TD><TABLE>" ;
		print ( "<TR>".
			colorTD("<B>$liste_name_kurz</B>","center",$r,$g,$b,2).
			"</TR>\n" ) ;
		$cnt = 0 ;
	}
	if ( $_status or $cnt==0) {
		switch ( $status ) {
		case 2:
			print ( "<TR>".
				colorTD("<B>Los (*)</B>",
					"center",0.3,0.3,0.3, 2).
				"</TR>\n" ) ;
			break ;
		case 3:
			print ( "<TR>".
				colorTD("<B>".(	$cnt == 0 ? 
						"nicht&nbsp;dabei" : 
						"Nachr&uuml;cker" ).
					"</B>","center", 0.3,0.3,0.3, 2).
				"</TR>\n" ) ;
			break ;
		}
	}

	print ( "<TR><TD>$kandidat_vorname $kandidat_nachname</TD>".
		"<TD align=right>$stimmen</TD></TR>\n" );
	$cnt++ ;
	
	if ( $liste_id_ ) {
		print "</TABLE></TD>\n" ;
	}
}

function show_listen ( $row ) {
	extract ( $row ) ;
	print ( "<TR>".
		colorTD($name_kurz,"center",$r,$g,$b).
		"<TD align=right>$stimmen</TD>".
		"<TD align=right>".percent($stimmen,$summe)."%</TD>".
		"<TD align=right>$sitze</TD>".
		"<TD align=left>".
		($los> 0 ? "(+1)" : "").
		"</TD>".
		"</TR>\n" ) ;
}

function show_wahlen ( $row ) {
	extract ( $row ) ;

	$wahl_file = str_replace(" ","_",$wahl_name_kurz) ;

	$listen_gueltig = $stimmen_gesamt - $stimmzettel_ungueltig - $listen_ungueltig ;
	$listen_summe   = $listen_gueltig - $listen_enthaltungen ;
	$kandidaten_gueltig = $stimmen_gesamt - $stimmzettel_ungueltig - $kandidaten_ungueltig ;
	$kandidaten_summe   = $kandidaten_gueltig - $kandidaten_enthaltungen ;

	if ( simple_query ( "SELECT count(*) FROM liste ".
			    "WHERE wahl = $wahl_id" ) > 1 ) {
		head ( $wahl_name_kurz . " (Listen)", "$wahl_file-listen.html" ) ;

		// Gesamt-Informationen
		print ( "Wahlberechtigte: $wahlberechtigt, ".
			"abgegebene Stimmzettel: $stimmen_gesamt, ".
			"Wahlbeteiligung: ".
			percent($stimmen_gesamt,$wahlberechtigt)."%".
			"<BR>\n".
			"ung&uuml;ltige Stimmzettel: $stimmzettel_ungueltig, ".
			"ung&uuml;ltige Stimmen: $listen_ungueltig ".
			"g&uuml;ltige Stimmen: $listen_gueltig, ".
			"<BR>\n".
			"Enthaltungen: $listen_enthaltungen ".
			"<BR>\n" ) ;

		// Listen-Tabelle
		print ( "<TABLE><TR valign=top>".
			"<TD><TABLE cellpadding=2>".
			"<TR>".
			"<TD>Liste</TD>".
			"<TD colspan=2>Stimmen</TD>".
			"<TD>Sitze</TD>".
			"</TR>\n" ) ;
		do_query ( 
			"SELECT liste.name_kurz, anzeige_red as r, ".
			"anzeige_green as g, anzeige_blue as b, ".
			"sitze, los, ".
			"sum(liste_urne.stimmen) AS stimmen, ".
			"$listen_summe AS summe ".
			"FROM liste, urne, liste_urne ".
			"WHERE liste.id = liste_urne.liste ".
			"AND urne.id = liste_urne.urne ".
			"AND urne.status = ".$GLOBALS["ok_status"]." ".
			"AND wahl = $wahl_id ".
			"GROUP BY liste.id ".
			"ORDER by liste.nummer", 
			show_listen ) ;
		print "</TABLE>" ;
		$num_los = simple_query ( "SELECT los FROM liste ".
					  "WHERE wahl = $wahl_id ".
					  "AND los > 0" ) ;
		if ( $num_los > 0 ) {
			print ( "(+1): ggf. +1 von $num_los Restsitzen ".
				"per Los\n" ) ;
		}
		print ( "</TD>\n".
			"<TD width=20></TD>\n" ) ;
		
		// Listen-Graph
		
		$chart = array () ;
		do_query_pass ( 
			"SELECT sitze, ".
			"anzeige_red, anzeige_green, anzeige_blue ".
			"FROM liste ".
			"WHERE wahl = $wahl_id ".
			"ORDER by liste.anzeige_nummer", 
			set_listen_chart, $chart ) ;
		if ( $num_los > 0 ) {
			array_push ( $chart, $num_los, 0.5, 0.5, 0.5 ) ;
		}
		print "<TD>" ;

		piechart ( 400, 200, $chart, "$wahl_file-liste.png" ) ;
		image ( "$wahl_file-liste.png" ) ;
		print ( "</TD></TR>\n".
			"</TABLE>\n".
			"<BR>\n" ) ;
		foot() ;
	}
	
	// Kandidaten
	head ( $wahl_name_kurz, "$wahl_file-kandi.html" ) ;

	// Gesamt-Daten
	print ( "Wahlberechtigte: $wahlberechtigt, ".
		"abgegebene Stimmzettel: $stimmen_gesamt, ".
		"Wahlbeteiligung: ".percent($stimmen_gesamt,
					    $wahlberechtigt)."%".
		"<BR>\n".
		"ung&uuml;ltige Stimmzettel: $stimmzettel_ungueltig, ".
		"ung&uuml;ltige Stimmen: $kandidaten_ungueltig, ".
		"g&uuml;ltig: $kandidaten_gueltig ".
		"<BR>\n" ) ;
	if ( $max_stimmen_wert == 1 ) {
		print ( "Enthaltungen: $kandidaten_enthaltungen ".
			"<BR>\n" ) ;
	}
	
	// Kandidaten
	print "<TABLE><TR valign=top>\n" ;
	do_query ( "SELECT liste.id AS liste_id, ".
		   "liste.name_kurz AS liste_name_kurz, ".
		   "anzeige_red AS r, ".
		   "anzeige_green AS g, ".
		   "anzeige_blue AS b, ".
		   "kandidat.status AS status, ".
		   "kandidat.vorname AS kandidat_vorname, ".
		   "kandidat.nachname AS kandidat_nachname, ".
		   "sum(kandidat_urne.stimmen) AS stimmen ".
		   "FROM liste, kandidat, urne, kandidat_urne ".
		   "WHERE kandidat.id = kandidat_urne.kandidat ".
		   "AND urne.id = kandidat_urne.urne ".
		   "AND liste.id = kandidat.liste ".
		   "AND urne.status = ".$GLOBALS["ok_status"]." ".
		   "AND liste.wahl = $wahl_id ".
		   "GROUP BY kandidat.id ".
		   "ORDER BY liste.nummer, status, stimmen DESC, ".
		   "kandidat.listenplatz",
		   show_kandidaten ) ;
	print "</TR></TABLE>\n" ;
	if ( $num_los != 0 ) {
		print ( "(*): $num_los Restsitze werden per Los auf ".
			"die gekennzeichneten Listen verteilt.<BR>" ) ;
	}

	foot() ;
}

do_query ( "SELECT ".
	   "wahl.id as wahl_id, wahl.name_kurz as wahl_name_kurz, ".
	   "wahlberechtigt, sitze, max_stimmen_wert, ".
	   "sum(stimmzettel) as stimmen_gesamt, ".
	   "sum(stimmzettel_ungueltig) as stimmzettel_ungueltig, ".
	   "sum(listen_ungueltig) as listen_ungueltig, ".
	   "sum(listen_enthaltungen) as listen_enthaltungen, ".
	   "sum(kandidaten_ungueltig) as kandidaten_ungueltig, ".
	   "sum(kandidaten_enthaltungen) as kandidaten_enthaltungen ".
	   "FROM wahl, urne, wahl_urne ".
	   "WHERE wahl.id = wahl_urne.wahl ".
	   "AND urne.id = wahl_urne.urne ".
	   "AND status = ".$GLOBALS["ok_status"]." ".
	   "GROUP by wahl.id ".
	   "ORDER by wahl.name_kurz", 
	   show_wahlen ) ;
?>
